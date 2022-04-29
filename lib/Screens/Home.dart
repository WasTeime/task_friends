import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_friends/Domain/AuthUser.dart';

class HomePage extends StatefulWidget{
  @override
  _HomePageState createState() => _HomePageState();
}

_getTaskFriend(mailSelectedFriend) async{
  var f = await FirebaseFirestore.instance.collection('Users').doc(mailSelectedFriend).get().then((doc) => doc.get('shownTuskInCooperativeMode'));
  return f;
}

class _HomePageState extends State<HomePage>{
  var _selectedFriend, _mailSelectedFriend;
  var _currentUserTask = 'Выберите задачу';

  @override
  Widget build(BuildContext context) {
    //TODO: должна появляться первая задача если никакая не выбрана
    final AuthUser? authUser = Provider.of<AuthUser?>(context, listen: false);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              margin: EdgeInsets.all(5),
              //color: Colors.green,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  //Текущий пользователь
                  Card(
                    color: Colors.blueAccent,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 35,
                      child: Center(
                        //TODO: вместо пользователей показывать ник или почту
                        child: Text('Задача ${authUser!.nickName}', style: TextStyle(fontSize: 20, color: Colors.white),),
                      ),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                    color: Colors.blueAccent,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 35,
                      child: ElevatedButton(
                        onPressed: (){
                          showDialog(context: context, builder: (BuildContext context){
                            return AlertDialog(
                              title: Center(child: Text('Задачи')),
                              content: SingleChildScrollView(
                                child: Container(
                                  width: 100,
                                  height: 200,
                                  child: StreamBuilder(
                                    stream: FirebaseFirestore.instance.collection('Users').doc(authUser?.email).collection('Tasks').snapshots(),
                                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                                      if (!snapshot.hasData) return Text('');
                                      return ListView.builder(
                                        itemCount: snapshot.data?.docs.length,
                                        itemBuilder: (context, i){
                                          return ListTile(
                                            title: ElevatedButton(
                                              style: ButtonStyle(
                                                backgroundColor: MaterialStateProperty.all(
                                                  Colors.indigoAccent.shade100
                                                )
                                              ),
                                              onPressed: () async{
                                                FirebaseFirestore.instance.collection('Users').doc(authUser?.email).update({'shownTuskInCooperativeMode': snapshot.data?.docs[i].get('title')});
                                                _currentUserTask = await FirebaseFirestore.instance.collection('Users').doc(authUser?.email).get().then((doc) => doc.get('shownTuskInCooperativeMode'));
                                                /*
                                                _idCurrentUserTask = snapshot.data?.docs[i].id;
                                                _currentUserTask = await FirebaseFirestore.instance.collection('Users').doc(authUser?.email).collection('Tasks').doc(_idCurrentUserTask).get().then((doc) => doc.data()!['title']);
                                                setState(() => _currentUserTask);
                                                print(_currentUserTask);
                                                 */
                                                setState(() => _currentUserTask);
                                                Navigator.of(context).pop();
                                              },
                                              child: Text(snapshot.data?.docs[i].get('title'), style: TextStyle(fontSize: 17),),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              )
                            );
                          });
                          /*
                          TODO: в качестве начального значения кнопки выбирается текущая задача
                          TODO: 1) при нажатии на кнопку появляется контекстное меню (alertDialog)
                          TODO:    и предлагает выбрать задачу
                          TODO: 2) при нажатии на задачу в контекстном меню она должна появиться на кнопке
                          TODO: 3) при нажатии кнопки добавить друга:
                          TODO:    3.1) нам надо взять его текущую задачу
                          TODO:    3.2) также предоставить выбор задачи по нажатию кнопки
                           */
                        },
                        child: Text('${_currentUserTask}', style: TextStyle(fontSize: 17),),
                      ),
                    ),
                  ),
                  //Друг
                  Card(
                    margin: EdgeInsets.only(top: 35, left: 5, right: 5, bottom: 5),
                    color: Colors.blueAccent,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 35,
                      child: Center(
                        //TODO: вместо пользователей показывать ник или почту
                        child: Text('Задача ${_selectedFriend == null ? 'друга' : _selectedFriend}', style: TextStyle(fontSize: 20, color: Colors.white),),
                      ),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                    color: Colors.blueAccent,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 35,
                      /*
                      FutureBuilder(
                        future: _getTaskFriend(_mailSelectedFriend),
                        builder: (context, snapshot){
                          return Center(
                            child: Text('${snapshot.data}', style: TextStyle(fontSize: 17, color: Colors.white)),
                          );
                        },
                      )
                       */
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance.collection('Users').snapshots(),
                        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
                          return ListView.builder(
                            itemCount: snapshot.data?.size,
                            itemBuilder: (context, i){
                              if (snapshot.data?.docs[i].id == _mailSelectedFriend){
                                if (snapshot.data?.docs[i].get('shownTuskInCooperativeMode') == null){
                                  return Center(
                                    child: Text('Пока пусто', style: TextStyle(fontSize: 17, color: Colors.white)),
                                  );
                                }
                                return Center(
                                  child: Text('${snapshot.data?.docs[i].get('shownTuskInCooperativeMode')}', style: TextStyle(fontSize: 17, color: Colors.white)),
                                );
                              }
                              return SizedBox();
                            },
                          );
                        },
                      )
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              margin: EdgeInsets.only(left: 5, right: 5, bottom: 5),
              //color: Colors.red,
              child: Row(
                children: [
                  //Контейнер текущего пользователя
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    width: 150,
                    height: MediaQuery.of(context).size.height,
                    color: Colors.grey,
                  ),
                  //Контейнер друга
                  Container(
                      margin: EdgeInsets.only(bottom: 10, top: 10, left: 10),
                      width: 150,
                      height: MediaQuery.of(context).size.height,
                      color: Colors.grey,
                      child: IconButton(
                        iconSize: 40,
                        onPressed: (){
                          //TODO: 2) после нажатия на выбранного друга мы загружаем его текущую задачу
                          //Появляющееся меню с друзьями при нажатии на '+'
                          showDialog(context: context, builder: (BuildContext context){
                            return AlertDialog(
                                title: Center(child: Text('Друзья')),
                                content: SingleChildScrollView(
                                  child: Container(
                                    width: 100,
                                    height: 200,
                                    child: FutureBuilder(
                                        future: FirebaseFirestore.instance.collection('Users').doc(authUser?.email).get().then((DocumentSnapshot documentSnapshot) {
                                          Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
                                          return data['friends'];
                                        },
                                        ),
                                        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot){
                                          if (snapshot.data == null){
                                            return Container(
                                              child: Text('Loading...'),
                                            );
                                          }
                                          else{
                                            return ListView.builder(
                                                itemCount: snapshot.data.length,
                                                itemBuilder: (BuildContext context, int i){
                                                  return ListTile(
                                                      title: ElevatedButton(
                                                        style: ButtonStyle(
                                                            backgroundColor: MaterialStateProperty.all(
                                                                Colors.green.shade300
                                                            )
                                                        ),
                                                        onPressed: () async{
                                                          //TODO: не сохраняется состояние при переходе на другие вкладки
                                                          //_selectedFriend = snapshot.data[i];
                                                          _selectedFriend = await FirebaseFirestore.instance.collection('Users').doc(snapshot.data[i]).get().then((doc) => doc.data()!['nickName']);
                                                          _mailSelectedFriend = FirebaseFirestore.instance.collection('Users').doc(snapshot.data[i]).id;
                                                          //_selectedTaskFriend = await FirebaseFirestore.instance.collection('Users').doc(_mailSelectedFriend).get().then((doc) => doc.get('shownTuskInCooperativeMode'));
                                                          setState(() => _selectedFriend);
                                                          //setState(() => _selectedTaskFriend);

                                                          Navigator.of(context).pop();
                                                        },
                                                        child: Text(snapshot.data?[i]),
                                                      )
                                                  );
                                                }
                                            );
                                          }
                                        }
                                    ),
                                  ),
                                )
                            );
                          });
                        },
                        icon: Icon(
                            Icons.add
                        ),
                      )
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}