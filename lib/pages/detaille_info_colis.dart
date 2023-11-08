import 'package:flutter/material.dart';
import 'dart:convert';

import '../model/colis_model.dart';

class ColisDetailPage extends StatelessWidget {
  final ColisModel colis;

  ColisDetailPage({required this.colis});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détailles du colis'),
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
            _buildInfoCard('Poids:', '${colis.poids ?? 0} kg'),
            _buildInfoCard('Volume:', '${colis.volume ?? 0} m³'),
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
            child: Text(title, style: TextStyle(fontSize:18,fontWeight: FontWeight.bold,color: Colors.grey,)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(content,style: TextStyle(fontSize:18,color: Colors.grey,fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
