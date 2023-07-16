import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:s_trading/model/colis_list.dart';
import '../model/colis_model.dart';
import 'ajout_grouper.dart';
import 'listes_colis_grouper.dart';

class Grouper extends StatefulWidget {
  const Grouper({Key? key}) : super(key: key);

  @override
  State<Grouper> createState() => _GrouperState();
}

class _GrouperState extends State<Grouper> {
  final _colisStream = FirebaseFirestore.instance.collection("colisGrouper");
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
  User? user = FirebaseAuth.instance.currentUser;

  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("colisDetails")
        .doc(user!.uid)
        .get()
        .then((value) {
      colisrep = ColisModel.fromMap(value.data());
      setState(() {});
    });
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
                  TextFormField(
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
                          ))),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                      enabled: false,
                      autofocus: false,
                      controller: trackingCartonEditingController,
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
                      onPressed: () {
                        colisCodebarre.etat = selectedtype;
                        _colisStream
                            .doc(documentSnapshot!.id)
                            .update({'etat': selectedtype});
                        Fluttertoast.showToast(
                            msg: "L'etat du carton a été modifié avec succés");
                        updateCollectionsIfConditionMet();
                        /*if (colisCodebarre.tracking == colisModel.tracking) {
                          final colisref1 =
                              firebaseFirestore.collection("colisDetails");
                          colisModel.etat = selectedtype;
                          colisref1
                              .doc(documentSnapshot!.id)
                              .update({'etat': selectedtype});
                          Fluttertoast.showToast(
                              msg: "L'etat du petit colis a été modifié");
                        }*/
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
          var docs = snapshot.data!.docs;

          return (snapshot.connectionState == ConnectionState.waiting)
              ? const Center(
                  child: CircularProgressIndicator(),
                )

              : ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot documentSnapshot = docs[index];
                    if (tracking.isEmpty) {
                      return Card(
                          child: ListTile(
                              title: Text(
                                docs[index]['trackingCarton'],
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                docs[index]['etat'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: IconButton(
                                  onPressed: () {
                                    _update(documentSnapshot);
                                    trackingEditingController.text =
                                        snapshot.data!.docs[index]['tracking'];
                                    trackingCartonEditingController.text =
                                        snapshot.data!.docs[index]
                                            ['trackingCarton'];
                                    selectedtype =
                                        snapshot.data!.docs[index]['etat'];
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
                    if (docs[index]['trackingCarton']
                        .toString()
                        .toLowerCase()
                        .startsWith(tracking.toLowerCase())) {
                      return Card(
                        child: ListTile(
                          title: Text(
                            docs[index]['trackingCarton'],
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            docs[index]['etat'],
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
  void updateCollectionsIfConditionMet() async {
    try {
      // Get a Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Start a batch write
      WriteBatch batch = firestore.batch();

      // Step 1: Retrieve the data that matches the condition from both collections
      QuerySnapshot collection1Snapshot =
      await firestore.collection('colisDetails').where('tracking', isEqualTo: trackingEditingController.text).get();

      // Step 2: Check if both documents are found
      if (collection1Snapshot.docs.isNotEmpty ) {
        // Step 3: Perform updates in both collections
        batch.update(collection1Snapshot.docs[0].reference, {'etat': selectedtype});

        // Step 4: Commit the batched write
        await batch.commit();
        print('Batch write successfully committed.');
      } else {
        print('Documents not found or condition not met. Batch write aborted.');
      }
    } catch (e) {
      print('Error performing batch write: $e');
    }
  }
}
