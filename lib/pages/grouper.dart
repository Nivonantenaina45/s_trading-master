import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'ajout_grouper.dart';
import 'listes_colis_grouper.dart';

class Grouper extends StatefulWidget {
  const Grouper({Key? key}) : super(key: key);

  @override
  State<Grouper> createState() => _GrouperState();
}

class _GrouperState extends State<Grouper> {
  List<Map<String, dynamic>> cartons = [];
  List<Map<String, dynamic>> searchResults = [];

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch data from the PHP API when the widget initializes.
  }

  Future<void> fetchData() async {
    final apiUrl = 'https://s-tradingmadagasikara.com/getCarton.php';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON data.
      List<dynamic> data = json.decode(response.body);

      setState(() {
        cartons = data.cast<Map<String, dynamic>>();
      });
    } else {
      // If the server did not return a 200 OK response, throw an exception.
      throw Exception('Failed to load data');
    }
  }
  Future<void> searchByBarcode() async {
    final barcode = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666',
      'Annuler',
      true,
      ScanMode.BARCODE,
    );

    if (barcode == '-1') {
      return;
    }

    List<Map<String, dynamic>> matchingCartons = [];
    for (var carton in cartons) {
      if (carton['trackingCarton'] == barcode) {
        matchingCartons.add(carton);
      }
    }

    setState(() {
      searchResults = matchingCartons;
    });

    if (searchResults.isNotEmpty) {
      print('Cartons trouvés : $searchResults');
    } else {
      Fluttertoast.showToast(msg: 'Aucun carton correspondant : $barcode');
    }
  }
  Future<void> searchByInput(String query) async {
    // Filtrez les cartons en fonction de la saisie de l'utilisateur.
    List<Map<String, dynamic>> matchingCartons = [];
    for (var carton in cartons) {
      if (carton['trackingCarton'].toLowerCase().contains(query.toLowerCase())) {
        matchingCartons.add(carton);
      }
    }

    setState(() {
      searchResults = matchingCartons;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Card(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.search,
                color: Colors.blue,
              ),
              onPressed: () {
                searchByBarcode();
              }, // Use the scanBarcode function here
            ),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Recherche...',
                ),
                onChanged: (val) {
                 searchByInput(val);
                },
              ),
            ),
          ],
        ),
      )),
      body: searchResults.isNotEmpty
          ? ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final trackingCarton = searchResults[index]['trackingCarton'];
          return Card(
            margin: EdgeInsets.all(5),
            child: ListTile(
              title: Text(
                'Tracking Carton: ${trackingCarton}',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Etat: ${searchResults[index]['etat']}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.blue,
                    ),
                    onPressed: () {
                      // Action de modification
                      // Vous pouvez naviguer vers la page de modification ici
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.blue,
                    ),
                    onPressed: () {
                      // Action de suppression
                      // Vous pouvez implémenter la suppression ici
                    },
                  ),
                ],
              ),
            ),
          );
        },
      )
          : ListView.builder(
        itemCount: cartons.length,
        itemBuilder: (context, index) {
          final trackingCarton = cartons[index]['trackingCarton'];
          return Card(
            margin: EdgeInsets.all(5),
            child: ListTile(
              title: Text(
                'Tracking Carton: ${trackingCarton}',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Etat: ${cartons[index]['etat']}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.blue,
                    ),
                    onPressed: () {
                      // Action de modification
                      // Vous pouvez naviguer vers la page de modification ici
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.blue,
                    ),
                    onPressed: () {
                      // Action de suppression
                      // Vous pouvez implémenter la suppression ici
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AjoutGrouper()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
