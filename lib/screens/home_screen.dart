
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nurses_todo_app/app_theme.dart';
import 'package:nurses_todo_app/controllers/database_services.dart';
import 'package:nurses_todo_app/models/resident_model.dart';
import 'package:nurses_todo_app/models/shift_model.dart';
import 'package:nurses_todo_app/models/todo_model.dart';
import 'package:nurses_todo_app/widgets/todo_widget.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
List<ShiftModel> shiftsNameList = [];
List<String> residentsNameList = [];
class _HomeScreenState extends State<HomeScreen> {

  DataBaseServices _dataBaseServices = DataBaseServices();

  final CollectionReference todosCollection = FirebaseFirestore.instance.collection('tasks');
  final CollectionReference shiftsCollection = FirebaseFirestore.instance.collection('shifts');
  final CollectionReference residentsCollection = FirebaseFirestore.instance.collection('residents');

  List<ToDo> _foundToDo = [];

  bool loading = false;


  List<ToDo> todoList = [];
  List<ShiftModel> shiftList = [];

  List<ResidentModel> residentsList = [];

  late ShiftModel ongoingShift;



  getData()async{
    setState(() {
      loading = true;
    });
    await _dataBaseServices.getAllShifts(shiftList);
    await getActiveShift();
    await _dataBaseServices.getAllResidents(residentsList);
    await _dataBaseServices.updateTasksShift(todoList, residentsList, shiftList, ongoingShift);
    // getAllTasks();
    setState(() {
      _foundToDo = todoList;
      loading = false;
    });
  }

  @override
  void initState() {
    getData();
    super.initState();
  }






  @override
  Widget build(BuildContext context) {


    final loadingWidget = (Platform.isAndroid)
        ? const CircularProgressIndicator(
      color: AppTheme.tdBlack,
    )
        : const CupertinoActivityIndicator(
      color: AppTheme.tdBlack,
    );

    return Scaffold(
      floatingActionButton: Container(
        margin: const EdgeInsets.only(
          bottom: 20,
          right: 20,
        ),
        child: ElevatedButton(
          onPressed: () {
            openDialog();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.tdBlue,
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
      body: SafeArea(
        child: Stack(
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
                        for (ToDo todoo in _foundToDo)
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
            if (loading)
              Container(
                  height: double.infinity,
                  width: double.infinity,
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: loadingWidget,
                  ))
          ],
        ),
      ),
    );
  }

  void _handleToDoChange(ToDo todo) async{
    await todosCollection.doc(todo.id).set({
      'task': todo.todoText,
      'done': !todo.isDone,
      'resident-id': todo.residentId,
      'shift-id': todo.shiftId,
    }).then((doc) =>  ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Task Marked Done Successfully"))));
    setState(() {

      todo.isDone = !todo.isDone;
    });
  }

  void _deleteToDoItem(String id) {
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





  getActiveShift(){
    DateTime timeNow = DateTime.now();
    if((timeNow.hour > 6  || (timeNow.hour == 6 &&  timeNow.minute > 30)) && (timeNow.hour < 14) ){
      ongoingShift =shiftList[2];
    }else if((timeNow.hour > 14) && (timeNow.hour < 21 ||(timeNow.hour == 21 && timeNow.minute < 30)) ){
      ongoingShift =shiftList[1];
    }else{
      ongoingShift =shiftList[0];
    }
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
  Future openDialog() => showDialog(
      context: context,
      builder: (context) {
        final TextEditingController taskDescription = TextEditingController();

        String? shiftName;
        String? residentName;
        late ShiftModel shift;
        late ResidentModel resident;
        List<String?> items = ['night shift','evening shift','morning shift',];
        return StatefulBuilder(
          builder:(BuildContext context, StateSetter setState){
             return Dialog(
              elevation: 2,
              backgroundColor: AppTheme.tdBGColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Task Details',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      bottom: 20,
                      right: 20,
                      left: 20,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 0.0),
                          blurRadius: 10.0,
                          spreadRadius: 0.0,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: taskDescription,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(0),
                        prefixIconConstraints: BoxConstraints(
                          maxHeight: 20,
                          minWidth: 25,
                        ),
                        border: InputBorder.none,
                        hintText: 'Task Description',
                        hintStyle: TextStyle(color: AppTheme.tdGrey),
                      ),
                    ),
                  ),
                  Container(
                      margin: const EdgeInsets.only(
                        bottom: 20,
                        right: 20,
                        left: 20,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0.0, 0.0),
                            blurRadius: 10.0,
                            spreadRadius: 0.0,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                            style: const TextStyle(color: AppTheme.tdBlack),
                            hint: const Text('Select shift',
                                style: TextStyle(color: AppTheme.tdGrey)),
                            iconSize: 35,
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: AppTheme.tdBlack,
                            ),
                            value: shiftName,
                            isExpanded: true,
                            items: items
                                .map<DropdownMenuItem<String>>((String? value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text('\t \t \t \t ${value!}'),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() {
                              shiftName = value;
                                  shift = shiftList.firstWhere(
                                      (element) => element.name == value);
                                  if (value == 'evening shift') {
                                    shift = shiftList[1];
                                  }
                                  if (value == 'night shift') {
                                    shift = shiftList[0];
                                  }
                                  if (value == 'morning shift') {
                                    shift = shiftList[2];
                                  }
                                })),
                      )),
                  Container(
                      margin: const EdgeInsets.only(
                        bottom: 20,
                        right: 20,
                        left: 20,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0.0, 0.0),
                            blurRadius: 10.0,
                            spreadRadius: 0.0,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                            style: const TextStyle(color: AppTheme.tdBlack),
                            hint: const Text('Select Resident',
                                style: TextStyle(color: AppTheme.tdGrey)),
                            iconSize: 35,
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: AppTheme.tdBlack,
                            ),
                            value: residentName,
                            isExpanded: true,
                            items: residentsNameList
                                .map<DropdownMenuItem<String>>((String? value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text('\t \t \t \t ${value!}'),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() {
                              residentName = value;
                                  resident = residentsList.firstWhere(
                                      (element) => element.name == value);
                                  if (value == 'evening shift') {
                                    shift = shiftList[1];
                                  }
                                  if (value == 'night shift') {
                                    shift = shiftList[0];
                                  }
                                  if (value == 'morning shift') {
                                    shift = shiftList[2];
                                  }
                                })),
                      )),
                  SizedBox(
                      height: 45,
                      width: 150,
                      child: ElevatedButton(
                        onPressed: () async {
                          final task = <String, dynamic>{
                            "done": false,
                            "resident-id": resident.id,
                            "shift-id": shift.id,
                            "task": taskDescription.text,
                          };
                          await _dataBaseServices.updateTodo(context, task);
                          await _dataBaseServices.getAllTasks(todoList, residentsList, ongoingShift);
                          Navigator.pop(context);
                        },
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                AppTheme.tdBlue)),
                        child: const Text('Create Task'),
                      )),
                ],
              ),
            );
          },
        );
      }
  );
  //
}