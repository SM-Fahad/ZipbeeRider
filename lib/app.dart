import 'package:ZipBee_Driver/core/bindings/controller_binder.dart';
import 'package:ZipBee_Driver/core/utils/app_route_observer.dart';
import 'package:ZipBee_Driver/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

class Nicholaslim extends StatelessWidget {
  const Nicholaslim({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          builder: EasyLoading.init(),
          initialRoute: AppRoutes.getSplashScreen(), // Main Route
          // initialRoute: AppRoutes.googleMapScreen, // for testing map
          getPages: AppRoutes.routes,
          initialBinding: ControllerBinder(),
          navigatorObservers: [appRouteObserver],
          themeMode: ThemeMode.system,
        );
      },
    );
  }
}
