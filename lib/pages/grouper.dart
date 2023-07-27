import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:s_trading/model/colis_list.dart';
import '../model/carton.dart';
import '../model/colis_model.dart';
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
    'En cours envoie',
    'Arrivé à Mada',
    'Récuperer',
    'Retour en chine',
  ];
  var selectedtype;
  ColisModel colisrep = ColisModel();
  ColisCodebarre colisCodebarre = ColisCodebarre();

  void _startListeningToCartons() {
   _colisStream.snapshots().listen((snapshot) {
      for (QueryDocumentSnapshot cartonDoc in snapshot.docs) {
        String etat = cartonDoc.get('etat');
        List<dynamic> colistracking = cartonDoc.get('trackingColis');
        _updateColisDetailles(etat, colistracking);
        Fluttertoast.showToast(msg: "L'état des petits colis a été modifié avec succès");
      }
    });
  }

  Future<void> _updateColisDetailles(String etat, List<dynamic> colistracking) async {
    for (var tracking in colistracking) {
      QuerySnapshot colisSnapshot =
      await FirebaseFirestore.instance.collection('colisDetails').where('tracking', isEqualTo: tracking).get();

      for (QueryDocumentSnapshot colisDoc in colisSnapshot.docs) {
        String docId = colisDoc.id;
        await _updateDocument(docId, etat);
      }
    }
  }

  Future<void> _updateDocument(String docId, String etat) async {
    try {
      // Update the document with the required fields
      await FirebaseFirestore.instance.collection('colisDetails').doc(docId).update({
        'etat': etat,
      });
      print('Document $docId updated successfully.');
    } catch (e) {
      print('An error occurred while updating the document: $e');
    }
  }

  @override
  Widget build(BuildContext context) {

    Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
      await showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (BuildContext ctx) {
            return Container(
              padding: EdgeInsets.all(16),
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
                      onPressed: (){

                        String cartonId = documentSnapshot?.id ?? '';
                        if (cartonId.isNotEmpty) {
                           _colisStream.doc(cartonId).update({'etat': selectedtype});
                          Fluttertoast.showToast(msg: "L'état du carton a été modifié avec succès");
                           _startListeningToCartons();
                           Navigator.pop(ctx);
                        }

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
            child: TextField(
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search), hintText: 'Recherche...'),
              onChanged: (val) {
                setState(() {
                  tracking = val;
                });
              },
            ),
          )),
      body: StreamBuilder(
        stream: _colisStream.snapshots(),
        builder: (context, snapshot) {

          List<QueryDocumentSnapshot> cartonDocs = snapshot.data!.docs;
          return (snapshot.connectionState == ConnectionState.waiting)
              ? const Center(
            child: CircularProgressIndicator(),
          )
              : ListView.builder(
              itemCount: cartonDocs.length,
              itemBuilder: (context, index) {
                 DocumentSnapshot documentSnapshot = cartonDocs[index];
                if (tracking.isEmpty) {
                  return Card(
                      child: ListTile(
                          title: Text(
                           '${cartonDocs[index]['tracking']}',
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${cartonDocs[index]['etat']}',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: IconButton(
                              onPressed: () {
                                _update(documentSnapshot);
                                /*trackingCartonEditingController.text =
                                cartonDocs[index]['tracking'];*/
                                selectedtype =
                                '${cartonDocs[index]['etat']}';
                              },
                              icon: Icon(Icons.edit, color: Colors.blue)),
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
                if (cartonDocs[index]['tracking']
                    .toString()
                    .toLowerCase()
                    .startsWith(tracking.toLowerCase())) {
                  return Card(
                    child: ListTile(
                      title: Text(
                        cartonDocs[index]['tracking'],
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        cartonDocs[index]['etat'],
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }
                return Container();
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


}
