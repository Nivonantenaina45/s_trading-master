import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrackingDetailsScreen extends StatefulWidget {
  final String tracking; // Pass the tracking information to this screen

  TrackingDetailsScreen({required this.tracking});

  @override
  _TrackingDetailsScreenState createState() => _TrackingDetailsScreenState();
}

class _TrackingDetailsScreenState extends State<TrackingDetailsScreen> {
  late Stream<DocumentSnapshot?> _trackingDocumentStream;




  @override
  void initState() {
    super.initState();

    // Initialize _trackingDocumentStream inside initState
    _trackingDocumentStream = FirebaseFirestore.instance
        .collection('colisDetails') // Replace with your Firestore collection name
        .where('tracking', isEqualTo: widget.tracking)
        .snapshots()
        .map((QuerySnapshot querySnapshot) {
      if (querySnapshot.size == 0) {
        // If there are no documents with the matching tracking value,
        // return null or a default value as per your requirement
        return null;
      }
      return querySnapshot.docs.first;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Colis Detailles"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<DocumentSnapshot?>(
          stream: _trackingDocumentStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return Text("Information du colis non trouvé");
            }
            final trackingData = snapshot.data!;
            if (trackingData == null) {
              return Text("Information du colis non trouvé");
            }
            return ListView(
              shrinkWrap: true,
              children: [
                InfoCard(
                  label: 'Tracking',
                  value: trackingData['tracking'],
                  color: Colors.white,
                ),
                InfoCard(
                  label: 'Code Client',
                  value: trackingData['codeClient'],
                  color: Colors.white,
                ),
                InfoCard(
                  label: 'Mode Envoie',
                  value: trackingData['modeEnvoie'],
                  color: Colors.white,
                ),

                InfoCard(
                  label: 'Date Saisie',
                  value: formatDateTime(trackingData['dateSaisie'] as Timestamp),
                  color: Colors.white,
                ),
                InfoCard(
                  label: 'Facture',
                  value: '${trackingData['facture'].toString()}Ar',
                  color: Colors.white,
                ),
                if (trackingData['modeEnvoie'] == 'Maritimes')
                  InfoCard(
                    label: 'Volume',
                    value: '${trackingData['volume'].toString()}m3',
                    color: Colors.white,
                  )
                else if (trackingData['modeEnvoie'] == 'Express')
                    InfoCard(
                      label: 'Poids',
                      value: '${trackingData['poids'].toString()}kg',
                      color: Colors.white,
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
  String formatDateTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedDate = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    String formattedTime = '${dateTime.hour}:${dateTime.minute}';
    return '$formattedDate - $formattedTime';
  }
}

class InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  InfoCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
