// ignore_for_file: must_be_immutable, use_key_in_widget_constructors

import 'package:chatapp/const/app_colors.dart';
import 'package:chatapp/logic/auth.dart';
import 'package:chatapp/ui/route/route.dart';
import 'package:chatapp/ui/styles/styles.dart';
import 'package:chatapp/ui/widgets/violetButton.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';


class SignUp extends StatelessWidget {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.only(left: 30.w, right: 30.w, top: 80.h),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Create\nYour Account",
                  style: TextStyle(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.violetColor,
                  ),
                ),
                SizedBox(
                  height: 12.h,
                ),
                Text(
                  "Create your account and start your journey......",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                SizedBox(
                  height: 80.h,
                ),
                TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  decoration: AppStyles().textFieldDecoration("Name"),
                ),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: AppStyles().textFieldDecoration("E-mail Address"),
                ),
                TextFormField(
                  controller: _passwordController,
                  keyboardType: TextInputType.text,
                  decoration: AppStyles().textFieldDecoration("Enter Password"),
                ),
                SizedBox(
                  height: 40.h,
                ),
                VioletButton(
                  "Create Account",
                  () => Auth().registration(
                    _nameController.text,
                      _emailController.text, _passwordController.text, context),
                ),
                SizedBox(
                  height: 10.h,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "--OR--",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
               
                SizedBox(
                  height: 10.h,
                ),
                RichText(
                  text: TextSpan(
                    text: "Already an user?  ",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w300,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                        text: "Log In",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.violetColor,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Get.toNamed(signIn),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
