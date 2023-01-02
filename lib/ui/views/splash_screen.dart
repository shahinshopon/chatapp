

import 'package:chatapp/const/app_strings.dart';
import 'package:chatapp/ui/route/route.dart';
import 'package:chatapp/ui/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  @override
  void initState() {
    Future.delayed(const Duration(seconds: 3), () => Get.toNamed(signUp));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FlutterLogo(
                size: 100.w,
              ),
              SizedBox(
                height: 10.h,
              ),
              Text(
                AppStrings.appName,
                style: AppStyles().myTextStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
