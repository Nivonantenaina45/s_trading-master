//import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:s_trading/pages/home.dart';
import 'package:s_trading/pages/registrartion.dart';
import 'package:http/http.dart' as http;

import '../model/user_model.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  //form key
  final _formKey = GlobalKey<FormState>();

  //editing controller
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login(String email, String pass) async {
    try {
      final response = await http.post(
        Uri.parse('https://s-tradingmadagasikara.com/login.php'),
        body: {
          "email": email,
          "password": pass,
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data["data"]["success"] == 1) {
          UserModel user = UserModel(
            email: email,
            nom: data["data"]["nom"],
            prenom: data["data"]["prenom"],
          );
          UserModel.saveUser(user);

          Fluttertoast.showToast(msg: "Connexion réussie");
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Home()));
        } else {
          Fluttertoast.showToast(msg: data["data"]["message"]);
        }
      } else {
        print("Erreur HTTP: ${response.statusCode}");
      }
    } catch (e) {
      print("Erreur lors de la requête HTTP: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    //email field
    final emailField = TextFormField(
        autofocus: false,
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value!.isEmpty) {
            return ("Entrer votre Email");
          }
          if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
              .hasMatch(value)) {
            return ("Entrer une Email valide");
          }
          return null;
        },
        onSaved: (value) {
          emailController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
            prefixIcon: const Icon(Icons.mail),
            contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
            hintText: "Email",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            )));
    //password field
    final passwordField = TextFormField(
      autofocus: false,
      controller: passwordController,
      obscureText: true,
      validator: (value) {
        RegExp regex = RegExp(r'^.{6,}$');
        if (value!.isEmpty) {
          return ("Mot de passe nécessaire");
        }
        if (!regex.hasMatch(value)) {
          return ("Entrer un mot de passe valide(min. 6 charactére");
        }
      },
      onSaved: (value) {
        passwordController.text = value!;
      },
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
          prefixIcon: const Icon(Icons.vpn_key),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Mot de passe",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );
    //login button
    final loginButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.blue,
      child: MaterialButton(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () {
          //signIn(emailController.text, passwordController.text);
          login(emailController.text, passwordController.text);
        },
        child: const Text(
          "Se connecter",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SingleChildScrollView(
            child: Container(
                color: Colors.white,
                child: Padding(
                    padding: const EdgeInsets.all(36.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 150,
                            child: Image.asset(
                              "assets/logo_strading.jpg",
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 25),
                          emailField,
                          const SizedBox(height: 25),
                          passwordField,
                          const SizedBox(height: 25),
                          loginButton,
                          const SizedBox(height: 25),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const Text("Vous n'avez pas un compte?"),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const Registration()));
                                },
                                child: const Text(
                                  "Créer",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ))),
          ),
        ));
  }

  /*void signIn(String email, String page) async {
    if (_formKey.currentState!.validate()) {
      await _auth
          .signInWithEmailAndPassword(email: email, password: page)
          .then((uid) => {
                Fluttertoast.showToast(msg: "connection avec succés"),
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => Home())),
              })
          .catchError((e) {
        Fluttertoast.showToast(msg: e!.message);
      });
    }
  }*/
}
