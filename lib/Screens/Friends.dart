import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:task_friends/Domain/AuthUser.dart';

class FriendsPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _FriendPageState();
  }
}

class _FriendPageState extends State<FriendsPage>{

  TextEditingController _controller = TextEditingController();
  List<dynamic> friends = [];
  late Future<List<String>> dartFuture;

  @override
  void initState() {
    super.initState();
  }

  /*
  Future<List<String>?> _getFriends() async{
    FirebaseFirestore.instance.collection('Users').doc().get().then((DocumentSnapshot documentSnapshot) {
      Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
      friends = data['friends'];
      if (documentSnapshot.exists) {
        debugPrint('${friends.length}');
      }
      return friends;
    });
  }
   */

  @override
  Widget build(BuildContext context) {
    final AuthUser? authUser = Provider.of<AuthUser?>(context, listen: false);
    FirebaseFirestore.instance.collection('Users').doc(authUser?.email).get().then((DocumentSnapshot documentSnapshot) {
      Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
      friends = data['friends'];
    });
    return Container(
      child: Scaffold(
          body: ListView(
            children: [
              Card(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                      hintText: 'Find friend'
                  ),
                ),
              ),
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 7),
                  child: ElevatedButton(onPressed: () {
                    //TODO: при добавлении человека к себе в друзья, я тоже появляюсь у него в друзьях
                    //TODO: сделать оповещение о добавлении в друзья или что пользователь не найден
                    /*
                    var _currentUserTask = FirebaseFirestore.instance.collection('Users').doc(authUser?.email).collection('Tasks').snapshots();
    var f = _currentUserTask.distinct
                     */
                    if (authUser?.email == _controller.text){
                      Fluttertoast.showToast(
                          msg: "You want to find yourself",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.indigo,
                          textColor: Colors.white,
                          fontSize: 16.0
                      );
                    }
                    else{
                      FirebaseFirestore.instance.collection('Users').doc(_controller.text).get().then((DocumentSnapshot documentSnapshot) {
                        if (documentSnapshot.exists) {
                          if (friends.indexOf(_controller.text) == -1){
                            friends.add(_controller.text);
                            FirebaseFirestore.instance.collection('Users').doc(authUser?.email).update({'friends': friends});
                          }
                          else{
                            Fluttertoast.showToast(
                                msg: "This user is already your friend",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.indigo,
                                textColor: Colors.white,
                                fontSize: 16.0
                            );
                          }
                        }
                      });
                    }
                  }, child: Text('Find'))
              ),
              Expanded(
                flex: 3,
                child: Container(
                  width: 500,
                  height: 350,
                  child: FutureBuilder(
                      future: FirebaseFirestore.instance.collection('Users').doc(authUser?.email).get().then((DocumentSnapshot documentSnapshot) {
                        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
                        friends = data['friends'];
                        if (documentSnapshot.exists) {
                          debugPrint('${friends.length}');
                        }
                        return friends;
                      }),
                      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot){
                        if (snapshot.data == null){
                          return Container(
                            child: Text('Loading...'),
                          );
                        }
                        else{
                          return ListView.builder(
                              itemCount: snapshot.data?.length,
                              itemBuilder: (BuildContext context, int i){
                                return Card(
                                  child: ListTile(
                                    trailing: IconButton(
                                      onPressed: () {
                                        friends.remove(snapshot.data?[i]);
                                        FirebaseFirestore.instance.collection('Users').doc(authUser?.email).update({'friends': friends});
                                      },
                                      icon: Icon(
                                          Icons.delete
                                      ),
                                    ),
                                    title: Text(snapshot.data?[i]),
                                  ),
                                );
                              }
                          );
                        }
                      }
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      margin: EdgeInsets.only(right: 23, top: 22),
                      width: 50,
                      height: 50,
                      child: IconButton(
                        onPressed: () => setState(() {}),
                        icon: Icon(
                          Icons.refresh,
                        ),
                      ),
                    )
                ),
              )
            ],
          )
      ),
    );
  }
}