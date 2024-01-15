import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AjoutColisPage extends StatefulWidget {
  final String cartonTracking;

  AjoutColisPage({required this.cartonTracking});
  @override
  _AjoutColisPageState createState() => _AjoutColisPageState();
}

class _AjoutColisPageState extends State<AjoutColisPage> {
  String barcodecolis = '69563258O';
  List<String> numerosColis = [];

  Future<void> sauvegarderColis(
      String cartonTracking, String trackingColis) async {
    final apiUrl = 'https://s-tradingmadagasikara.com/addColisforget.php';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'cartonTracking': cartonTracking,
          'trackingColis': trackingColis,
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Colis ajouter avec succés'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${responseData['message']}'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Échec de la requête HTTP, code: ${response.statusCode}'),
          ),
        );
      }
    } catch (error) {
      print('Erreur lors de la requête HTTP: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la requête HTTP: $error'),
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
                  primary: Colors.blue,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding: EdgeInsets.all(20)),
              onPressed: () {
                if (numerosColis.isNotEmpty) {
                  for (String barcode in numerosColis) {
                    sauvegarderColis(widget.cartonTracking, barcode);
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Aucun colis scanné. Veuillez scanner un colis avant de sauvegarder.'),
                    ),
                  );
                }
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
        numerosColis.add(barcodecolis);
        this.barcodecolis = barcodecolis;
      });
    }
  }
}
