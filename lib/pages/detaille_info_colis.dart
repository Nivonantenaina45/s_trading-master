import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailsInfoColis extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;
  DetailsInfoColis({required this.documentSnapshot});

  @override
  State<DetailsInfoColis> createState() => _DetailsInfoColisState();
}

class _DetailsInfoColisState extends State<DetailsInfoColis> {
  @override
  Widget build(BuildContext context) {
    final bool isMaritimeMode =
        widget.documentSnapshot['modeEnvoie'] == 'Maritimes';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails du colis"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            InfoCard(
              label: 'Tracking',
              value: widget.documentSnapshot['tracking'],
              color: Colors.white,
            ),
            InfoCard(
              label: 'Code Client',
              value: widget.documentSnapshot['codeClient'],
              color: Colors.white,
            ),
            InfoCard(
              label: 'Mode Envoie',
              value: widget.documentSnapshot['modeEnvoie'],
              color: Colors.white,
            ),
            InfoCard(
              label: 'Frais de livraison',
              value: '${widget.documentSnapshot['frais']}Ar',
              color: Colors.white,
            ),
            InfoCard(
              label: 'Net à payer',
              value: '${widget.documentSnapshot['facture']}Ar',
              color: Colors.white,
            ),
            InfoCard(
              label: 'Etat',
              value: widget.documentSnapshot['etat'],
              color: Colors.white,
            ),
            if (!isMaritimeMode)
              InfoCard(
                label: 'Poids',
                value: '${widget.documentSnapshot['poids']}kg',
                color: Colors.white,
              ),
            if (isMaritimeMode)
              InfoCard(
                label: 'Volume',
                value: '${widget.documentSnapshot['volume']}m3',
                color: Colors.white,
              ),
            InfoCard(
              label: 'Date de saisie ',
              value: formatDateTime(widget.documentSnapshot['dateSaisie']),
              color: Colors.white,
            ),
            // Section pour afficher les dates d'état
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('colisDetails')
                  .doc(widget.documentSnapshot.id)
                  .collection('dates')
                  .orderBy('dateEtat', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text(
                    'Aucune date d\'état disponible.',
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold),
                  );
                }

                final dateEtatList = snapshot.data!.docs;
                final Map<String, Timestamp> latestDateByState = {};

                // Parcourez la liste triée et stockez la dernière date pour chaque état
                for (var dateDoc in dateEtatList) {
                  final String etat = dateDoc['etat'];
                  if (!latestDateByState.containsKey(etat)) {
                    latestDateByState[etat] = dateDoc['dateEtat'];
                  }
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dates d\'état:',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                    for (var etat in latestDateByState.keys)
                      Card(
                        child: ListTile(
                          title: Text(
                            formatDateTime(latestDateByState[etat]!),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          subtitle: Text(
                            etat,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
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
