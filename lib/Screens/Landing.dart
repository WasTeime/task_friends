import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_friends/Domain/AuthUser.dart';
import 'package:task_friends/Screens/Auth.dart';
import 'package:task_friends/Screens/Navigation.dart';

class LandingPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final AuthUser? authUser = Provider.of<AuthUser?>(context);
    final bool isLoggedIn = authUser != null;

    if (isLoggedIn) {
      return Navigation();
    }
    else {
      return AuthorizationPage();
    }
  }
}