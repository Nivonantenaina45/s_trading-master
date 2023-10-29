import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../model/colis_list.dart';
import 'detaille_info_colis.dart';
import 'tracking_details.dart';

class ListColis extends StatefulWidget {
  ListColis({required this.doc});
  final DocumentSnapshot doc;

  @override
  State<ListColis> createState() => _ListColisState();
}

class _ListColisState extends State<ListColis> {
  List<dynamic> allTrackingColis = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Détailles"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.calculate,color: Colors.white,), // Remplacez par l'icône de votre choix
            onPressed: () {
              _calculateTotal();
            },
          ),
        ],
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
                  allTrackingColis.clear();

                  for (var cartonDocument in cartonDocuments) {
                    List<dynamic> trackingColis = cartonDocument['trackingColis'];
                    allTrackingColis.addAll(trackingColis);
                  }

                  return ListView.builder(
                    itemCount: allTrackingColis.length,
                    itemBuilder: (context, index) {
                      var tracking = allTrackingColis[index];
                        return GestureDetector(
                          onTap: () {
                        // Navigate to DetailsInfoColis screen with the tracking data
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => TrackingDetailsScreen(
                              tracking:tracking,),
                          ),
                        );
                      },
                        child:Card(
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
                            ),
                          ],
                        )
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
  void _calculateTotal() async {
    double total = 0;
    String unit = "";

    for (var tracking in allTrackingColis) {
      QuerySnapshot colisDetailsSnapshot = await FirebaseFirestore.instance
          .collection('colisDetails')
          .where('tracking', isEqualTo: tracking)
          .get();

      colisDetailsSnapshot.docs.forEach((colisDoc) {
        double poids = colisDoc['poids'];
        double volume = colisDoc['volume'];

        String modeEnvoie = colisDoc['modeEnvoie'];

        if (modeEnvoie == 'Maritimes') {
          total += volume;
          unit = "m3";
        } else {
          total += poids;
          unit = "kg";
        }
      });
    }

    if (total > 0) {
      String formattedTotal = total.toStringAsFixed(4);
      String unitLabel = unit == "m3" ? "m3" : "kg";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Total: $formattedTotal $unitLabel'),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.blue,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Aucun document correspondant aux trackings trouvés.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }



  void _deleteColis(String tracking) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmer la suppression",style:TextStyle(color: Colors.blue)),
          content: const Text("Êtes-vous sûr de vouloir supprimer ce colis ?",style:TextStyle(color: Colors.grey),),
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

