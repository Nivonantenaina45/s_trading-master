import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/colis_list.dart';
import '../model/colis_model.dart';

class Etats extends StatefulWidget {
  const Etats({Key? key}) : super(key: key);

  @override
  State<Etats> createState() => _EtatsState();
}

class _EtatsState extends State<Etats> {
  final _colisStream =
      FirebaseFirestore.instance.collection("colisDetails").snapshots();
  String tracking = "";
  final _formKey = GlobalKey<FormState>();
  final codeclientEditingController = TextEditingController();
  final trackingEditingController = TextEditingController();

  final List<String> _etat = <String>[
    'Arrivé en chine',
    'En cours envoie',
    'Arrivé à Mada',
    'Récuperer',
    'Retour en chine',
  ];
  final List<String> _modeenvoie = <String>['Express', 'Maritimes', 'Batterie'];
  final poidsEditingController = TextEditingController();
  final volumeEditingController = TextEditingController();
  final fraisdelivraisonEditingController = TextEditingController();

  var selectedtype, selectedtype2;

  @override
  Widget build(BuildContext context) {
    final codeclientfield = TextFormField(
        autofocus: false,
        enabled: false,
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
    final trackingfield = TextFormField(
        autofocus: false,
        enabled: false,
        controller: trackingEditingController,
        keyboardType: TextInputType.name,
        validator: (value) {
          if (value!.isEmpty) {
            return ("tracking obligatoire");
          }
          return null;
        },
        onSaved: (value) {
          trackingEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
            prefixIcon: const Icon(Icons.confirmation_num_rounded),
            contentPadding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
            hintText: "tracking",
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

    final changeButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.blue,
      child: MaterialButton(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        //minWidth: MediaQuery.of(context).size.width,
        onPressed: () {
          postDetailsToFirestore();
          Navigator.pop(context);
        },
        child: const Text(
          "Changer",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
    Widget updateWidgets() => Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 15,
              ),
              trackingfield,
              const SizedBox(
                height: 15,
              ),
              codeclientfield,
              const SizedBox(
                height: 15,
              ),
              poidsfield,
              const SizedBox(
                height: 15,
              ),
              volumefield,
              const SizedBox(
                height: 15,
              ),
              fraisdelivraisonfield,
              const SizedBox(
                height: 5,
              ),
              modeenvoi,
              const SizedBox(
                height: 5,
              ),
              etat,
              const SizedBox(
                height: 5,
              ),
              changeButton,
            ],
          ),
        );
    return Scaffold(
      appBar: AppBar(
          title: Card(
        child: TextField(
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.search), hintText: 'Recherche...'),
          onChanged: (val) {
            setState(() {
              tracking = val;
            });
          },
        ),
      )),
      body: StreamBuilder(
        stream: _colisStream,
        builder: (context, snapshot) {
          var docs = snapshot.data!.docs;
          return (snapshot.connectionState == ConnectionState.waiting)
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot documentSnapshot =
                        snapshot.data!.docs[index];
                    if (tracking.isEmpty) {
                      return ListTile(
                        title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                docs[index]['tracking'],
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                        isScrollControlled: true,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20),
                                          ),
                                        ),
                                        context: context,
                                        builder: (context) => updateWidgets());
                                    codeclientEditingController.text = snapshot
                                        .data?.docs[index]['codeClient'];
                                    trackingEditingController.text =
                                        snapshot.data?.docs[index]['tracking'];
                                    poidsEditingController.text =
                                        documentSnapshot['poids'].toString();
                                    volumeEditingController.text =
                                        documentSnapshot['volume'].toString();
                                    fraisdelivraisonEditingController.text =
                                        snapshot.data?.docs[index]['frais'];
                                    selectedtype = snapshot.data?.docs[index]['etat'];
                                    selectedtype2 =snapshot.data?.docs[index]['etat'];

                                  },
                                  icon: Icon(Icons.edit, color: Colors.blue))
                            ]),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              docs[index]['modeEnvoie'],
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              docs[index]['etat'],
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    if (docs[index]['tracking']
                        .toString()
                        .toLowerCase()
                        .startsWith(tracking.toLowerCase())) {
                      return ListTile(
                        title: Text(
                          docs[index]['tracking'],
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              docs[index]['modeEnvoie'],
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              docs[index]['etat'],
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return Container();
                  });
        },
      ),
    );
  }

  postDetailsToFirestore() async {
    //calling our firestore
    //calling our user model
    //sending these values
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    ColisModel colisModel = ColisModel();
    double poidstr = double.parse(poidsEditingController.text);
    double volumestr = double.parse(volumeEditingController.text);

    //writing all the value
    //colisModel.colisid = colisModel.colisid;
    colisModel.codeClient = codeclientEditingController.text;
    colisModel.tracking = trackingEditingController.text;
    colisModel.poids = poidstr;
    colisModel.volume = volumestr;
    colisModel.frais = fraisdelivraisonEditingController.text;
    colisModel.modeEnvoie = selectedtype2;
    colisModel.etat = selectedtype;
    // colisModel.facture = resultat as String?;

    await firebaseFirestore
        .collection("colisDetails")
        .doc("JyVSFR7VOLJND5Hcibq9")
        .update(colisModel.toMap());
    Fluttertoast.showToast(msg: "Le colis a été modifié avec succés");
  }
}
