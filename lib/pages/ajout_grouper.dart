import 'dart:convert';

//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:s_trading/model/colis_list.dart';
import 'package:s_trading/model/colis_model.dart';
import '../model/carton.dart';
import 'package:http/http.dart' as http;

class AjoutGrouper extends StatefulWidget {
  const AjoutGrouper({Key? key}) : super(key: key);

  @override
  State<AjoutGrouper> createState() => _AjoutGrouperState();
}

class _AjoutGrouperState extends State<AjoutGrouper> {
  String barcode = '5269832';
  String barcodecolis = '69563258O';
  final codeclientEditingController = TextEditingController();
  final List<String> _etat = <String>[
    'Arrivé en chine',
    'en cours envoie',
    'arrivé à Mada',
    'récuperer',
    'retour en chine',
  ];
  var selectedtype;
  List<String> listeScans = [];

  @override
  Widget build(BuildContext context) {
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
    final saveButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.blue,
      child: MaterialButton(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        //minWidth: MediaQuery.of(context).size.width,
        onPressed: () {
          //ajouterCartonAvecScans();
          ajouterCarton();
        },
        child: const Text(
          "Sauvegarder",
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
        title: const Text("Ajouter un groupement"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 15),
              const Text(
                'Tracking du carton ',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    barcode,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 5),
                  ElevatedButton(
                    onPressed: () {
                      scanBarcodeCarton();
                    },
                    child: const Text("Scan"),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              etat,
              const SizedBox(height: 15),
              const Text(
                "Identité du colis",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    barcodecolis,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      scanBarcodeColis();
                    },
                    child: const Text("Scan"),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              // codeclientfield,
              const SizedBox(height: 5),
              saveButton,
            ]),
      ),
    );
  }

  Future<void> scanBarcodeCarton() async {
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
  }

  Future<void> scanBarcodeColis() async {
    final barcodecolis = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666',
      'Cancel',
      true,
      ScanMode.BARCODE,
    );

    if (!mounted) return;

    if (barcodecolis != '-1') {
      bool validerColis = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              "Validation colis",
              style: TextStyle(color: Colors.blue),
            ),
            content: Text(
              "Voulez-vous ajouter $barcodecolis?",
              style: TextStyle(color: Colors.grey),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // Annuler la validation
                },
                child: const Text("Annuler"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Valider la validation
                },
                child: const Text("Valider"),
              ),
            ],
          );
        },
      );

      if (validerColis == true) {
        setState(() {
          this.barcodecolis = barcodecolis;
          listeScans.add(barcodecolis);
        });
      }
    }
  }

  Future<void> ajouterCarton() async {
    if (barcode.isEmpty || selectedtype == null || listeScans.isEmpty) {
      Fluttertoast.showToast(
          msg:
              'Veuillez scanner un code-barres, sélectionner un état et ajouter des données de suivi.');
      return;
    }

    Map<String, dynamic> cartonData = {
      "trackingCarton": barcode,
      "etat": selectedtype,
      "trackingColis": listeScans,
    };

    final apiUrl = 'https://s-tradingmadagasikara.com/addCarton.php';

    final response = await http.post(
      Uri.parse(apiUrl),
      body: jsonEncode(cartonData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      // Carton ajouté avec succès
      print('Response Body: ${response.body}');
      Fluttertoast.showToast(msg: 'Carton ajouté avec succès');

      setState(() {
        barcode = '';
        selectedtype = null;
        listeScans.clear();
      });
    } else if (response.statusCode == 400) {
      // Mauvaise requête
      print('HTTP Error: ${response.statusCode}');
      print('Response Body: ${response.body}');
      Fluttertoast.showToast(msg: 'Données incomplètes fournies');
    } else {
      // Erreur interne du serveur ou autre
      print('HTTP Error: ${response.statusCode}');
      print('Response Body: ${response.body}');
      Fluttertoast.showToast(msg: '${response.body}');
    }
  }

  /* Future<void> ajouterCarton(Carton carton) async {
    CollectionReference cartonCollection = FirebaseFirestore.instance.collection('cartons');

    Map<String, dynamic> cartonData = carton.toJson();

    await cartonCollection.add(cartonData);
  }
  void ajouterCartonAvecScans() {
    // Créez un nouvel objet Carton avec les données du carton collectées auparavant
    Carton nouveauCarton = Carton(
        tracking: barcode,
        etat: selectedtype,
        trackingColis:listeScans);

    // Appelez la fonction pour ajouter le carton à Firestore
    ajouterCarton(nouveauCarton);
    Fluttertoast.showToast(msg: "Les colis ont été ajouté dans le carton $barcode");
  }*/

/* postDetailsToFirestore() async {
    //calling our firestore
    //calling our user model
    //sending these values
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    ColisCodebarre colisCodebarre = ColisCodebarre();

    //writing all the value
    colisCodebarre.trackingCarton = barcode;
    colisCodebarre.etat = selectedtype;
    colisCodebarre.tracking = barcodecolis;

    await firebaseFirestore
        .collection("colisGrouper")
        .add(colisCodebarre.toMap());
    Fluttertoast.showToast(msg: "Le coli a été ajouté dans le carton $barcode");
  }*/
}
