import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:s_trading/model/colis_list.dart';
import '../model/carton.dart';
import '../model/colis_model.dart';
import 'ajout_colis_oubli.dart';
import 'ajout_grouper.dart';
import 'listes_colis_grouper.dart';

class Grouper extends StatefulWidget {
  const Grouper({Key? key}) : super(key: key);

  @override
  State<Grouper> createState() => _GrouperState();
}

class _GrouperState extends State<Grouper> {
  final _colisStream = FirebaseFirestore.instance.collection("cartons");

  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  String tracking = "";
  final codeclientEditingController = TextEditingController();
  final trackingCartonEditingController = TextEditingController();
  final trackingEditingController = TextEditingController();
  final List<String> _etat = <String>[
    'Arrivé en chine',
    'en cours envoie',
    'arrivé à Mada',
    'récuperer',
    'retour en chine',
  ];
  var selectedtype;
  String barcode = "";
  ColisModel colisrep = ColisModel();
  ColisCodebarre colisCodebarre = ColisCodebarre();

  void _startListeningToCartons() {
    _colisStream.snapshots().listen((snapshot) {
      for (QueryDocumentSnapshot cartonDoc in snapshot.docs) {
        String etat = cartonDoc.get('etat');
        List<dynamic> colistracking = cartonDoc.get('trackingColis');
        _updateColisDetailles(etat, colistracking);
        Fluttertoast.showToast(
            msg: "L'état des petits colis a été modifié avec succès");
      }
    });
  }

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

  Future<void> _updateColisDetailles(
      String etat, List<dynamic> colistracking) async {
    for (var tracking in colistracking) {
      QuerySnapshot colisSnapshot = await FirebaseFirestore.instance
          .collection('colisDetails')
          .where('tracking', isEqualTo: tracking)
          .get();

      for (QueryDocumentSnapshot colisDoc in colisSnapshot.docs) {
        String docId = colisDoc.id;
        await _updateDocument(docId, etat);
      }
    }
  }

  Future<void> _updateDocument(String docId, String etat) async {
    try {
      DateTime currentDate = DateTime.now();
      await FirebaseFirestore.instance
          .collection('colisDetails')
          .doc(docId)
          .collection('dates')
          .add({
        'dateEtat': Timestamp.fromDate(currentDate),
        'etat': etat,
      });
      await FirebaseFirestore.instance
          .collection('colisDetails')
          .doc(docId)
          .update({
        'etat': etat,
      });
      print('Document $docId updated successfully.');
    } catch (e) {
      print('An error occurred while updating the document: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<void> _deleteCarton(String cartonId) async {
      try {
        await _colisStream.doc(cartonId).delete();
        Fluttertoast.showToast(msg: "Carton supprimé avec ses colis membres");
      } catch (e) {
        Fluttertoast.showToast(msg: "Erreur de suppression");
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
                  /*TextFormField(
                      enabled: false,
                      autofocus: false,
                      controller: trackingEditingController,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                          prefixIcon:
                          const Icon(Icons.confirmation_num_rounded),
                          contentPadding:
                          const EdgeInsets.fromLTRB(15, 10, 15, 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ))),*/
                  const SizedBox(
                    height: 15,
                  ),
                  const SizedBox(
                    height: 15,
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
                      //minWidth: MediaQuery.of(context).size.width,
                      onPressed: () async {
                        String cartonId = documentSnapshot?.id ?? '';
                        await updateEtatAndDate(cartonId, selectedtype);
                        _startListeningToCartons();
                        Navigator.pop(ctx);
                      },
                      child: const Text(
                        "changer",
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

    return Scaffold(
      appBar: AppBar(
          title: Card(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.search,
                color: Colors.blue,
              ),
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
          List<QueryDocumentSnapshot> cartonDocs = snapshot.data?.docs??[];
          return (snapshot.connectionState == ConnectionState.waiting)
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.builder(
                  itemCount: cartonDocs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot documentSnapshot = cartonDocs[index];
                    if (tracking.isEmpty ||
                        cartonDocs[index]['tracking']
                            .toString()
                            .toLowerCase()
                            .startsWith(tracking.toLowerCase())) {
                      return Card(
                          child: ListTile(
                              title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${cartonDocs[index]['tracking']}',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          _update(documentSnapshot);
                                          /*trackingCartonEditingController.text =
                                cartonDocs[index]['tracking'];*/
                                          selectedtype =
                                              '${cartonDocs[index]['etat']}';
                                        },
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blue)),
                                    IconButton(
                                      onPressed: () {
                                        // Naviguez vers la page "AjoutColis" ici
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AjoutColisPage(),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.add, color: Colors.blue),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text(
                                                  "Confirmer la suppression",style:TextStyle(color: Colors.blue)),
                                              content: const Text(
                                                  "Êtes-vous sûr de vouloir supprimer ce carton?",style:TextStyle(color: Colors.grey),),
                                              actions: [
                                                TextButton(
                                                  child: const Text("Annuler"),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                TextButton(
                                                  child:
                                                      const Text("Supprimer"),
                                                  onPressed: () {
                                                    _deleteCarton(
                                                        documentSnapshot.id);
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      icon: const Icon(Icons.delete,
                                          color: Colors.blue),
                                    ),
                                  ]),
                              subtitle: Text(
                                '${cartonDocs[index]['etat']}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ListColis(doc: documentSnapshot),
                                  ),
                                );
                              }));
                    }
                    return const SizedBox.shrink();
                  });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AjoutGrouper()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> updateEtatAndDate(String cartonId, String etat) async {
    try {
      DateTime currentDate = DateTime.now();

      // Mettez à jour le document du carton
      await FirebaseFirestore.instance
          .collection('cartons')
          .doc(cartonId)
          .update({
        'etat': etat,
      });

      // Obtenez les colis membres du carton
      DocumentSnapshot cartonSnapshot = await FirebaseFirestore.instance
          .collection('cartons')
          .doc(cartonId)
          .get();
      List<dynamic> colistracking = cartonSnapshot.get('trackingColis');

      // Mettez à jour les colis membres du carton
      for (var tracking in colistracking) {
        QuerySnapshot colisSnapshot = await FirebaseFirestore.instance
            .collection('colisDetails')
            .where('tracking', isEqualTo: tracking)
            .get();

        for (QueryDocumentSnapshot colisDoc in colisSnapshot.docs) {
          String docId = colisDoc.id;
          await _updateDocument(docId, etat);
        }
      }

      Fluttertoast.showToast(
        msg: "L'état du carton a été modifié avec succès",
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg:
            "Erreur lors de la mise à jour de l'état du carton et de ses colis membres",
      );
      print('An error occurred while updating the carton and colis: $e');
    }
  }
}
