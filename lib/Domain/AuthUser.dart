import 'package:firebase_auth/firebase_auth.dart';

class AuthUser{
  String? id;
  String? email;
  String? nickName;

  AuthUser.fromFirebase(User? user){
    id = user?.uid;
    email = user?.email;
    nickName = user?.displayName;
  }
}