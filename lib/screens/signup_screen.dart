import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nurses_todo_app/app_theme.dart';
import 'dart:io';
import '../controllers/auth.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthController _auth = AuthController();
  String? _value;
  late int shift;
  late List<String?> items = ['night shift','evening shift','morning shift',];
  bool loading = false;
  String error = '';
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final loadingWidget = (Platform.isAndroid)
        ? const CircularProgressIndicator(
          color: AppTheme.tdBlack,
        )
        : const CupertinoActivityIndicator(
          color: AppTheme.tdBlack,
        );

    return Stack(
      children: [
        Scaffold(
            appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: const BackButton(
                  color: Colors.black, // <-- SEE HERE
                )),
            backgroundColor: Colors.white,
            body: Form(
              key: _formKey,
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 50, bottom: 100),
                        child: Text(
                          'Signup',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
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
                        child: TextFormField(
                          controller: _name,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'name is empty';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                              hintText: 'name', border: InputBorder.none),
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
                        child: TextFormField(
                          controller: _email,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'email is empty';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                              hintText: 'email', border: InputBorder.none),
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
                        child: TextFormField(
                          controller: _password,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'password is empty';
                            } else if (value.length < 6) {
                              return 'Password should be at least 6 characters';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                              hintText: 'password', border: InputBorder.none),
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
                              style: const TextStyle(
                                  color: AppTheme.tdBlack),
                              hint: Text(
                                'Select shift',
                                style: TextStyle(
                                    color:
                                    AppTheme.tdBlack),
                              ),
                              iconSize: 35,
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: AppTheme.tdBlack,
                              ),
                              value: _value,
                              isExpanded: true,
                              items: items.map<
                                  DropdownMenuItem<String>>(
                                      (String? value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                          '\t \t \t \t ${value!}'),
                                    );
                                  }).toList(),
                              onChanged: (value) =>
                                  setState(() {
                                    _value =value;
                                    if(value == 'shift1'){
                                      shift =1;
                                    }if(value == 'shift2'){
                                      shift =2;
                                    }if(value == 'shift3'){
                                      shift =3;
                                    }
                                  })),
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        error,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 14.0),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      SizedBox(
                          height: 45,
                          width: 150,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => loading = true);
                                dynamic result = await _auth.register(_email.text, _password.text, _name.text, shift);
                                print(result);
                                if (result == null) {
                                  setState(() =>
                                      error = 'please supply a valid email');
                                }if (result != null) {
                                  Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
                                }
                                setState(() => loading = false);
                              }
                            },
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        AppTheme.tdBlue)),
                            child: const Text('Signup'),
                          )),
                      const SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ),
              ),
            )),
        if (loading)
          Container(
              height: double.infinity,
              width: double.infinity,
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: loadingWidget,
              ))
      ],
    );
  }
}
