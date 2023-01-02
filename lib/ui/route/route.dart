import 'package:chatapp/ui/views/auth/sign_in.dart';
import 'package:chatapp/ui/views/auth/sign_up.dart';
import 'package:chatapp/ui/views/home_screen.dart';
import 'package:chatapp/ui/views/splash_screen.dart';
import 'package:get/get.dart';

const String splash = '/splash-screen';
const String signUp = '/sign-up-screen';
const String signIn = '/sign-in-screen';
const String homeScreen = '/home-screen';
const String chatScreen = '/chat-screen';

//  control our page route flow

List<GetPage> getPages = [
  GetPage(
    name: splash,
    page: () => SplashScreen(),
  ),
  GetPage(
    name: signUp,
    page: () => SignUp(),
  ),
  GetPage(
    name: signIn,
    page: () => SignIn(),
  ),
  GetPage(
    name: homeScreen,
    page: () => const HomePage(),
  ),
];
