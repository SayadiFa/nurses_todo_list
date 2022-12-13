
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nurses_todo_app/app_theme.dart';
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

  final CollectionReference todosCollection = FirebaseFirestore.instance.collection('tasks');
  final CollectionReference shiftsCollection = FirebaseFirestore.instance.collection('shifts');
  final CollectionReference residentsCollection = FirebaseFirestore.instance.collection('residents');

  List<ToDo> _foundToDo = [];

  bool loading = false;


  List<ToDo> todoList = [];
  List<ShiftModel> shiftList = [];

  List<Resident> residentsList = [];

  late ShiftModel ongoingShift;

  updateTasksShift() async{
    DateTime timeNow = DateTime.now();
    if((timeNow.hour > 6  || (timeNow.hour == 6 &&  timeNow.minute > 30)) && (timeNow.hour < 14) || (timeNow.hour == 6 &&  timeNow.minute == 30)){
      await todosCollection.where("done", isEqualTo:false).get().then((event) {
        for (var doc in event.docs) {
          final data = doc.data() as Map<String, dynamic>;
          todosCollection.doc(data['id']).set({
            'task': data['task'],
            'done': data['done'],
            'resident-id': data['resident-id'],
            'shift-id': shiftList.firstWhere((element) => element.name == "morning shift").id,
          });

          todoList.add(ToDo(
              id: doc.id,
              todoText: data['task'],
              isDone: data['done'],
              residentName: residentsList.firstWhere((element) => element.id==data['resident-id']).name,
              residentId: data['resident-id'],
              shiftId: data['shift-id']
          ));
        }
      });

      
    }else if(((timeNow.hour > 14) && (timeNow.hour < 21 ||(timeNow.hour == 21 && timeNow.minute < 30))) || (timeNow.hour == 14)){
      await todosCollection.where("done", isEqualTo:false).get().then((event) {
        for (var doc in event.docs) {
          final data = doc.data() as Map<String, dynamic>;
          todosCollection.doc(data['id']).set({
            'task': data['task'],
            'done': data['done'],
            'resident-id': data['resident-id'],
            'shift-id': shiftList.firstWhere((element) => element.name == "evening shift").id,
          });

          todoList.add(ToDo(
              id: doc.id,
              todoText: data['task'],
              isDone: data['done'],
              residentName: residentsList.firstWhere((element) => element.id==data['resident-id']).name,
              residentId: data['resident-id'],
              shiftId: data['shift-id']
          ));
        }
      });


    }else{
      await todosCollection.where("done", isEqualTo:false).get().then((event) {
        for (var doc in event.docs) {
          final data = doc.data() as Map<String, dynamic>;
          todosCollection.doc(data['id']).set({
            'task': data['task'],
            'done': data['done'],
            'resident-id': data['resident-id'],
            'shift-id': shiftList.firstWhere((element) => element.name == "night shift").id,
          });

          todoList.add(ToDo(
              id: doc.id,
              todoText: data['task'],
              isDone: data['done'],
              residentName: residentsList.firstWhere((element) => element.id==data['resident-id']).name,
              residentId: data['resident-id'],
              shiftId: data['shift-id']
          ));
        }
      });
    }
  }

  getData()async{
    await getAllShifts();
    await getActiveShift();
    getAllResidents();
    await updateTasksShift();
    // getAllTasks();
    setState(() {
      _foundToDo = todoList;
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


  getAllShifts()async{
    setState(() {
      loading = true;
    });

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
  }
  getAllResidents()async{
    await residentsCollection.get().then((event) {
      for (var doc in event.docs) {
        final data = doc.data() as Map<String, dynamic>;
        print("${doc.id} => ${doc.data()}");
        residentsList.add(
            Resident(
              id: doc.id,
              name: data['name'],
            )
        );
        residentsNameList.add(data['name']);
      }
    });
    setState(() {
      loading = false;
    });
  }
  getAllTasks()async{

    todoList = [];
    await todosCollection.where("shift-id", isEqualTo: ongoingShift.id).get().then((event) {
      for (var doc in event.docs) {
        final data = doc.data() as Map<String, dynamic>;
        todoList.add(
            ToDo(
                id: doc.id,
                todoText: data['task'],
                isDone: data['done'],
                residentName: residentsList.firstWhere((element) => element.id==data['resident-id']).name,
                residentId: data['resident-id'],
                shiftId: data['shift-id']
            )
        );
      }
    });
    setState(() {

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
  Future openDialog() => showDialog(
      context: context,
      builder: (context) {
        final TextEditingController taskDescription = TextEditingController();

        String? shiftName;
        String? residentName;
        late ShiftModel shift;
        late Resident resident;
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
                          await todosCollection.doc().set(task).onError((e, _) =>
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Couldn't Task"))));
                          await getAllTasks();
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