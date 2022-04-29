import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_friends/Domain/AuthUser.dart';

class TasksPage extends StatefulWidget{
  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage>{
  List <String> tasks = [];
  String? _userNameTask = '', _userDescriptionTask = '';
  TextEditingController _controllerNameTask = TextEditingController();
  TextEditingController _controllerDescriptionTask = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final AuthUser? authUser = Provider.of<AuthUser?>(context, listen: false);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                width: MediaQuery.of(context).size.width,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.lightBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text('Текущие задачи', style: TextStyle(fontSize: 25, color: Colors.white),),
                )
            ),
          ),
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection('Users').doc(authUser?.email).collection('Tasks').snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
              if (!snapshot.hasData) return Expanded(
                flex: 6,
                child: Container(
                  child: Center(
                    child: Text('Нет задач', style: TextStyle(fontSize: 20)),
                  ),
                ),
              );
              return Expanded(
                flex: 6,
                child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    width: MediaQuery.of(context).size.width,
                    height: 380,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListView.builder(
                      itemCount: snapshot.data?.docs.length,
                      itemBuilder: (context, i){
                        return Dismissible(
                          background: Container(
                            color: Colors.green,
                          ),
                          secondaryBackground: Container(
                            color: Colors.red,
                          ),
                          key: Key(snapshot.data!.docs[i].id),
                          child: Card(
                            child: ElevatedButton(
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                      EdgeInsets.only(left: 10)
                                  ),
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.green.shade300
                                  )
                              ),
                              onPressed: (){
                                _controllerNameTask.text = snapshot.data?.docs[i].get('title');
                                _controllerDescriptionTask.text = snapshot.data?.docs[i].get('description');
                                showDialog(context: context, builder: (BuildContext context){
                                  return AlertDialog(
                                    title: Text('Изменить задачу'),
                                    content: SingleChildScrollView(
                                      child: Container(
                                        height: 200,
                                        child: Column(
                                          children: [
                                            TextField(
                                              controller: _controllerNameTask,
                                              decoration: InputDecoration(
                                                  hintText: 'Название задачи'
                                              ),
                                              maxLines: 2,
                                            ),
                                            TextField(
                                              controller: _controllerDescriptionTask,
                                              decoration: InputDecoration(
                                                  hintText: 'Описание задачи'
                                              ),
                                              maxLines: 5,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: (){
                                          FirebaseFirestore.instance.collection('Users').doc(authUser?.email).collection('Tasks').doc(snapshot.data?.docs[i].id).update({
                                            'userId': authUser?.id,
                                            'title' : _controllerNameTask.text,
                                            'description': _controllerDescriptionTask.text,
                                          });
                                          _userNameTask = _userDescriptionTask = '';
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Изменить'),
                                      ),
                                    ],
                                  );
                                });
                              },
                              child: ListTile(
                                title: Text(snapshot.data?.docs[i].get('title')),
                                trailing: IconButton(
                                  onPressed: (){
                                    FirebaseFirestore.instance.collection('Users').doc(authUser?.email).collection('Tasks').doc(snapshot.data?.docs[i].id).delete();
                                  },
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          onDismissed: (direction){
                            if (direction == DismissDirection.endToStart) {
                                FirebaseFirestore.instance.collection('Users').doc(authUser?.email).collection('Tasks').doc(snapshot.data?.docs[i].id).delete();
                              }
                            else {

                            }
                          },
                        );
                      },
                    )
                )
              );
            },
          ),
          Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              width: MediaQuery.of(context).size.width,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton(
                  onPressed: (){
                    showDialog(context: context, builder: (BuildContext context){
                      return AlertDialog(
                        title: Text('Добавить задачу'),
                        content: SingleChildScrollView(
                          child: Container(
                            height: 200,
                            child: Column(
                              children: [
                                TextField(
                                  onChanged: (String value){
                                    _userNameTask = value;
                                  },
                                  decoration: InputDecoration(
                                      hintText: 'Название задачи'
                                  ),
                                  maxLines: 2,
                                ),
                                TextField(
                                  onChanged: (String value){
                                    _userDescriptionTask = value;
                                  },
                                  decoration: InputDecoration(
                                      hintText: 'Описание задачи'
                                  ),
                                  maxLines: 5,
                                ),
                              ],
                            ),
                          ),
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: (){
                              FirebaseFirestore.instance.collection('Users').doc(authUser?.email).collection('Tasks').add({
                                'userId': authUser?.id,
                                'title' : _userNameTask,
                                'description': _userDescriptionTask,
                              });
                              _userNameTask = _userDescriptionTask = '';
                              Navigator.of(context).pop();
                            },
                            child: Text('Добавить'),
                          ),
                        ],
                      );
                    });
                  },
                  child: Text('Добавить задачу  +',style: TextStyle(fontSize: 20),)
              ),
            ),
          )
        ],
      ),
    );
  }
}