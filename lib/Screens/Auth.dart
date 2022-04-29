import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../Domain/AuthUser.dart';
import '../Services/Auth.dart';

class AuthorizationPage extends StatefulWidget{
  @override
  _AuthorizationPageState createState() => _AuthorizationPageState();
}

class _AuthorizationPageState extends State<AuthorizationPage>{
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passController = TextEditingController();
  TextEditingController _nickNameController = TextEditingController();

  String? _email;
  String? _password;
  String? _nickName;
  bool showLogin = true;

  AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    Widget _logo(){
      return Padding(
        padding: EdgeInsets.only(top: 100),
        child: Container(
          child: Align(
              child: Text('TaskFriends', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),)
          ),
        ),
      );
    }

    Widget _input(Icon icon, String hint, TextEditingController controller, bool obscure){
      return Container(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: TextField(
          controller: controller,
          obscureText: obscure,
          style: TextStyle(fontSize: 20, color: Colors.white),
          decoration: InputDecoration(
              hintStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white30),
              hintText: hint,
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 3)
              ),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54, width: 1)
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: IconTheme(
                  data: IconThemeData(color: Colors.white),
                  child: icon,
                ),
              )
          ),
        ),
      );
    }

    Widget _button(String text, void func()){
      return Container(
        width: MediaQuery.of(context).size.width - 35,
        height: 40,
        child: ElevatedButton(
            onPressed: (){
              func();
            },
            child: Text(text, style: TextStyle(fontSize: 20),)
        ),
      );
    }

    Widget _form(String label, void func(), bool showNickName){
      return Container(
        child: Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(bottom: 20, top: 10),
                child: _input(Icon(Icons.email), 'EMAIL', _emailController, false)
            ),
            Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: _input(Icon(Icons.lock), 'PASSWORD', _passController, true)
            ),
            if (showNickName)
              Padding(
                  padding: EdgeInsets.only(bottom: 30),
                  child: _input(Icon(Icons.account_box), 'NICKNAME', _nickNameController, false)
              ),
            _button(label, func),
          ],
        ),
      );
    }

    void _loginAuthorisationUser() async {
      _email = _emailController.text;
      _password = _passController.text;

      if (_email!.isEmpty || _password!.isEmpty) return;

      AuthUser? authUser = await _authService.signInWithEmailAndPassword(_email!.trim(), _password!.trim());
      if (authUser == null){
        Fluttertoast.showToast(
            msg: "Can't SignIn you! Please check your email or password",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
      else {
        _emailController.clear();
        _passController.clear();
      }
    }

    void _registerAuthorisationUser() async {
      _email = _emailController.text;
      _password = _passController.text;
      _nickName = _nickNameController.text;

      if (_email!.isEmpty || _password!.isEmpty || _nickName!.isEmpty) {
        Fluttertoast.showToast(
            msg: "Can't Register you! Please check your email or password or nickName",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
        return;
      };

      AuthUser? authUser = await _authService.registerInWithEmailAndPassword(_email!.trim(), _password!.trim());
      await FirebaseAuth.instance.currentUser?.updateDisplayName(_nickName);
      if (authUser == null){
        Fluttertoast.showToast(
            msg: "Can't Register you! Please check your email or password",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
      else {
        FirebaseFirestore.instance.collection('Users').doc(authUser!.email).set(
            {
              'shownTuskInCooperativeMode': '',
              'nickName': _nickName,
              'userId': authUser!.id,
              'friends': [],
            });
        _emailController.clear();
        _passController.clear();
        _nickNameController.clear();
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _logo(),
            (
                showLogin
                    ? Column(
                  children: <Widget> [
                    _form('LOGIN', _loginAuthorisationUser, false),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: GestureDetector(
                        child: Text('Not registered yet? Register', style: TextStyle(fontSize: 20, color: Colors.white),),
                        onTap: (){
                          setState(() {
                            showLogin = false;
                          });
                        },
                      ),
                    )
                  ],
                )
                    :
                Column(
                  children: <Widget> [
                    _form('Register', _registerAuthorisationUser, true),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: GestureDetector(
                        child: Text('Already registered? Login', style: TextStyle(fontSize: 20, color: Colors.white),),
                        onTap: (){
                          setState(() {
                            showLogin = true;
                          });
                        },
                      ),
                    )
                  ],
                )
            )
          ],
        ),
      ),
    );
  }
}