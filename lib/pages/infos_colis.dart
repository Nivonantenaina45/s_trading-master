import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../model/colis_model.dart';

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
                    //minWidth: MediaQuery.of(context).size.width,
                    onPressed: () async {
                     /* ColisModel colisModel = ColisModel();
                      double poidstr =
                          double.parse(poidsEditingController.text);
                      double volumestr =
                          double.parse(poidsEditingController.text);
                      int fraisdelivr =
                          int.parse(fraisdelivraisonEditingController.text);*/

                      //writing all the value
                      /*colisModel.codeClient = codeclientEditingController.text;
                      colisModel.tracking = trackingEditingController.text;
                      colisModel.etat = selectedtype;
                      colisModel.poids = poidstr;
                      colisModel.volume = volumestr;
                      colisModel.frais = fraisdelivr;
                      colisModel.modeEnvoie = selectedtype2;*/
                      await _colisStream
                          .doc(documentSnapshot!.id)
                          .update({'etat':selectedtype});
                      Fluttertoast.showToast(
                          msg: "L'etat du colis a été changé avec succés");
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
                                        color: Colors.blue))
                              ]),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                docs[index]['facture'].toString(),
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
                        ),
                      );
                    }
                    if (docs[index]['tracking']
                        .toString()
                        .toLowerCase()
                        .startsWith(tracking.toLowerCase())) {
                      return Card(
                        child: ListTile(
                          title:Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
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
                                      color: Colors.blue))],
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                docs[index]['facture'].toString(),
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
                        ),
                      );
                    }
                    return Container();
                  });
        },
      ),
    );
  }
}
