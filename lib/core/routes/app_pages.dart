import 'package:eplisio_go/core/routes/app_routes.dart';
import 'package:eplisio_go/features/auth/presentation/binding/auth_binding.dart';
import 'package:eplisio_go/features/auth/presentation/screen/auth_screen.dart';
import 'package:eplisio_go/features/auth/presentation/widgets/set_password_screen.dart';
import 'package:eplisio_go/features/client/presentation/binding/client_binding.dart';
import 'package:eplisio_go/features/client/presentation/screen/client_screen.dart';
import 'package:eplisio_go/features/clinic/presentation/binding/clinic_bindings.dart';
import 'package:eplisio_go/features/clinic/presentation/screen/clinic_screen.dart';
import 'package:eplisio_go/features/dashboard/presentation/binding/dashboard_binding.dart';
import 'package:eplisio_go/features/dashboard/presentation/screen/dashboard_screen.dart';
import 'package:eplisio_go/features/splash/presentation/binding/splash_binding.dart';
import 'package:eplisio_go/features/splash/presentation/screen/splash_screen.dart';
import 'package:get/get.dart';

class AppPages {
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),

    GetPage(
      name: Routes.DASHBOARD,
      page: () => DashboardScreen(),
      binding: DashboardBinding(),
    ),

    GetPage(
      name: Routes.LOGIN,
      page: () => const AuthScreen(),
      binding: AuthBinding(),
    ),

    GetPage(
      name: Routes.SETPASSWORD,
      page: () => const SetPasswordScreen(),
      binding: AuthBinding(),
    ),

    GetPage(
      name: Routes.CLIENT,
      page: () => const ClientsScreen(),
      binding: ClientsBinding(),
    ),

    GetPage(
      name: Routes.CLINIC,
      page: () => const HospitalsScreen(),
      binding: HospitalsBinding(),
    ),
    
  ];
}
