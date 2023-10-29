import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AjoutColisPage extends StatefulWidget {
  final String cartonTracking;

  AjoutColisPage({required this.cartonTracking});
  @override
  _AjoutColisPageState createState() => _AjoutColisPageState();
}

class _AjoutColisPageState extends State<AjoutColisPage> {
  String barcodecolis = '69563258O';
  List<String> numerosColis = [];

  Future<void> sauvegarderColis(String cartonTracking, List<String> colis) async {
    try {
      // Recherchez le document du carton correspondant au tracking donné
      QuerySnapshot cartonQuery = await FirebaseFirestore.instance.collection('cartons').where('tracking', isEqualTo: cartonTracking).get();

      if (cartonQuery.docs.isNotEmpty) {
        DocumentSnapshot cartonDoc = cartonQuery.docs.first;

        List<dynamic> trackingColis = List.from(cartonDoc['trackingColis']);
        trackingColis.addAll(colis);

        // Mettez à jour le document du carton avec les nouveaux colis
        await cartonDoc.reference.update({
          'trackingColis': trackingColis,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Colis sauvegardés avec succès dans le carton $cartonTracking'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Le carton $cartonTracking n\'existe pas.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la sauvegarde du colis: $e'),
        ),
      );
      print('Erreur lors de la sauvegarde du colis: $e');
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
            const Text(
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
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    scanBarcodeColis();
                  },
                  child: const Text("Scannez le colis"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Colors.blue, //background color of button
                  elevation: 3, //elevation of button
                  shape: RoundedRectangleBorder( //to set border radius to button
                      borderRadius: BorderRadius.circular(30)
                  ),
                  padding: EdgeInsets.all(20) //content padding inside button
              ),
              onPressed: () {
                sauvegarderColis(widget.cartonTracking, numerosColis);
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








