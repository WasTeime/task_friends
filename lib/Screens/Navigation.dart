import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_friends/Domain/AuthUser.dart';
import 'package:task_friends/Screens/Friends.dart';
import 'package:task_friends/Screens/Home.dart';
import 'package:task_friends/Screens/Messages.dart';
import 'package:task_friends/Screens/Settings.dart';
import 'package:task_friends/Screens/Tasks.dart';
import 'package:task_friends/Services/Auth.dart';

class Navigation extends StatefulWidget{
  @override
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<Navigation>{
  int currentIndex = 0;
  final screens = [
    TasksPage(), MessagesPage(), HomePage(), FriendsPage(), SettingsPage()
  ];

  @override
  Widget build(BuildContext context) {
    final AuthUser? authUser = Provider.of<AuthUser?>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text (authUser!.nickName.toString()),
        actions: [
          IconButton(
            onPressed: (){
              FirebaseFirestore.instance.collection('Users').doc(authUser?.email).update({'shownTuskInCooperativeMode': null});
              AuthService().logOut();
            },
            icon: Icon(
                Icons.exit_to_app
            ),
          )
        ],
      ),
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.blue.shade50,
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.check_box),
              label: 'Tasks',
              backgroundColor: Colors.green
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.messenger),
              label: 'Messages',
              backgroundColor: Colors.indigoAccent
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
              backgroundColor: Colors.indigoAccent
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Friends',
              backgroundColor: Colors.indigoAccent
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
              backgroundColor: Colors.indigoAccent
          ),
        ],
      ),
    );
  }
}