import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../model/colis_list.dart';

class ListColis extends StatefulWidget {
  ListColis({required this.doc});
  final DocumentSnapshot doc;

  @override
  State<ListColis> createState() => _ListColisState();
}

class _ListColisState extends State<ListColis> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Détailles"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.doc['tracking'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color:Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(widget.doc['etat'],
              style: const TextStyle(fontSize: 18,color: Colors.grey),
            ),
            const SizedBox(height: 10),
            const  Text("Listes des colis",
              style: const TextStyle(fontSize: 24,color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('cartons')
                    .where('tracking', isEqualTo: widget.doc['tracking'])
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error fetching related information'),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No related information available'),
                    );
                  }

                  var cartonDocuments = snapshot.data!.docs;
                  List<dynamic> allTrackingColis = [];

                  for (var cartonDocument in cartonDocuments) {
                    List<dynamic> trackingColis = cartonDocument['trackingColis'];
                    allTrackingColis.addAll(trackingColis);
                  }

                  return ListView.builder(
                    itemCount: allTrackingColis.length,
                    itemBuilder: (context, index) {
                      var tracking = allTrackingColis[index];
                        return Card(
                        child:Column(
                          children: [
                            Row(
                              children: [
                                Text(tracking, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold,color: Colors.grey)),
                                IconButton(
                                  icon: const Icon(Icons.delete,color:Colors.blue),
                                  onPressed: () {
                                    // Ajoutez ici la logique de suppression pour le colis "tracking"
                                    _deleteColis(tracking);
                                  },
                                ),
                              ],
                            )

                          ],
                        )
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _deleteColis(String tracking) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmer la suppression"),
          content: const Text("Êtes-vous sûr de vouloir supprimer ce colis ?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await FirebaseFirestore.instance
                      .collection('cartons')
                      .where('tracking', isEqualTo: widget.doc['tracking'])
                      .get()
                      .then((querySnapshot) {
                    querySnapshot.docs.forEach((doc) async {
                      List<dynamic> trackingColis = doc['trackingColis'];
                      trackingColis.remove(tracking);
                      await doc.reference.update({'trackingColis': trackingColis});
                    });
                  });
                  Fluttertoast.showToast(msg:"Colis supprimé avec succès");
                } catch (error) {
                  Fluttertoast.showToast(msg:"Erreur lors de la suppression du colis");
                }
              },
              child: const Text("Supprimer"),
            ),
          ],
        );
      },
    );
  }

}

