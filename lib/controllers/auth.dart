import 'package:firebase_auth/firebase_auth.dart';
import 'package:nurses_todo_app/controllers/database_services.dart';
import 'package:nurses_todo_app/models/user_model.dart';

class AuthController{

  final FirebaseAuth _auth =  FirebaseAuth.instance;

  AppUser _userFromFirebase (User user){

    return  AppUser(uid: user.uid);
  }

// auth change user stream
  Stream<AppUser> get user {
    return _auth.authStateChanges().map((event) => _userFromFirebase(event!));
  }

  Future register(String email, String password, String name, int shift)async{
    try{
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password,);
      User? user = credential.user;


      if(user != null){
        await DataBaseServices(uid: user.uid).updateUser(name, shift);
      }
      return _userFromFirebase(user!);
    } catch(e){
      print(e.toString());
      return null;
    }
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = credential.user;
      return user;
    } catch (error) {
      print(error.toString() + 'error');
      return null;
    }
  }


}