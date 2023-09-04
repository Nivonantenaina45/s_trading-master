import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/services.dart';

import 'detaille_info_colis.dart';


class Etats extends StatefulWidget {
  const Etats({Key? key}) : super(key: key);

  @override
  State<Etats> createState() => _EtatsState();
}

class _EtatsState extends State<Etats> {
  final _colisStream = FirebaseFirestore.instance.collection("colisDetails");
  String tracking = "";
  final codeclientEditingController = TextEditingController();
  final trackingEditingController = TextEditingController();
  String barcode="";

  final List<String> _etat = <String>[
    'Arrivé en chine',
    'en cours envoie',
    'arrivé à Mada',
    'récuperer',
    'retour en chine',
  ];
  final List<String> _modeenvoie = <String>['Express', 'Maritimes', 'Batterie'];
  final poidsEditingController = TextEditingController();
  final volumeEditingController = TextEditingController();
  final fraisdelivraisonEditingController = TextEditingController();

  var selectedtype, selectedtype2;

  Future<void> scanBarcode() async {
     barcode = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666',
      'Cancel',
      true,
      ScanMode.BARCODE,
    );

    if (!mounted) return;

    setState(() {
      tracking = barcode;
    });
  }

  Future<void> _deleteDocument(String documentId) async {
    try {
      await _colisStream.doc(documentId).delete();
      Fluttertoast.showToast(msg: "Colis supprimé");
    } catch (e) {
      Fluttertoast.showToast(msg: "Erreur de suppression du colis");
    }
  }

  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                    enabled: false,
                    autofocus: false,
                    controller: trackingEditingController,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.confirmation_num_rounded),
                        contentPadding:
                            const EdgeInsets.fromLTRB(15, 10, 15, 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ))),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                    enabled: false,
                    autofocus: false,
                    controller: codeclientEditingController,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.code),
                        contentPadding:
                            const EdgeInsets.fromLTRB(15, 10, 15, 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ))),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                    enabled: true,
                    autofocus: false,
                    controller: poidsEditingController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.monitor_weight_outlined),
                        contentPadding:
                            const EdgeInsets.fromLTRB(15, 10, 15, 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ))),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                    enabled: true,
                    autofocus: false,
                    controller: volumeEditingController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.space_dashboard),
                        contentPadding:
                            const EdgeInsets.fromLTRB(15, 10, 15, 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ))),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                    enabled: true,
                    autofocus: false,
                    controller: fraisdelivraisonEditingController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.money),
                        contentPadding:
                            const EdgeInsets.fromLTRB(15, 10, 15, 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ))),
                const SizedBox(
                  height: 5,
                ),
                DropdownButton(
                  items: _modeenvoie
                      .map((value) => DropdownMenuItem(
                            value: value,
                            enabled: true,
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
                ),
                const SizedBox(
                  height: 5,
                ),
                DropdownButton(
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
                ),
                const SizedBox(
                  height: 5,
                ),
                Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.blue,
                  child: MaterialButton(
                    padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                    onPressed: () async {
                      await updateEtatAndDate(documentSnapshot!.id, selectedtype);
                      Navigator.pop(ctx);
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
                ),


              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Card(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.search,color: Colors.blue,),
              onPressed: scanBarcode, // Use the scanBarcode function here
            ),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Recherche...',
                ),
                onChanged: (val) {
                  setState(() {
                    tracking = val;
                  });
                },
              ),
            ),
          ],
        ),
      )),
      body: StreamBuilder(
        stream: _colisStream.snapshots(),
        builder: (context, snapshot) {
          var docs = snapshot.data!.docs;
          return (snapshot.connectionState == ConnectionState.waiting)
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot documentSnapshot = docs[index];
                    if (tracking.isEmpty ||
                        docs[index]['tracking']
                            .toString()
                            .toLowerCase()
                            .startsWith(tracking.toLowerCase())) {
                      return Card(
                        child: ListTile(
                          title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  docs[index]['tracking'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                    onPressed: () {
                                      _update(documentSnapshot);
                                      codeclientEditingController.text =
                                          snapshot.data!.docs[index]
                                              ['codeClient'];
                                      trackingEditingController.text = snapshot
                                          .data!.docs[index]['tracking'];
                                      poidsEditingController.text = snapshot
                                          .data!.docs[index]['poids']
                                          .toString();
                                      volumeEditingController.text = snapshot
                                          .data!.docs[index]['volume']
                                          .toString();
                                      fraisdelivraisonEditingController.text =
                                          snapshot.data!.docs[index]['frais']
                                              .toString();
                                      selectedtype =
                                          snapshot.data!.docs[index]['etat'];
                                      selectedtype2 = snapshot.data?.docs[index]
                                          ['modeEnvoie'];
                                    },
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue)),
                                IconButton(
                                    icon: const Icon(Icons.delete,color: Colors.blue,),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text("Confirmer la suppression "),
                                            content: const Text(
                                                "vous voulez vraiment supprimé ce colis?"),
                                            actions: [
                                              TextButton(
                                                child: const Text("annuler"),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              TextButton(
                                                child: const Text("Supprimer"),
                                                onPressed: () {
                                                  _deleteDocument(
                                                      documentSnapshot.id);
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    })
                              ]),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                docs[index]['etat'] ?? 'etat non disponible',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            if (documentSnapshot != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailsInfoColis(documentSnapshot: documentSnapshot),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  });
        },
      ),
    );
  }
  Future<void> updateEtatAndDate(String documentId, String etat) async {
    try {
      DateTime currentDate = DateTime.now();

      // Mettez à jour le document du colis
      await FirebaseFirestore.instance.collection('colisDetails').doc(documentId).update({
        'etat': etat,
      });

      // Ajoutez la date au champ correspondant dans Firestore
      String fieldName = 'dateEtat_${etat.replaceAll(' ', '_').toLowerCase()}';
      await FirebaseFirestore.instance.collection('colisDetails').doc(documentId).collection('dates').add({
        'dateEtat': Timestamp.fromDate(currentDate),
        'etat': etat,
      });

      Fluttertoast.showToast(
        msg: "L'etat du colis a été changé avec succès",
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Erreur lors de la mise à jour de l'état du colis",
      );
      print('An error occurred while updating the document: $e');
    }
  }
}
