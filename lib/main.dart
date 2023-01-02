import 'package:chatapp/ui/route/route.dart';
import 'package:chatapp/ui/views/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   //name: "chatapp",
  //   options: const FirebaseOptions(
  //       apiKey: "AIzaSyDzdndc8nmCkP02ePKkIXD7xI87wtUjPLM",
  //       appId: "1:1055797851575:web:6de3a2bf64a1ce3540e432",
  //       messagingSenderId: "1055797851575",
  //       projectId: "chatapp-afdf7"),
  // );

  //await GetStorage.init();

  runApp(
    App(),
  );
}

class App extends StatelessWidget {
  // Create the initialization Future outside of `build`:
  final Future<FirebaseApp> _initialization = Firebase.initializeApp(
    name: "chatapp",
    options: const FirebaseOptions(
        apiKey: "AIzaSyDzdndc8nmCkP02ePKkIXD7xI87wtUjPLM",
        appId: "1:1055797851575:web:6de3a2bf64a1ce3540e432",
        messagingSenderId: "1055797851575",
        projectId: "chatapp-afdf7"),
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return const Center(child: CircularProgressIndicator());
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(428, 926),
      builder: (_, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.system,
          initialRoute: splash,
          getPages: getPages,
          home: SplashScreen(),
        );
      },
    );
  }
}
