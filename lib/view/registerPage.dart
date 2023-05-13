import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'buyerLandingPage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}
enum UserType { Buyer, Seller }

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  UserType? _type = UserType.Buyer;
  final functions = FirebaseFunctions.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), labelText: "Email"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), labelText: "Password"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        title: const Text('Buyer'),
                        leading: Radio<UserType>(
                          value: UserType.Buyer,
                          groupValue: _type,
                          onChanged: (UserType? value) {
                            setState(() {
                              _type = value;
                            });
                          },
                        ),
                      ),
                      ListTile(
                        title: const Text('Seller'),
                        leading: Radio<UserType>(
                          value: UserType.Seller,
                          groupValue: _type,
                          onChanged: (UserType? value) {
                            setState(() {
                              _type = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 16.0),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // Navigate the user to the Home page
                          try {
                            final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                email: emailController.text,
                                password: passwordController.text
                            );


                            await FirebaseAuth.instance.signInWithEmailAndPassword(
                                email: emailController.text,
                                password: passwordController.text
                            );

                            if(_type == UserType.Buyer ){
                              try {
                                final result = await FirebaseFunctions.instance.httpsCallable('addBuyer').call(
                                    {
                                      "mail": emailController.text
                                    }
                                );
                                log("Add Buyer");
                              } on FirebaseFunctionsException catch (error) {
                                log("error buyer");
                                print(error.code);
                                print(error.details);
                                print(error.message);
                              }
                            } else {
                              try {
                                final result = await FirebaseFunctions.instance.httpsCallable('addSeller').call(
                                    {
                                      "mail": emailController.text
                                    }
                                );
                                log("Add Seller");
                              } on FirebaseFunctionsException catch (error) {
                                log("error buyer");
                                print(error.code);
                                print(error.details);
                                print(error.message);
                              }
                            }


                            Navigator.popUntil(context, ModalRoute.withName('/'));

                            Navigator.push(context, MaterialPageRoute(builder: (context) => BuyerLandingPage()));

                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'weak-password') {
                              print('The password provided is too weak.');
                            } else if (e.code == 'email-already-in-use') {
                              print('The account already exists for that email.');
                            }
                          }
                        }
                      },
                      child: const Text('Submit'),
                    ),
                  ),
                ),
              ],
            ),
          )
      ),
    );
  }
}