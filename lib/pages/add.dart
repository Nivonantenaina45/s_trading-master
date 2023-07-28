import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../model/colis_model.dart';

class Add extends StatefulWidget {
  const Add({Key? key}) : super(key: key);

  @override
  State<Add> createState() => _State();
}

class _State extends State<Add> {
  String barcode = '69563258O';
  final _formKey = GlobalKey<FormState>();
  final codeclientEditingController = TextEditingController();
  final poidsEditingController = TextEditingController();
  final volumeEditingController = TextEditingController();
  final fraisdelivraisonEditingController = TextEditingController();
  var selectedtype, selectedtype2;

  int resultat = 0;

  final List<String> _modeenvoie = <String>['Express', 'Maritimes', 'Batterie'];
  final List<String> _etat = <String>[
    'Arrivé en chine',
    'En cours envoie',
    'Arrivé à Mada',
    'Récuperer',
    'Retour en chine',
  ];

  @override
  Widget build(BuildContext context) {
    final codeclient = TextFormField(
        autofocus: false,
        controller: codeclientEditingController,
        keyboardType: TextInputType.name,
        validator: (value) {
          if (value!.isEmpty) {
            return ("code client obligatoire");
          }
          return null;
        },
        onSaved: (value) {
          codeclientEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
            prefixIcon: const Icon(Icons.code),
            contentPadding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
            hintText: "code client",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            )));
    final poidsfield = TextFormField(
        autofocus: false,
        controller: poidsEditingController,
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value!.isEmpty) {
            return ("poids obligatoire");
          }
          return null;
        },
        onSaved: (value) {
          poidsEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
            prefixIcon: const Icon(Icons.monitor_weight_outlined),
            contentPadding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
            hintText: "poids en kg",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            )));
    final volumefield = TextFormField(
        autofocus: false,
        controller: volumeEditingController,
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value!.isEmpty) {
            return ("volume obligatoire");
          }
          return null;
        },
        onSaved: (value) {
          volumeEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
            prefixIcon: const Icon(Icons.space_dashboard),
            contentPadding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
            hintText: "volume en m3",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            )));
    final fraisdelivraisonfield = TextFormField(
        autofocus: false,
        controller: fraisdelivraisonEditingController,
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value!.isEmpty) {
            return ("frais de livraison obligatoire");
          }
          return null;
        },
        onSaved: (value) {
          fraisdelivraisonEditingController.text = value!;
        },
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
            prefixIcon: const Icon(Icons.money),
            contentPadding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
            hintText: "frais de livraison en Ar",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            )));
    final modeenvoi = DropdownButton(
      items: _modeenvoie
          .map((value) => DropdownMenuItem(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(color: Colors.black54),
                ),
              ))
          .toList(),
      onChanged: (selectedmodeenvoi) {
        if (kDebugMode) {
          print('$selectedmodeenvoi');
        }
        setState(() {
          selectedtype2 = selectedmodeenvoi;
        });
      },
      value: selectedtype2,
      isExpanded: false,
      hint: const Text(
        'Choisisez un mode envoie',
        style: TextStyle(color: Colors.black54),
      ),
    );
    final etat = DropdownButton(
      items: _etat
          .map((value) => DropdownMenuItem(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(color: Colors.black54),
                ),
              ))
          .toList(),
      onChanged: (selectedetat) {
        if (kDebugMode) {
          print('$selectedetat');
        }
        setState(() {
          selectedtype = selectedetat;
        });
      },
      value: selectedtype,
      isExpanded: false,
      hint: const Text(
        'Choisisez un Etat',
        style: TextStyle(color: Colors.black54),
      ),
    );

    final addButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.blue,
      child: MaterialButton(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () {
          insert();
          barcode = 'Inconnue';
          fraisdelivraisonEditingController.text = '';
          codeclientEditingController.text = '';
          poidsEditingController.text = '';
          volumeEditingController.text = '';
        },
        child: const Text(
          "Inserer",
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
      appBar: AppBar(
        title: const Text("Ajouter"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    barcode,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: ()  {
                      scanBarcode();
                    },
                    child: const Text("Scan"),
                  )
                ],
              ),
              const SizedBox(height: 15),
              codeclient,
              const SizedBox(height: 15),
              poidsfield,
              const SizedBox(height: 15),
              volumefield,
              const SizedBox(height: 15),
              fraisdelivraisonfield,
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    FontAwesomeIcons.plane,
                    size: 15.0,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 25.0),
                  modeenvoi,
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    FontAwesomeIcons.servicestack,
                    size: 15.0,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 25.0),
                  etat,
                ],
              ),
              const SizedBox(height: 15),
              addButton,
            ],
          ),
        ),
      ),
    );
  }

  Future<void> scanBarcode() async {
    final barcode = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666',
      'Cancel',
      true,
      ScanMode.BARCODE,
    );

    if (!mounted) return;

    setState(() {
      this.barcode = barcode;
    });
    CollectionReference collectionReference =
    FirebaseFirestore.instance.collection('colisClient');
    QuerySnapshot querySnapshot =
    await collectionReference.where('tracking', isEqualTo: barcode).get();

    if (querySnapshot.docs.isEmpty) {
      print('Barcode not found.');
    } else {
      // Barcode found in Firestore
      var doc = querySnapshot.docs.first;
      Map<String, dynamic> data = doc.data() as Map<String,dynamic>;
      // Update the state with the retrieved data
      setState(() {
        codeclientEditingController.text = data['codeClient'];
        Fluttertoast.showToast(msg: 'mode  envoie ${data['modeEnvoi']}');
      });
    }

  }

  void insert() async {
    if (_formKey.currentState!.validate()) {
      postDetailsToFirestore();
    }
  }

  postDetailsToFirestore() async {
    //calling our firestore
    //calling our user model
    //sending these values
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    ColisModel colisModel = ColisModel();

    double poidstr = double.parse(poidsEditingController.text);
    double volumestr = double.parse(volumeEditingController.text);
    int fraisdelivr = int.parse(fraisdelivraisonEditingController.text);
    calcul();
    final colisref = firebaseFirestore.collection("colisDetails").doc();
    //writing all the value
    colisModel.colisid = colisref.id;
    colisModel.codeClient = codeclientEditingController.text;
    colisModel.tracking = barcode;
    colisModel.poids = poidstr;
    colisModel.volume = volumestr;
    colisModel.frais = fraisdelivr;
    colisModel.modeEnvoie = selectedtype2;
    colisModel.etat = selectedtype;
    colisModel.facture = resultat;

    await colisref.set(colisModel.toMap());
    Fluttertoast.showToast(msg: "Le colis a été ajouté avec succés");
  }

  int calcul() {
    int prixExpress = 88000;
    int prixbatterie = 185000;
    int prixmaritime = 2136000;
    //int resultat = 0;
    double res2 = 0.0;
    double resd = 0.0;
    var poids = double.parse(poidsEditingController.text);
    var volume = double.parse(volumeEditingController.text);
    int fraisdelivr = int.parse(fraisdelivraisonEditingController.text);
    double prixexp = prixExpress.toDouble();

    if (selectedtype2 == "Express" && volume == 0) {
      resd = prixexp * poids;
      resultat = resd.toInt() + fraisdelivr;
      Fluttertoast.showToast(msg: 'la valeur du colis est de $resultat Ar');
    }
    if (selectedtype2 == "Express" && volume < 0.006 && poids == 0) {
      resd = volume * prixexp;
      res2 = (resd / 0.006);
      resultat = res2.toInt() + fraisdelivr;
      Fluttertoast.showToast(msg: 'la valeur du colis est de $resultat Ar');
    }
    if (selectedtype2 == "Express" && volume > 0.006 && poids == 0) {
      resd = volume * prixexp;
      resultat = resd.toInt() + fraisdelivr;
      Fluttertoast.showToast(msg: 'la valeur du colis est de $resultat Ar');
    }

    if (selectedtype2 == "Maritimes" && poids == 0) {
      resd = volume * prixmaritime;
      resultat = resd.toInt() + fraisdelivr;
      Fluttertoast.showToast(msg: 'la valeur du colis est de $resultat Ar');
    }
    if (selectedtype2 == "Batterie" && volume == 0) {
      resd = prixbatterie * poids;
      resultat = resd.toInt() + fraisdelivr;
      Fluttertoast.showToast(msg: 'la valeur du colis est de $resultat Ar');
    }
    return resultat;
  }
}
