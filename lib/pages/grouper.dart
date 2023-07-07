import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:s_trading/model/colis_list.dart';
import '../model/colis_model.dart';
import 'ajout_grouper.dart';

class Grouper extends StatefulWidget {
  const Grouper({Key? key}) : super(key: key);

  @override
  State<Grouper> createState() => _GrouperState();
}

class _GrouperState extends State<Grouper> {
  final _colisStream =
      FirebaseFirestore.instance.collection("colisGrouper").snapshots();
  String tracking = "";
  final _formKey = GlobalKey<FormState>();
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
  ColisModel colisModel = ColisModel();

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("colisDetails")
        .doc("JyVSFR7VOLJND5Hcibq9")
        .get()
        .then((value) {
      colisModel = ColisModel.fromMap(value.data());
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final trackingCartonfield = TextFormField(
        enabled: false,
        autofocus: false,
        controller: trackingCartonEditingController,
        keyboardType: TextInputType.name,
        validator: (value) {
          if (value!.isEmpty) {
            return ("tracking carton  obligatoire");
          }
          return null;
        },
        onSaved: (value) {
          trackingCartonEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lan),
            contentPadding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
            hintText: "tracking Carton",
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
            return ("tracking carton  obligatoire");
          }
          return null;
        },
        onSaved: (value) {
          trackingEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
            prefixIcon: const Icon(Icons.water),
            contentPadding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
            hintText: "tracking",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            )));

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
          synchro();
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
              trackingCartonfield,
              const SizedBox(
                height: 15,
              ),
              const SizedBox(
                height: 15,
              ),
              trackingfield,
              const SizedBox(
                height: 15,
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
                    if (tracking.isEmpty) {
                      return ListTile(
                        title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                docs[index]['trackingCarton'],
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
                                    trackingEditingController.text =
                                        snapshot.data!.docs[index]['tracking'];
                                    trackingCartonEditingController.text =
                                        snapshot.data!.docs[index]
                                            ['trackingCarton'];
                                    selectedtype =
                                        snapshot.data!.docs[index]['etat'];
                                  },
                                  icon: Icon(Icons.edit, color: Colors.blue))
                            ]),
                        subtitle: Row(
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
                    if (docs[index]['trackingCarton']
                        .toString()
                        .toLowerCase()
                        .startsWith(tracking.toLowerCase())) {
                      return ListTile(
                        title: Text(
                          docs[index]['trackingCarton'],
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
                              docs[index]['tracking'],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AjoutGrouper()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  postDetailsToFirestore() async {
    //calling our firestore
    //calling our user model
    //sending these values
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    ColisCodebarre colisCodebarre = ColisCodebarre();

    //writing all the value
    colisCodebarre.tracking = trackingEditingController.text;
    colisCodebarre.trackingCarton = trackingCartonEditingController.text;
    colisCodebarre.etat = selectedtype;
    colisModel.etat = selectedtype;

    await firebaseFirestore
        .collection("colisGrouper")
        .doc("ymVB2yGZrc9Ctdq6EK9j")
        .update(colisCodebarre.toMap());
    Fluttertoast.showToast(msg: "L'etat du carton a été modifié avec succés");
  }

  void synchro() async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    colisModel.etat = selectedtype;
    await firebaseFirestore
        .collection("colisDetails")
        .doc("JyVSFR7VOLJND5Hcibq9")
        .update({'etat': selectedtype});
    Fluttertoast.showToast(msg: "L'etat du petit colis a été modifié");
  }
}
