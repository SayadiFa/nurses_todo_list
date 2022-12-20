import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nurses_todo_app/models/shift_model.dart';
import 'package:nurses_todo_app/models/todo_model.dart';
import 'package:nurses_todo_app/screens/home_screen.dart';

import '../models/resident_model.dart';

class DataBaseServices {

  final String? uid;
  final String? taskId;
  DataBaseServices({this.uid, this.taskId});

  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference todosCollection = FirebaseFirestore.instance.collection('tasks');
  final CollectionReference shiftsCollection = FirebaseFirestore.instance.collection('shifts');
  final CollectionReference residentsCollection = FirebaseFirestore.instance.collection('residents');



  Future updateUser(String name) async {
    return await usersCollection.doc(uid).set({
      'name': name,
    });
  }
  Future updateTodo(BuildContext context,Map<String, dynamic> task) async {
    return await todosCollection.doc().set(task).onError((e, _) =>
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Couldn't add Task"))));
  }

  getAllTasks(List<ToDo> todoList,List<ResidentModel>  residentsList,  ShiftModel ongoingShift)async{

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
  }

  updateTasksShift(List<ToDo> todoList,List<ResidentModel>  residentsList,  List<ShiftModel> shiftList, ShiftModel ongoingShift) async{
    DateTime timeNow = DateTime.now();
    if((timeNow.hour > 6  || (timeNow.hour == 6 &&  timeNow.minute > 30)) && (timeNow.hour < 14) || (timeNow.hour == 6 &&  timeNow.minute == 30)){
      await todosCollection.where("done", isEqualTo:false).get().then((event) {
        for (var doc in event.docs) {
          final data = doc.data() as Map<String, dynamic>;
          todosCollection.doc(data['id']).update({
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
          todosCollection.doc(data['id']).update({
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
          todosCollection.doc(data['id']).update({
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

  Future getAllShifts(List<ShiftModel> shiftList, )async{

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

  getAllResidents(List<ResidentModel> residentsList)async{
    await residentsCollection.get().then((event) {
      for (var doc in event.docs) {
        final data = doc.data() as Map<String, dynamic>;
        print("${doc.id} => ${doc.data()}");
        residentsList.add(
            ResidentModel(
              id: doc.id,
              name: data['name'],
            )
        );
        residentsNameList.add(data['name']);
      }
    });
  }


}