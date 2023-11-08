import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:s_trading/model/user_model.dart';
import 'package:s_trading/pages/home.dart';

class Registration extends StatefulWidget {
  const Registration({Key? key}) : super(key: key);

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final _formKey = GlobalKey<FormState>();

  //final _auth = FirebaseAuth.instance;

  final nomEditingController = TextEditingController();
  final prenomEditingController = TextEditingController();
  final emailEditingController = TextEditingController();
  final motdepassEditingController = TextEditingController();
  final confmotdepassEditingController = TextEditingController();

  void register(String nom, String prenom, String email, String pass) async {
    try {
      final response = await http.post(
        Uri.parse('https://s-tradingmadagasikara.com/registration.php'),
        body: {
          "nom": nom,
          "prenom": prenom,
          "email": email,
          "password": pass,
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data["data"]["succes"] == 1) {
          UserModel user = UserModel(
            email: email,
            nom: data["data"]["nom"],
            prenom: data["data"]["prenom"],
          );
          UserModel.saveUser(user);
          Fluttertoast.showToast(msg: "Le compte a été créé avec succès");
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Home()));
        } else {
          Fluttertoast.showToast(msg: "${data["data"]["msg"]}");
        }
      } else {
        print("Erreur HTTP: ${response.statusCode}");
      }
    } catch (e) {
      print("Erreur lors de la requête HTTP: $e");
    }
    emailEditingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final nomField = TextFormField(
        autofocus: false,
        controller: nomEditingController,
        keyboardType: TextInputType.name,
        validator: (value) {
          RegExp regex = RegExp(r'^.{3,}$');
          if (value!.isEmpty) {
            return ("Nom obligatoire");
          }
          if (!regex.hasMatch(value)) {
            return ("Entrer un nom valide(min. 3 charactére");
          }
          return null;
        },
        onSaved: (value) {
          nomEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
            prefixIcon: const Icon(Icons.account_circle),
            contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
            hintText: "Nom",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            )));

    final prenomField = TextFormField(
        autofocus: false,
        controller: prenomEditingController,
        keyboardType: TextInputType.name,
        validator: (value) {
          if (value!.isEmpty) {
            return ("Nom obligatoire");
          }
          return null;
        },
        onSaved: (value) {
          prenomEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
            prefixIcon: const Icon(Icons.account_circle),
            contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
            hintText: "prenom",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            )));
    final emailField = TextFormField(
        autofocus: false,
        controller: emailEditingController,
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
          emailEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
            prefixIcon: const Icon(Icons.mail),
            contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
            hintText: "Email",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            )));
    final passwordField = TextFormField(
      autofocus: false,
      controller: motdepassEditingController,
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
        motdepassEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon: const Icon(Icons.vpn_key),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Mot de passe",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final passwordConfField = TextFormField(
      autofocus: false,
      controller: confmotdepassEditingController,
      obscureText: true,
      validator: (value) {
        if (confmotdepassEditingController.text.length > 6 &&
            motdepassEditingController.text != value) {
          return "mot de passe non trouvé";
        }
        return null;
      },
      onSaved: (value) {
        confmotdepassEditingController.text = value!;
      },
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
          prefixIcon: const Icon(Icons.vpn_key),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Confirmer Mot de passe",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );
    final signupButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.blue,
      child: MaterialButton(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () {
          //signup(emailEditingController.text, motdepassEditingController.text);
          if (_formKey.currentState!.validate()) {
            register(nomEditingController.text, prenomEditingController.text,
                emailEditingController.text, motdepassEditingController.text);
          }
        },
        child: const Text(
          "Créer",
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.blue,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
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
                          nomField,
                          const SizedBox(height: 25),
                          prenomField,
                          const SizedBox(height: 25),
                          emailField,
                          const SizedBox(height: 25),
                          passwordField,
                          const SizedBox(height: 25),
                          passwordConfField,
                          const SizedBox(height: 25),
                          signupButton,
                        ],
                      ),
                    ))),
          ),
        ));
  }

  /*void signup(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((userCredential) async {
        await userCredential.user!.sendEmailVerification();
        postDetailsToFirestore();
      })
          .catchError((e) {
        Fluttertoast.showToast(msg: e.toString());
      });
    }
  }

  postDetailsToFirestore() async {
    //calling our firestore
    //calling our user model
    //sending these values
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;

    UserModel userModel = UserModel();

    //writing all the value
    userModel.email = user!.email;
    userModel.uid = user!.uid;
    userModel.nom = nomEditingController.text;
    userModel.prenom = prenomEditingController.text;

    await firebaseFirestore
        .collection("users")
        .doc(user.uid)
        .set(userModel.toMap());
    Fluttertoast.showToast(msg: "Le compte a été créer avec succés");
    Navigator.pop(context);

    /*Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
        (route) => false);*/
  }*/
}
