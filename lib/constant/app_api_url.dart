import 'package:flutter/foundation.dart';
import 'package:belwork/utils/app_log.dart';

class AppApiUrl {
  AppApiUrl._privateConstructor();
  static final AppApiUrl _instance = AppApiUrl._privateConstructor();
  static AppApiUrl get instance => _instance;


  static final String _baseUrlFromEnv = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://topackubilaybackend.maktechapp.cloud',
  );

  static String _validateUrl(String url) {
    if (!kDebugMode && url.startsWith('http://')) {
      errorLog(
        'AppApiUrl',
        'HTTP (non-TLS) base URL blocked in release build. Use HTTPS.',
      );
      assert(false, 'Production builds must use HTTPS. Got: $url');
    }
    return url;
  }

  static final String domain = _validateUrl(_baseUrlFromEnv);
  static final String socket = _validateUrl(_baseUrlFromEnv);
  final String baseUrl = "$domain/";

  //////////////////////////////////  base
  String refreshToken = "/auth/reset-refresh-token";
  String userProfile = "/user/my-profile";
  String about =
      "/admin/side-content/about-us/4f4f6cc1-afaf-4bcf-aa73-187e9bd74e83";
  String privacyPolicy =
      "/admin/side-content/privacy-policy/00fe5e2c-a20f-40af-91c7-4d90b2511202";
  String termsAndConditions =
      "/admin/side-content/terms-and-condition/cc55902e-939a-42b5-a5cf-94f8c07038a1";
  String faq = "/faq";
  String notification = "/notification";
  ////////////
  String login = "auth/login";
  String googleLogin = "/auth/google";
  String appleLogin = "/auth/apple";
  String deviceToken = "/auth/device-token";
  String authDeleteAccount = "/authDeleteAccount";
  String user = "/auth/register";
  String changePassword = "/changePassword";
  String userResendOtp = "/auth/resend-email";
  String sendOtp = "/auth/send-otp";
  String authOtpVerify = "/auth/verify-opt";
  String updatePassword = "/auth/update-password";
  String authForgotPassword = "/authForgotPassword";
  String authVerifyEmail = "/auth/verify-email";
  String authResetPassword = "/authResetPassword";
  String resetPassword = "/auth/reset-password";
  String professionalAccountCreate = "/professional/account-create";
  String professionalVerifyEmail = "/professional/professional-verify-email";
  ////////////  customer home
  String allProfessionalsList = "/admin/dashboard/all-professionals-list";
  String professionalListByCategories =
      "/admin/dashboard/professional-list-by-categories";
  String allServiceCategoryList = "/admin/dashboard/all-service-category-list";
  String allSubsidies = "/admin/dashboard/all-subsidies";
  String nearestProfessionalsByCategory =
      "/user/nearest-professionals-by-category";
  String createJob = "/user/job";
  String yearlyInspection = "/user/all-tasks/yearly-inspection";
  String allJobList = "/user/all-job-list";
  String customerAllJobs = "/user/all-jobs";
  String allJobsProfessional = "/user/all-jobs-professional";
  String employeeAllJob(String employeeId) =>
      "/company/assigned/all-assigned-sites-by-employee/$employeeId";
  String get employeeProfile => "/company/dashboard/employee-profile";
  String updateProfile = "/user/update-profile";
  String professionalDetailsProfile(String professionalId) =>
      "/professional/details-profile/$professionalId";
  String companyServiceCategoryList = "/company/service-category-list";
  String companyServiceCategory = "/company/service-category";
  String professionalWorkListByDate(String professionalId) =>
      "/professional/$professionalId/work-list-by-date";
  String updateProfessionalAccount(String professionalId) =>
      "/professional/update-account/$professionalId";
  String sendMessage = "/user/message";
  String createJobProposal = "/professional/job-proposal";
  String postTaskEvidence = "/professional/task-evidence";
  String updateJobProposalStatus(String proposalId) =>
      "/professional/job-proposal/$proposalId/status";
  String getLastMessageList = "/user/messages/get-last-message-list";
  String getConversationMessages(String userId) => "/user/messages/$userId";
  String getUserById(String userId) => "/user/$userId";
  String createPaymentCheckout = "/user/create-payment-checkout";
  String commonReport = "/common/report";
  String updateIsReadStatus(String userId) => "/user/messages/update-isRead-status/$userId";
  String allTaskEvidenceByUser(String jobId) =>
      "/professional/all-task-evidence-by-user/$jobId";
  String postJobFeedback(String jobId) => "/user/jobs/$jobId/feedback";
  String postJobRevision(String jobId) => "/user/job-revision/$jobId";
}

