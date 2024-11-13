import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter_application_3/widget/widget_homescreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyA_OAmyr4w97XhsP5DaPBOJC3MfOFL7Vhg",
            authDomain: "doanchuyennganh-857ed.firebaseapp.com",
            projectId: "doanchuyennganh-857ed",
            storageBucket: "doanchuyennganh-857ed.firebasestorage.app",
            messagingSenderId: "970066316916",
            appId: "1:970066316916:web:59119d4fd10068f7e04b21",
            measurementId: "G-VFT86PCPV8"));
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WellcomeHomesreen(),
    );
  }
}
