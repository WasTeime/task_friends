import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:task_friends/Domain/AuthUser.dart';
import 'package:task_friends/Screens/Auth.dart';
import 'package:task_friends/Screens/Landing.dart';
import 'package:task_friends/Screens/Navigation.dart';
import 'package:task_friends/Services/Auth.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(TaskFriends());
}

class TaskFriends extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return StreamProvider<AuthUser?>.value (
        initialData: null,
        value: AuthService().currentUser,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              primaryColor: Colors.indigoAccent,
              textTheme: TextTheme(subtitle1: TextStyle(color: Colors.black))
          ),
          home: LandingPage(),
        )
    );
  }
}