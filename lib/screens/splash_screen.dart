import 'dart:developer';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:messaju/api/apis.dart';
import 'package:messaju/screens/auth/login_screen.dart';
import 'package:messaju/screens/home_screen.dart';
import '../../main.dart';
//import 'package:messaju/screens/home_screen.dart';
//splash screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 3000),(){
      //fullscreen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(systemNavigationBarColor: Colors.white,statusBarColor: Colors.white));

        if (APIs.auth.currentUser != null){
          log('\nUser: ${APIs.auth.currentUser}');
           //log('\nUserAdditionalInfo: ${FirebaseAuth.instance.currentUser.additionalUserInfo}');
                //homescreen navigation
              Navigator.pushReplacement(context,MaterialPageRoute(builder:(_) => const HomeScreen()));
        }
        else{
                //loginscreen navigation
            Navigator.pushReplacement(context,MaterialPageRoute(builder:(_) => const LoginScreen()));
        }


      
    });
  }

  @override
  Widget build(BuildContext context) {
    mq =MediaQuery.of(context).size;
    return  Scaffold(
      //appbar
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Welcome To Messeju'),
      ),
      body: Stack(children: [
      
        Positioned(
          top: mq.height *.15,
          width:mq.width *.5,
          right:mq.width*.25,
          
          child: Image.asset('images/chat.png')),
        Positioned(
          bottom: mq.height *.15,
          width:mq.width *.9,
          left: mq.width*.05,
          height: mq.height *.07,
          child: const Text("Made By Me 😒",
          textAlign:TextAlign.center,
          style:TextStyle(color:Colors.black,fontSize: 20,letterSpacing: 2)))
      ]),
      );
  }
}