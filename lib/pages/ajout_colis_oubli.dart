import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AjoutColisPage extends StatefulWidget {
  @override
  _AjoutColisPageState createState() => _AjoutColisPageState();
}

class _AjoutColisPageState extends State<AjoutColisPage> {
  String barcodecolis = '69563258O';
  List<String> numerosColis = [];

  Future<void> sauvegarderColis(String numeroColis) async {
    try {
      await FirebaseFirestore.instance.collection('cartons').add({
        'trackingColis': FieldValue.arrayUnion(numerosColis),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Colis sauvegardé avec succès'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la sauvegarde du colis'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ajouter un colis"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Identité du colis",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  barcodecolis,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    scanBarcodeColis();
                  },
                  child: Text("Scannez le colis"),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                sauvegarderColis(barcodecolis);
              },
              child: Text("Sauvegarder"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> scanBarcodeColis() async {
    final barcodecolis = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666',
      'Cancel',
      true,
      ScanMode.BARCODE,
    );

    if (!mounted) return;

    if (barcodecolis != '-1') {
      setState(() {
        numerosColis.add(barcodecolis); // Ajoutez le numéro de colis à la liste
        this.barcodecolis = barcodecolis;
      });
    }
  }
}








