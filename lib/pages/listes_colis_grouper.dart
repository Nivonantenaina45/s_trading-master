import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
                            Text(tracking, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,color: Colors.grey)),
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
}

