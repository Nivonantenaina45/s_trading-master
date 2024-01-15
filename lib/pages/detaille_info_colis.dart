import 'package:flutter/material.dart';
import '../model/colis_model.dart';

class ColisDetailPage extends StatelessWidget {
  final ColisModel colis;

  ColisDetailPage({required this.colis});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du colis'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard('Tracking:', colis.tracking.toString()),
            _buildInfoCard('État:', colis.etat.toString()),
            _buildInfoCard('Code Client:', colis.codeClient.toString()),
            _buildPoidsOrVolumeCard(),
            _buildInfoCard('Frais:', '${colis.frais ?? 0}Ar'),
            _buildInfoCard('Mode d\'envoi:', colis.modeEnvoie.toString()),
            _buildInfoCard('Facture:', '${colis.facture ?? 0}Ar'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(content, style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoidsOrVolumeCard() {
    String title;
    String content;

    bool isExpressOrBattery = colis.modeEnvoie == 'Express' || colis.modeEnvoie == 'Batterie';
    bool isMaritimes = colis.modeEnvoie == 'Maritimes';

    if (isExpressOrBattery) {
      title = 'Poids:';
      content = '${colis.poids ?? 0} kg';
    } else if (isMaritimes) {
      title = 'Volume:';
      content = '${colis.volume ?? 0} m³';
    } else {
      // Default case
      title = 'Poids or Volume'; // You can customize this based on your requirements
      content = 'Default Content';
    }

    return _buildInfoCard(title, content);
  }
}
