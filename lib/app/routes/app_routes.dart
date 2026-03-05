/// App Routes - Definisi semua route names
class AppRoutes {
  AppRoutes._();

  // Route paths
  static const String INITIAL = '/';
  static const String SPLASH = '/splash';
  static const String ONBOARDING = '/onboarding';
  
  // Auth
  static const String LOGIN = '/login'; // Main login (2 button)
  static const String LOGIN_FORM = '/login-form'; // Form login
  static const String REGISTER = '/register'; // Form register
  static const String FORGOT_PASSWORD = '/forgot-password';
  static const String VERIFY_OTP = '/verify-otp';
  static const String RESET_PASSWORD = '/reset-password';
  static const UPDATE_PASSWORD = '/update-password';
  
  // Main
  static const String HOME = '/home';
  static const String PROFILE = '/profile';
  static const String SETTINGS = '/settings';
  
  // Complaint
  static const String COMPLAINT_LIST = '/complaint-list';
  static const String COMPLAINT_DETAIL = '/complaint-detail';
  static const String COMPLAINT_CREATE = '/complaint-create';
  static const String COMPLAINT_STATUS = '/complaint-status';
  
  // ✅ PENGADUAN (BARU - TAMBAHKAN 2 ROUTE INI)
  static const String FORM_PENGADUAN = '/form-pengaduan';
  static const String PENGADUAN_SUCCESS = '/pengaduan-success';
  static const RIWAYAT_PENGADUAN = '/riwayat-pengaduan';
  static const DETAIL_KASUS = '/detail-kasus';

  // Legal Info
  static const String LEGAL_INFO = '/legal-info';
  static const String LEGAL_DETAIL = '/legal-detail';
  
  // Paralegal
  static const String PARALEGAL_LIST = '/paralegal-list';
  static const String PARALEGAL_CHAT = '/paralegal-chat';


  // Other
  static const String NOTIFICATION = '/notification';
  static const String HELP = '/help';
  static const String ABOUT = '/about';
  static const String TERMS = '/terms';
  static const String PRIVACY = '/privacy';
}