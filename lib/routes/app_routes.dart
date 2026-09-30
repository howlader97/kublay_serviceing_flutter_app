import 'package:belwork/models/chat_model.dart';
import 'package:belwork/models/professional_profile_details_model.dart';
import 'package:belwork/screens/all_language_screen/all_language_screen.dart';
import 'package:belwork/screens/base_screen/about_us_screen/about_us_screen.dart';
import 'package:belwork/screens/base_screen/terms_and_conditions_screen/terms_and_conditions_screen.dart';
import 'package:belwork/screens/chat_screen/chat_screen/chat_screen.dart';
import 'package:belwork/screens/chat_screen/message_screen/message_screen.dart';
import 'package:belwork/screens/company_employee_screen/company_profile_edit_screen/company_profile_edit_screen.dart';
import 'package:belwork/screens/customer_screen/customer_evidence_screen/customer_evidence_screen.dart';
import 'package:belwork/models/task_evidence_response.dart';
import 'package:belwork/screens/technician_screen/technician_profile_edit_screen/technician_profile_edit_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/error_handling_screen/not_found_screen/not_found_screen.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/routes/internet_check_provider.dart';
import 'package:belwork/screens/app_navigation_screen/app_navigation_screen.dart';
import 'package:belwork/screens/auth/email_verificaton_screen/email_verificaiton_screen.dart';
import 'package:belwork/screens/auth/otp_verification_screen/otp_verification_screen.dart';
import 'package:belwork/screens/auth/reset_password_screen/reset_password_screen.dart';
import 'package:belwork/screens/auth/role_setting_screen/roll_setting_screen.dart';
import 'package:belwork/screens/auth/sign_in_screen/sign_in_screen.dart';
import 'package:belwork/screens/auth/sign_up_screen/sign_up_screen.dart';
import 'package:belwork/screens/auth/signup_otp_verification/signup_otp_verification.dart';
import 'package:belwork/screens/auth/verificaiton_screen/verification_screen.dart';
import 'package:belwork/screens/base_screen/language_screen/language_screen.dart';
import 'package:belwork/screens/base_screen/privacy_policy_screen/privacy_policy_screen.dart';
import 'package:belwork/screens/company_employee_screen/companay_submit_evidence_screen/company_submit_evidence_screen.dart';
import 'package:belwork/screens/company_employee_screen/company_agenda_screen/company_agenda_screen.dart';
import 'package:belwork/screens/company_employee_screen/company_profile_screen/company_profile_screen.dart';
import 'package:belwork/screens/customer_screen/customer_activity_evidence/customer_activity_evidence.dart';
import 'package:belwork/screens/customer_screen/customer_activity_screen/customer_activity_screen.dart';
import 'package:belwork/screens/customer_screen/customer_all_job_screen/customer_all_job_screen.dart';
import 'package:belwork/screens/customer_screen/customer_all_services/customer_all_service.dart';
import 'package:belwork/screens/customer_screen/customer_invoice_screen/customer_invoice_screen.dart';
import 'package:belwork/screens/customer_screen/customer_delete_account_screen/customer_delete_account_screen.dart';
import 'package:belwork/screens/customer_screen/customer_planner_screen/customer_planner_screen.dart';
import 'package:belwork/screens/customer_screen/customer_profile_edit/customer_profile_edit.dart';
import 'package:belwork/screens/customer_screen/customer_profile_screen/customer_profile_screen.dart';
import 'package:belwork/screens/customer_screen/customer_region_subsidy_grants/customer_region_subsidy_grants.dart';
import 'package:belwork/screens/customer_screen/customer_apeal_status/customer_appeal_status.dart';
import 'package:belwork/screens/customer_screen/customer_review_screen/customer_review_screen.dart';
import 'package:belwork/screens/customer_screen/customer_subscription_screen/customer_subscription_screen.dart';
import 'package:belwork/screens/customer_screen/customer_technician_list/customer_technician_list.dart';
import 'package:belwork/screens/customer_screen/customer_to_technician_profile/customer_to_technician_profile.dart';
import 'package:belwork/screens/customer_screen/customer_view_details/customer_view_details.dart';
import 'package:belwork/screens/customer_screen/technician_list/technician_list.dart';
import 'package:belwork/screens/splash_screen/splash_screen.dart';
import 'package:belwork/screens/technician_screen/technician_home_screen/technician_home_screen.dart';

import 'package:belwork/screens/technician_screen/technician_manage_screen/technician_manage_screen.dart';
import 'package:belwork/screens/technician_screen/technician_planner_screen/technician_planner_screen.dart';
import 'package:belwork/screens/technician_screen/technician_profile_screen/technician_profile_screen.dart';
import 'package:belwork/screens/technician_screen/technician_quation_to_customer_screen/technician_quotation_to_customer_screen.dart';
import 'package:belwork/screens/technician_screen/technician_submit_evidence/technician_submit_evidence.dart';
import 'package:belwork/utils/app_log.dart';
import 'package:belwork/models/technician_job_response.dart';
import 'package:go_router/go_router.dart';

import '../screens/customer_screen/customer_delete_accoutn_form/customer_delete_account_form.dart';
import '../screens/customer_screen/customer_edit_password/customer_edit_password.dart';
import '../screens/customer_screen/customer_home_screen/customer_home_screen.dart';
import '../screens/customer_screen/customer_planner_add_screen/customer_planner_add_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRoutes {
  ////////////// constructor
  AppRoutes._privateConstructor();
  static final AppRoutes _instance = AppRoutes._privateConstructor();
  static AppRoutes get instance => _instance;
  //////////////// routes

  GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    debugLogDiagnostics: kDebugMode,
    initialLocation: AppRoutesKey.instance.initial,
    routes: [
      GoRoute(
        path: AppRoutesKey.instance.initial,
        name: AppRoutesKey.instance.splash,
        builder: (context, state) => SplashScreen(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.languageScreen}",
        name: AppRoutesKey.instance.languageScreen,
        builder: (context, state) => LanguageScreen(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.signInScreen}",
        name: AppRoutesKey.instance.signInScreen,
        builder: (context, state) => SignInScreen(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.notFoundScreen}",
        name: AppRoutesKey.instance.notFoundScreen,
        builder: (context, state) => NotFoundScreen(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.rollSettingScreen}",
        name: AppRoutesKey.instance.rollSettingScreen,
        builder: (context, state) => RollSettingScreen(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.signUpScreen}",
        name: AppRoutesKey.instance.signUpScreen,
        builder: (context, state) => SignUpScreen(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.emailVerificationScreen}",
        name: AppRoutesKey.instance.emailVerificationScreen,
        builder: (context, state) => EmailVerificationScreen(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.otpVerificationScreen}",
        name: AppRoutesKey.instance.otpVerificationScreen,
        builder: (context, state) => OtpVerificationScreen(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.resetPasswordScreen}",
        name: AppRoutesKey.instance.resetPasswordScreen,
        builder: (context, state) => ResetPasswordScreen(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.appNavigationScreen}",
        name: AppRoutesKey.instance.appNavigationScreen,
        builder: (context, state) => AppNavigationScreen(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.customerHomeScreen}",
        name: AppRoutesKey.instance.customerHomeScreen,
        builder: (context, state) => CustomerHomeScreen(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.customerActivityScreen}",
        name: AppRoutesKey.instance.customerActivityScreen,
        builder: (context, state) => CustomerActivityScreen(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.customerPlannerScreen}",
        name: AppRoutesKey.instance.customerPlannerScreen,
        builder: (context, state) => CustomerPlannerScreen(),
      ),

      GoRoute(
        path: "/${AppRoutesKey.instance.customerProfileScreen}",
        name: AppRoutesKey.instance.customerProfileScreen,
        builder: (context, state) => CustomerProfileScreen(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.technicianHomeScreen}",
        name: AppRoutesKey.instance.technicianHomeScreen,
        builder: (context, state) => TechnicianHomeScreen(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.technicianManageScreen}",
        name: AppRoutesKey.instance.technicianManageScreen,
        builder: (context, state) => TechnicianManageScreen(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.technicianPlannerScreen}",
        name: AppRoutesKey.instance.technicianPlannerScreen,
        builder: (context, state) => TechnicianPlannerScreen(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.technicianProfileScreen}",
        name: AppRoutesKey.instance.technicianProfileScreen,
        builder: (context, state) => TechnicianProfileScreen(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.companyAgendaScreen}",
        name: AppRoutesKey.instance.companyAgendaScreen,
        builder: (context, state) => CompanyAgendaScreen(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.companyProfileScreen}",
        name: AppRoutesKey.instance.companyProfileScreen,
        builder: (context, state) => CompanyProfileScreen(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.customerTechnicianList}",
        name: AppRoutesKey.instance.customerTechnicianList,
        builder: (context, state) => CustomerTechnicianList(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.customerPlannerAddScreen}",
        name: AppRoutesKey.instance.customerPlannerAddScreen,
        builder: (context, state) => CustomerPlannerAddScreen(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.customerProfileEdit}",
        name: AppRoutesKey.instance.customerProfileEdit,
        builder: (context, state) => CustomerProfileEdit(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.customerEditPassword}",
        name: AppRoutesKey.instance.customerEditPassword,
        builder: (context, state) => CustomerEditPassword(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.customerDeleteAccountScreen}",
        name: AppRoutesKey.instance.customerDeleteAccountScreen,
        builder: (context, state) => CustomerDeleteAccountScreen(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.customerDeleteAccountForm}",
        name: AppRoutesKey.instance.customerDeleteAccountForm,
        builder: (context, state) => CustomerDeleteAccountForm(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.customerReviewScreen}",
        name: AppRoutesKey.instance.customerReviewScreen,
        builder: (context, state) => CustomerReviewScreen(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.customerActivityEvidence}",
        name: AppRoutesKey.instance.customerActivityEvidence,
        builder: (context, state) {
          final item = state.extra is TaskEvidenceItem
              ? state.extra as TaskEvidenceItem
              : null;
          return CustomerActivityEvidence(evidenceItem: item);
        },
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.customerInvoiceScreen}",
        name: AppRoutesKey.instance.customerInvoiceScreen,
        builder: (context, state) => CustomerInvoiceScreen(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.customerToTechnicianProfile}",
        name: AppRoutesKey.instance.customerToTechnicianProfile,
        builder: (context, state) {
          final professionalId = state.extra is String
              ? state.extra as String
              : (state.extra is Map &&
                        (state.extra as Map)['professionalId'] != null
                    ? (state.extra as Map)['professionalId'] as String
                    : null);
          return CustomerToTechnicianProfile(professionalId: professionalId);
        },
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.customerViewDetails}",
        name: AppRoutesKey.instance.customerViewDetails,
        builder: (context, state) {
          final project = state.extra is ProjectData
              ? state.extra as ProjectData
              : null;
          return CustomerViewDetails(project: project);
        },
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.customerAllJobScreen}",
        name: AppRoutesKey.instance.customerAllJobScreen,
        builder: (context, state) => const CustomerAllJobScreen(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.companySubmitEvidenceScreen}",
        name: AppRoutesKey.instance.companySubmitEvidenceScreen,
        builder: (context, state) {
          final jobId = state.extra as String?;
          return CompanySubmitEvidenceScreen(jobId: jobId);
        },
      ),

      GoRoute(
        path: "/${AppRoutesKey.instance.technicianSubmitEvidence}",
        name: AppRoutesKey.instance.technicianSubmitEvidence,
        builder: (context, state) {
          final jobId = state.extra as String?;
          return TechnicianSubmitEvidence(jobId: jobId);
        },
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.signupOtpVerification}",
        name: AppRoutesKey.instance.signupOtpVerification,
        builder: (context, state) => SignupOtpVerification(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.verificationScreen}",
        name: AppRoutesKey.instance.verificationScreen,
        builder: (context, state) => VerificationScreen(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.technicianQuotationToCustomerScreen}",
        name: AppRoutesKey.instance.technicianQuotationToCustomerScreen,
        builder: (context, state) {
          final item = state.extra as TechnicianJobItem?;
          return TechnicianQuotationToCustomerScreen(jobItem: item);
        },
      ),

      GoRoute(
        path: "/${AppRoutesKey.instance.customerAllService}",
        name: AppRoutesKey.instance.customerAllService,
        builder: (context, state) => CustomerAllService(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.technicianList}",
        name: AppRoutesKey.instance.technicianList,
        builder: (context, state) {
          if (state.extra is Map) {
            final map = state.extra as Map;
            return TechnicianList(
              categoryId: map['categoryId'] as String?,
              lat: map['lat'] as String?,
              lng: map['lng'] as String?,
              radiusKm: map['radiusKm'] as String?,
              category: map['category'] as String?,
            );
          } else if (state.extra is String) {
            return TechnicianList(categoryId: state.extra as String);
          }
          return const TechnicianList();
        },
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.customerRegionSubsidyGrants}",
        name: AppRoutesKey.instance.customerRegionSubsidyGrants,
        builder: (context, state) => const CustomerRegionSubsidyGrants(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.customerSubscriptionScreen}",
        name: AppRoutesKey.instance.customerSubscriptionScreen,
        builder: (context, state) => const CustomerSubscriptionScreen(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.privacyPolicyScreen}",
        name: AppRoutesKey.instance.privacyPolicyScreen,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),

      GoRoute(
        path: "/${AppRoutesKey.instance.customerAppealStatus}",
        name: AppRoutesKey.instance.customerAppealStatus,
        builder: (context, state) => const CustomerAppealStatus(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.allLanguageScreen}",
        name: AppRoutesKey.instance.allLanguageScreen,
        builder: (context, state) => const AllLanguageScreen(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.technicianProfileEditScreen}",
        name: AppRoutesKey.instance.technicianProfileEditScreen,
        builder: (context, state) => const TechnicianProfileEditScreen(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.companyProfileEditScreen}",
        name: AppRoutesKey.instance.companyProfileEditScreen,
        builder: (context, state) => const CompanyProfileEditScreen(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.messageScreen}",
        name: AppRoutesKey.instance.messageScreen,
        builder: (context, state) => const MessageScreen(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.termsAndConditionsScreen}",
        name: AppRoutesKey.instance.termsAndConditionsScreen,
        builder: (context, state) => const TermsAndConditionsScreen(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.aboutUsScreen}",
        name: AppRoutesKey.instance.aboutUsScreen,
        builder: (context, state) => const AboutUsScreen(),
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.customerEvidenceScreen}",
        name: AppRoutesKey.instance.customerEvidenceScreen,
        builder: (context, state) {
          final jobId = state.extra as String?;
          return CustomerEvidenceScreen(jobId: jobId);
        },
      ),
      GoRoute(
        path: "/${AppRoutesKey.instance.chatScreen}",
        name: AppRoutesKey.instance.chatScreen,
        builder: (context, state) {
          final user = state.extra is ChatUserModel
              ? state.extra as ChatUserModel
              : null;
          return ChatScreen(chatUser: user);
        },
      ),
    ],
    errorBuilder: (context, state) {
      return NotFoundScreen();
    },
    redirect: (context, state) {
      final container = ProviderScope.containerOf(context, listen: false);
      final asyncStatus = container.read(internetStatusProvider);

      if (asyncStatus.isLoading) return null;
      if (asyncStatus.hasError) return "/${AppRoutesKey.instance.errorScreen}";

      final isOnline = asyncStatus.value ?? true;
      final goingToNoInternet =
          state.name == AppRoutesKey.instance.noInternetScreen;

      if (!isOnline && !goingToNoInternet) {
        return "/${AppRoutesKey.instance.noInternetScreen}";
      }

      if (isOnline && goingToNoInternet) {
        return "/"; // initial route
      }

      return null;
    },
  );

  ////////////////////. route operation start
  String _normalize(String value) => value.startsWith("/") ? value : "/$value";

  void go(String value) {
    try {
      router.go(_normalize(value));
    } catch (e) {
      errorLog("goNamed", e);
    }
  }

  void goNamed(
    String value, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
    String? fragment,
  }) {
    try {
      router.goNamed(
        value,
        pathParameters: pathParameters,
        extra: extra,
        fragment: fragment,
        queryParameters: queryParameters,
      );
    } catch (e) {
      errorLog("goNamed", e);
    }
  }

  void replace(String value, {Object? extra}) {
    try {
      router.replace(_normalize(value), extra: extra);
    } catch (e) {
      errorLog("replaceNamed", e);
    }
  }

  void replaceNamed(
    String value, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
  }) {
    try {
      router.replaceNamed(
        value,
        pathParameters: pathParameters,
        extra: extra,
        queryParameters: queryParameters,
      );
    } catch (e) {
      errorLog("replaceNamed", e);
    }
  }

  Future<T?> push<T extends Object?>(
    String value, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
  }) async {
    try {
      return await router.push<T>(_normalize(value), extra: extra);
    } catch (e) {
      errorLog("push", e);
      return null;
    }
  }

  Future<T?> pushNamed<T extends Object?>(
    String value, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
  }) async {
    try {
      return await router.pushNamed<T>(
        value,
        pathParameters: pathParameters,
        extra: extra,
        queryParameters: queryParameters,
      );
    } catch (e) {
      errorLog("pushNamed", e);
      return null;
    }
  }

  void pushReplacement(String value, {Object? extra}) {
    try {
      router.pushReplacement(_normalize(value), extra: extra);
    } catch (e) {
      errorLog("pushReplacement", e);
    }
  }

  void pushReplacementNamed(
    String value, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
  }) {
    try {
      router.pushReplacementNamed(
        value,
        pathParameters: pathParameters,
        extra: extra,
        queryParameters: queryParameters,
      );
    } catch (e) {
      errorLog("pushReplacementNamed", e);
    }
  }

  void pop() {
    try {
      GoRouter.of(rootNavigatorKey.currentContext!).pop();
    } catch (e) {
      errorLog("pop", e);
    }
  }

  ////////////////////. route operation end
}
