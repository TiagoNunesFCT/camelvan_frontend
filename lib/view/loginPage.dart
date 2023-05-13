import 'package:camelvan_frontend/view/registerPage.dart';
import 'package:camelvan_frontend/view/sellerLandingPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'buyerLandingPage.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
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
                const EdgeInsets.symmetric(horizontal: 8, vertical: 16.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Navigate the user to the Home page
                        try {
                          final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                              email: emailController.text,
                              password: passwordController.text
                          );

                          FirebaseFirestore db = FirebaseFirestore.instance;

                          // //check if user is buyer or seller
                          // DocumentSnapshot snapshot = await db.collection('users').doc(credential.user!.uid).get().then();
                          // if(snapshot['type'] == 'buyer'){
                          //   Navigator.push(context, MaterialPageRoute(builder: (context) => BuyerLandingPage()));
                          // }else{
                          //   Navigator.push(context, MaterialPageRoute(builder: (context) => SellerLandingPage()));
                          // }

                          final docRef = db.collection("users").doc(emailController.text);
                          docRef.get().then(
                                (DocumentSnapshot doc) {
                                  final data = doc.data() as Map<String, dynamic>;
                                  if(data['type'] == 'buyer'){
                                    Navigator.popUntil(context, ModalRoute.withName('/'));
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => BuyerLandingPage()));
                                  } else {
                                    Navigator.popUntil(context, ModalRoute.withName('/'));
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => SellerLandingPage()));
                                  }
                            },
                            onError: (e) => print("Error getting document: $e"),
                          );

                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'user-not-found') {
                            print('No user found for that email.');
                          } else if (e.code == 'wrong-password') {
                            print('Wrong password provided for that user.');
                          }
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill input')),
                        );
                      }
                    },
                    child: const Text('Sign in'),
                  ),
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 16.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
                    },
                    child: const Text('Register'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}