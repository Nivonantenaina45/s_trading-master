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
        title: Text("Détailles"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.doc['trackingCarton'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color:Colors.grey),
            ),
            SizedBox(height: 8),
            Text(widget.doc['etat'],
              style: TextStyle(fontSize: 18,color: Colors.grey),
            ),
            SizedBox(height: 16),
           const  Text(
              'Listes des petits colis:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color:Colors.grey),
            ),
            SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('colisGrouper')
                    .where('trackingCarton', isEqualTo: widget.doc['trackingCarton']) // Assuming 'itemId' is the field in 'related_info' collection that corresponds to 'title'
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error fetching related information'),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text('No related information available'),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      String tracking = doc['tracking'];
                      return Card(
                        child: ListTile(
                          title: Text(tracking, style: TextStyle(fontSize: 18,color: Colors.grey))
                          // You can add more fields as needed
                        ),
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

