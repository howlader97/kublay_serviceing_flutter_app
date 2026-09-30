import 'package:belwork/constant/app_api_url.dart';
import 'package:belwork/models/chat_model.dart';
import 'package:belwork/models/job_proposal_model.dart';
import 'package:belwork/services/api/api_services.dart';
import 'package:belwork/utils/app_log.dart';

class ChatRepository {
  ChatRepository._privateConstructor();
  static final ChatRepository _instance = ChatRepository._privateConstructor();
  static ChatRepository get instance => _instance;

  final ApiServices _apiServices = ApiServices.instance;
  final AppApiUrl _api = AppApiUrl.instance;

  /// Create job proposal via POST /professional/job-proposal
  Future<JobProposalResponseData?> createJobProposal(
    JobProposalRequest request,
  ) async {
    try {
      final response = await _apiServices.postServices(
        url: _api.createJobProposal,
        body: request.toJson(),
      );

      if (response != null &&
          response['data'] != null &&
          response['data'] is Map<String, dynamic>) {
        return JobProposalResponseData.fromJson(
          response['data'] as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e) {
      errorLog('ChatRepository.createJobProposal', e);
      return null;
    }
  }

  /// Send message via POST /user/message
  Future<ChatMessageModel?> sendMessage({
    required String receiverId,
    required String message,
    String? jobId,
    String? proposalId,
    String? currentUserId,
  }) async {
    try {
      final body = <String, dynamic>{
        'receiverId': receiverId,
        'message': message,
      };
      if (jobId != null && jobId.isNotEmpty) {
        body['jobId'] = jobId;
      }
      if (proposalId != null && proposalId.isNotEmpty) {
        body['proposalId'] = proposalId;
      }

      final response = await _apiServices.postServices(
        url: _api.sendMessage,
        body: body,
      );

      if (response != null &&
          response['data'] != null &&
          response['data'] is Map<String, dynamic>) {
        return ChatMessageModel.fromJson(
          response['data'],
          currentUserId: currentUserId,
        );
      }
      return null;
    } catch (e) {
      errorLog('ChatRepository.sendMessage', e);
      return null;
    }
  }

  /// Get last message list via GET /user/messages/get-last-message-list
  Future<List<ChatListItemModel>> getLastMessageList({
    String? currentUserId,
  }) async {
    try {
      final response = await _apiServices.getServices(_api.getLastMessageList);
      if (response != null && response['data'] != null) {
        List rawList = [];
        if (response['data'] is List) {
          rawList = response['data'];
        } else if (response['data'] is Map<String, dynamic>) {
          final dataMap = response['data'] as Map<String, dynamic>;
          // Support multiple possible key names from backend
          if (dataMap['conversations'] is List) {
            rawList = dataMap['conversations'];
          } else if (dataMap['lastConversation'] is List) {
            rawList = dataMap['lastConversation'];
          } else if (dataMap['messages'] is List) {
            rawList = dataMap['messages'];
          }
        }
        return rawList
            .whereType<Map<String, dynamic>>()
            .map(
              (e) =>
                  ChatListItemModel.fromJson(e, currentUserId: currentUserId),
            )
            .toList();
      }
      return [];
    } catch (e) {
      errorLog('ChatRepository.getLastMessageList', e);
      return [];
    }
  }

  /// Get conversation messages between current user and specified userId via GET /user/messages/$userId
  Future<List<ChatMessageModel>> getConversationMessages({
    required String userId,
    String? currentUserId,
  }) async {
    try {
      final response = await _apiServices.getServices(
        _api.getConversationMessages(userId),
        showErrorSnackBar: false,
      );
      if (response != null &&
          response['data'] != null &&
          response['data'] is List) {
        final List list = response['data'];
        return list
            .map(
              (e) => ChatMessageModel.fromJson(
                e as Map<String, dynamic>,
                currentUserId: currentUserId,
              ),
            )
            .toList();
      }
      return [];
    } catch (e) {
      errorLog('ChatRepository.getConversationMessages', e);
      return [];
    }
  }

  /// Get user profile by userId via GET /user/$userId
  Future<ChatUserModel?> getUserById(String userId) async {
    if (userId.isEmpty) return null;
    try {
      final response = await _apiServices.getServices(
        _api.getUserById(userId),
        showErrorSnackBar: false,
      );
      if (response != null && response is Map<String, dynamic>) {
        if (response['data'] != null &&
            response['data'] is Map<String, dynamic>) {
          return ChatUserModel.fromJson(
            response['data'] as Map<String, dynamic>,
          );
        } else {
          return ChatUserModel.fromJson(response);
        }
      }
      return null;
    } catch (e) {
      errorLog('ChatRepository.getUserById', e);
      return null;
    }
  }

  /// Mark messages as read via PATCH /user/messages/update-isRead-status/$userId
  Future<bool> markMessagesAsRead(String userId) async {
    if (userId.isEmpty) return false;
    try {
      final response = await _apiServices.patchServices(
        url: _api.updateIsReadStatus(userId),
        showErrorSnackBar: false,
      );
      if (response != null) {
        return true;
      }
      return false;
    } catch (e) {
      errorLog('ChatRepository.markMessagesAsRead', e);
      return false;
    }
  }

  /// Update job proposal status via PATCH /professional/job-proposal/{proposalId}/status
  Future<bool> updateJobProposalStatus({
    required String proposalId,
    required String status,
  }) async {
    if (proposalId.isEmpty) return false;
    try {
      final response = await _apiServices.patchServices(
        url: _api.updateJobProposalStatus(proposalId),
        body: {'status': status},
      );
      if (response != null) {
        return true;
      }
      return false;
    } catch (e) {
      errorLog('ChatRepository.updateJobProposalStatus', e);
      return false;
    }
  }

  /// Create payment checkout session via POST /user/create-payment-checkout
  Future<String?> createPaymentCheckout({
    required String jobId,
    required String professionalId,
    required dynamic totalHoursToComplete,
    required dynamic hourlyRate,
    required dynamic materialPrice,
    required dynamic vatPercentage,
  }) async {
    try {
      final hoursNum = num.tryParse(totalHoursToComplete.toString()) ?? 0;
      final rateNum = num.tryParse(hourlyRate.toString()) ?? 0;
      final materialNum = num.tryParse(materialPrice.toString()) ?? 0;
      final vatNum = num.tryParse(vatPercentage.toString()) ?? 0;

      final body = <String, dynamic>{
        'jobId': jobId,
        'professionalId': professionalId,
        'totalHoursToComplete': hoursNum,
        'hourlyRate': rateNum,
        'materialPrice': materialNum,
        'vatPercentage': vatNum,
      };

      final response = await _apiServices.postServices(
        url: _api.createPaymentCheckout,
        body: body,
      );

      if (response != null && response is Map) {
        final checkoutUrl = response['url']?.toString() ??
            response['checkoutUrl']?.toString() ??
            response['sessionUrl']?.toString() ??
            response['paymentUrl']?.toString() ??
            response['redirectUrl']?.toString() ??
            response['stripeUrl']?.toString() ??
            response['link']?.toString() ??
            (response['data'] is Map
                ? (response['data']['url']?.toString() ??
                    response['data']['checkoutUrl']?.toString() ??
                    response['data']['sessionUrl']?.toString() ??
                    response['data']['paymentUrl']?.toString() ??
                    response['data']['redirectUrl']?.toString() ??
                    response['data']['stripeUrl']?.toString())
                : null) ??
            (response['data'] is String &&
                    response['data'].toString().startsWith('http')
                ? response['data'].toString()
                : null);

        if (checkoutUrl != null && checkoutUrl.isNotEmpty) {
          return checkoutUrl;
        }
      }
      return null;
    } catch (e) {
      errorLog('ChatRepository.createPaymentCheckout', e);
      return null;
    }
  }
}
