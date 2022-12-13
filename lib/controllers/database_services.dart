import 'package:cloud_firestore/cloud_firestore.dart';

class DataBaseServices {

  final String? uid;
  final String? taskId;
  DataBaseServices({this.uid, this.taskId});

  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference todosCollection = FirebaseFirestore.instance.collection('tasks');



  Future updateUser(String name, int shift) async {
    return await usersCollection.doc(uid).set({
      'name': name,
      'shift': shift,
    });
  }


}