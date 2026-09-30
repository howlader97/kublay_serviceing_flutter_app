import 'package:flutter_riverpod/legacy.dart';
import 'package:belwork/models/professional_profile_details_model.dart';
import 'package:belwork/services/repository/professional_repository.dart';
import 'package:belwork/utils/app_log.dart';

class TechnicianProfileState {
  final ProfessionalProfileDetailsModel? profileDetails;
  final bool isLoading;
  final String? errorMessage;

  const TechnicianProfileState({
    this.profileDetails,
    this.isLoading = false,
    this.errorMessage,
  });

  TechnicianProfileState copyWith({
    ProfessionalProfileDetailsModel? profileDetails,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TechnicianProfileState(
      profileDetails: profileDetails ?? this.profileDetails,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class TechnicianProfileNotifier extends StateNotifier<TechnicianProfileState> {
  final ProfessionalRepository _repository = ProfessionalRepository.instance;
  String? _lastKnownAvatar;
  String? _lastKnownName;

  TechnicianProfileNotifier() : super(const TechnicianProfileState());

  void updateUserLocally({String? name, String? avatarUrl}) {
    if ((name != null && name.isNotEmpty) || (avatarUrl != null && avatarUrl.isNotEmpty)) {
      if (name != null && name.isNotEmpty) {
        _lastKnownName = name;
      }
      if (avatarUrl != null && avatarUrl.isNotEmpty) {
        _lastKnownAvatar = avatarUrl;
      }
      final currentDetails = state.profileDetails;
      final currentProf = currentDetails?.data?.professional;
      final currentUser = currentProf?.user;
      if (currentProf != null && currentUser != null) {
        final updatedUser = ProfessionalUserData(
          id: currentUser.id,
          name: name ?? currentUser.name,
          contact: currentUser.contact,
          avatar: avatarUrl ?? currentUser.avatar,
          role: currentUser.role,
          takenServices: currentUser.takenServices,
          latitude: currentUser.latitude,
          longitude: currentUser.longitude,
          address: currentUser.address,
          bio: currentUser.bio,
          rating: currentUser.rating,
        );
        final updatedProf = ProfessionalData(
          id: currentProf.id,
          userId: currentProf.userId,
          corporateVatNumber: currentProf.corporateVatNumber,
          cbeSecurityFile: currentProf.cbeSecurityFile,
          workingRadiusKmLatitude: currentProf.workingRadiusKmLatitude,
          workingRadiusKmLongitude: currentProf.workingRadiusKmLongitude,
          status: currentProf.status,
          type: currentProf.type,
          isSupplier: currentProf.isSupplier,
          hourlyRate: currentProf.hourlyRate,
          category: currentProf.category,
          workingTime: currentProf.workingTime,
          workingTimeStart: currentProf.workingTimeStart,
          workingTimeEnd: currentProf.workingTimeEnd,
          availability: currentProf.availability,
          websiteLink: currentProf.websiteLink,
          createdAt: currentProf.createdAt,
          updatedAt: currentProf.updatedAt,
          user: updatedUser,
        );
        final updatedData = ProfessionalProfileDetailsData(
          professional: updatedProf,
          allProjects: currentDetails?.data?.allProjects,
          allReviews: currentDetails?.data?.allReviews,
          allServices: currentDetails?.data?.allServices,
        );
        state = state.copyWith(
          profileDetails: ProfessionalProfileDetailsModel(
            message: currentDetails?.message,
            data: updatedData,
          ),
        );
      }
    }
  }

  void setAvatar(String avatarUrl) {
    updateUserLocally(avatarUrl: avatarUrl);
  }

  Future<void> fetchProfileDetails({bool showLoading = true}) async {
    if (showLoading) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }
    try {
      final data = await _repository.getProfessionalProfileDetails();
      if (data != null) {
        final fetchedAvatar = data.data?.professional?.user?.avatar;
        final fetchedName = data.data?.professional?.user?.name;

        if (fetchedAvatar != null && fetchedAvatar.isNotEmpty) {
          _lastKnownAvatar = fetchedAvatar;
        }
        if (fetchedName != null && fetchedName.isNotEmpty) {
          _lastKnownName = fetchedName;
        }

        final currentProf = data.data?.professional;
        final currentUser = currentProf?.user;
        if (currentProf != null && currentUser != null) {
          final effectiveAvatar = (fetchedAvatar != null && fetchedAvatar.isNotEmpty)
              ? fetchedAvatar
              : _lastKnownAvatar;
          final effectiveName = (fetchedName != null && fetchedName.isNotEmpty)
              ? fetchedName
              : _lastKnownName;

          if ((effectiveAvatar != null && effectiveAvatar != currentUser.avatar) ||
              (effectiveName != null && effectiveName != currentUser.name)) {
            final updatedUser = ProfessionalUserData(
              id: currentUser.id,
              name: effectiveName ?? currentUser.name,
              contact: currentUser.contact,
              avatar: effectiveAvatar ?? currentUser.avatar,
              role: currentUser.role,
              takenServices: currentUser.takenServices,
              latitude: currentUser.latitude,
              longitude: currentUser.longitude,
              address: currentUser.address,
              bio: currentUser.bio,
              rating: currentUser.rating,
            );
            final updatedProf = ProfessionalData(
              id: currentProf.id,
              userId: currentProf.userId,
              corporateVatNumber: currentProf.corporateVatNumber,
              cbeSecurityFile: currentProf.cbeSecurityFile,
              workingRadiusKmLatitude: currentProf.workingRadiusKmLatitude,
              workingRadiusKmLongitude: currentProf.workingRadiusKmLongitude,
              status: currentProf.status,
              type: currentProf.type,
              isSupplier: currentProf.isSupplier,
              hourlyRate: currentProf.hourlyRate,
              category: currentProf.category,
              workingTime: currentProf.workingTime,
              workingTimeStart: currentProf.workingTimeStart,
              workingTimeEnd: currentProf.workingTimeEnd,
              availability: currentProf.availability,
              websiteLink: currentProf.websiteLink,
              createdAt: currentProf.createdAt,
              updatedAt: currentProf.updatedAt,
              user: updatedUser,
            );
            final updatedData = ProfessionalProfileDetailsData(
              professional: updatedProf,
              allProjects: data.data?.allProjects,
              allReviews: data.data?.allReviews,
              allServices: data.data?.allServices,
            );
            final finalModel = ProfessionalProfileDetailsModel(
              message: data.message,
              data: updatedData,
            );
            state = state.copyWith(profileDetails: finalModel, isLoading: false);
            return;
          }
        }
        state = state.copyWith(profileDetails: data, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load profile data',
        );
      }
    } catch (e) {
      errorLog('TechnicianProfileNotifier.fetchProfileDetails', e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void clearProfile() {
    _lastKnownAvatar = null;
    _lastKnownName = null;
    state = const TechnicianProfileState();
  }
}

final technicianProfileProvider =
    StateNotifierProvider<TechnicianProfileNotifier, TechnicianProfileState>(
  (ref) => TechnicianProfileNotifier(),
);
