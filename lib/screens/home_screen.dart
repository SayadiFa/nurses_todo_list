import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nurses_todo_app/app_theme.dart';
import 'package:nurses_todo_app/controllers/database_services.dart';
import 'package:nurses_todo_app/models/shift_model.dart';
import 'package:nurses_todo_app/models/todo_model.dart';
import 'package:nurses_todo_app/widgets/todo_widget.dart';
import 'package:provider/provider.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<ToDo> _foundToDo = [];
  final _todoController = TextEditingController();


  List<ToDo> todoList = [];
  List<ShiftModel> shiftList = [];
  late ShiftModel ongoingShift;
  getAllShifts()async{
    final CollectionReference shiftsCollection = FirebaseFirestore.instance.collection('shifts');
    await shiftsCollection.get().then((event) {
      for (var doc in event.docs) {
        final data = doc.data() as Map<String, dynamic>;
        // print("${doc.id} => ${doc.data()}");
        shiftList.add(
            ShiftModel(
              id: doc.id,
              name: data['name'],
              from: data['from'],
              to: data['to'],
            )
        );
      }
    });
    getShift();
    getAllTasks();
    setState(() {

    });
  }

  getAllTasks()async{

    todoList = [];
    final CollectionReference todosCollection = FirebaseFirestore.instance.collection('tasks');
    await todosCollection.where("shift-id", isEqualTo: ongoingShift.id).get().then((event) {
      for (var doc in event.docs) {
        final data = doc.data() as Map<String, dynamic>;
        todoList.add(
            ToDo(
                id: doc.id,
                todoText: data['task'],
                isDone: data['done'],
                residentId: data['resident-id'],
                shiftId: data['shift-id']
            )
        );
      }
    });
    setState(() {

    });
  }

  @override
  void initState() {
    getAllShifts();
    // getShift();
    // getAllTasks();
    super.initState();
  }






  @override
  Widget build(BuildContext context) {

    return Scaffold(
      floatingActionButton: Container(
        margin: const EdgeInsets.only(
          bottom: 20,
          right: 20,
        ),
        child: ElevatedButton(
          onPressed: () {
            // _addToDoItem(_todoController.text);
            getAllShifts();
          },
          style: ElevatedButton.styleFrom(
            primary: AppTheme.tdBlue,
            minimumSize: const Size(60, 60),
            elevation: 10,
          ),
          child: const Text(
            '+',
            style: TextStyle(
              fontSize: 40,
            ),
          ),
        ),
      ),
      backgroundColor: AppTheme.tdBGColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            child: Column(
              children: [
                searchBox(),
                Expanded(
                  child: ListView(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(
                          top: 50,
                          bottom: 20,
                        ),
                        child: const Text(
                          'All ToDos',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      for (ToDo todoo in todoList)
                        ToDoWidget(
                          todo: todoo,
                          onToDoChanged: _handleToDoChange,
                          onDeleteItem: _deleteToDoItem,
                        ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleToDoChange(ToDo todo) async{
    final CollectionReference todoCollection = FirebaseFirestore.instance.collection('tasks');
    await todoCollection.doc(todo.id).set({
      'task': todo.todoText,
      'done': !todo.isDone,
      'resident-id': todo.residentId,
      'shift-id': todo.shiftId,
    });
    setState(() {

      todo.isDone = !todo.isDone;
    });
  }

  void _deleteToDoItem(String id) {
    final CollectionReference todosCollection = FirebaseFirestore.instance.collection('tasks');
    todosCollection.doc(id).delete().then(
          (doc) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Task Deleted Successfully")));
          },
      onError: (e) => print("Error updating document $e"),
    );
    setState(() {
      todoList.removeWhere((item) => item.id == id);
    });
  }

  void _addToDoItem(String toDo) {
    setState(() {
      todoList.add(ToDo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        todoText: toDo,
      ));
    });
    _todoController.clear();
  }

  void _runFilter(String enteredKeyword) {
    List<ToDo> results = [];
    if (enteredKeyword.isEmpty) {
      results = todoList;
    } else {
      results = todoList
          .where((item) => item.todoText!
          .toLowerCase()
          .contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundToDo = results;
    });
  }

  getShift(){
    DateTime timeNow = DateTime.now();
    if((timeNow.hour > 6  || (timeNow.hour == 6 &&  timeNow.minute > 30)) && (timeNow.hour < 14) ){
      ongoingShift =shiftList[2];
    }else if((timeNow.hour > 14) && (timeNow.hour < 21 ||(timeNow.hour == 21 && timeNow.minute < 30)) ){
      ongoingShift =shiftList[1];
    }else{
      ongoingShift =shiftList[0];
    }
    setState(() {

    });
  }

  Widget searchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        onChanged: (value) => _runFilter(value),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(0),
          prefixIcon: Icon(
            Icons.search,
            color: AppTheme.tdBlack,
            size: 20,
          ),
          prefixIconConstraints: BoxConstraints(
            maxHeight: 20,
            minWidth: 25,
          ),
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: TextStyle(color: AppTheme.tdGrey),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.tdBGColor,
      elevation: 0,
      actions: [
        // InkWell(
        //   onTap: (){
        //
        //   },
        //   child: Row(
        //     children: const [
        //       Text('Add Resident', style: TextStyle(color: Colors.black),),
        //       Icon(Icons.add, color: AppTheme.tdBlack,)
        //
        //     ],
        //   ),
        // )
      ],
    );
  }
}