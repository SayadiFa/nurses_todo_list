import 'package:cloud_firestore/cloud_firestore.dart';

class ToDo {
  String? id;
  String? residentId;
  String? shiftId;
  String? todoText;
  bool isDone;

  ToDo({
    required this.id,
    required this.todoText,
    this.isDone = false,
    this.residentId,
    this.shiftId,
  });


  // factory ToDo.fromFirestore(
  //     DocumentSnapshot<Map<String, dynamic>> snapshot,
  //     SnapshotOptions? options,
  //     ) {
  //   final data = snapshot.data();
  //   return ToDo(
  //     id: data?['name'],
  //     todoText: data?['name'],
  //     isDone: data?['done']
  //   );
  // }
}