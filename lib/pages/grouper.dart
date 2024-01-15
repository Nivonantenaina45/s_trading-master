import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'ajout_colis_oubli.dart';
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
  final List<String> etat = [
    'Arrivé en chine',
    'En cours d\'envoi',
    'Arrivé à Mada',
    'Récupéré',
    'Retour en chine',
  ];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
     //fetchData();
  }

  Future<List<Map<String, dynamic>>> fetchData() async {
    final apiUrl = 'https://s-tradingmadagasikara.com/getCarton.php';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
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

    print('Search Query: $query');
    print('Matching Cartons: $matchingCartons');

    setState(() {
      searchResults = matchingCartons;
    });
  }

  Future<void> refreshData() async {
    try {
      var updatedData = await fetchData();
      setState(() {
        cartons = updatedData;
      });
    } catch (e) {
      print('Erreur lors de la récupération des données: $e');
    }
  }

  void _showEditBottomSheet(Map<String, dynamic> carton) {
    String? selectedDropdownValue = carton['etat'] ?? etat.first;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Modifier l\'état du carton',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Etat',
                    ),
                    value: selectedDropdownValue,
                    onChanged: (value) {
                      setState(() {
                        selectedDropdownValue = value;
                      });
                    },
                    items: etat.map((value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        var response = await http.put(
                          Uri.parse('https://s-tradingmadagasikara.com/updateCarton.php'),
                          headers: {"Content-Type": "application/json"},
                          body: jsonEncode({
                            'trackingCarton': carton['trackingCarton'],
                            'etat': selectedDropdownValue,
                            'date': DateTime.now().toString(),
                          }),
                        );

                        print('Response status code: ${response.statusCode}');
                        print('Response body: ${response.body}');

                        if (response.statusCode == 200) {
                          Map<String, dynamic> result = json.decode(response.body);

                          if (result.containsKey('success') && result['success'] == true) {
                            Fluttertoast.showToast(msg: "Mise à jour réussie");
                            await refreshData();
                          } else {
                            String errorMessage = result.containsKey('message') ? result['message'] : 'Erreur lors de la mise à jour';
                            Fluttertoast.showToast(msg: errorMessage);
                          }
                        } else {
                          Fluttertoast.showToast(msg: 'Échec de la mise à jour');
                        }
                      } catch (e) {
                        print('Exception during API call: $e');
                        Fluttertoast.showToast(msg: 'Erreur lors de la mise à jour: $e');
                      }

                      Navigator.pop(context);
                    },
                    child: const Text('Enregistrer'),
                  ),
                ],
              ),
            );
          },
        );
      },

    );
  }

  Future<void> deleteAndRefresh(String trackingCarton) async {
    final apiUrl = 'https://s-tradingmadagasikara.com/deleteCarton.php';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {'trackingCarton': trackingCarton},
      );

      if (response.statusCode == 200) {
        print('Suppression réussie');
        fetchData().then((data) {
          setState(() {
            cartons = data;
          });
        });
      } else {
        print('Erreur lors de la suppression du carton: ${response.body}');
      }
    } catch (error) {
      print('Erreur réseau lors de la suppression du carton: $error');
    }
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
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: 'Recherche...',
                  ),
                  onChanged: (val) {
                    searchByInput(searchController.text);

                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Erreur de chargement des données'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Aucune donnée disponible'),
            );
          } else {
            cartons = snapshot.data!;
            return ListView.builder(
              itemCount: searchResults.isEmpty ? cartons.length : searchResults.length,
              itemBuilder: (context, index) {
                final trackingCarton = searchResults.isEmpty
                    ? cartons[index]['trackingCarton']
                    : searchResults[index]['trackingCarton'];
                return Card(
                  margin: const EdgeInsets.all(5),
                  child: ListTile(
                    title: Text(
                      'Tracking Carton: $trackingCarton',
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListColis(tracking: trackingCarton),
                        ),
                      );
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.add,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AjoutColisPage(
                                  cartonTracking: trackingCarton,
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            _showEditBottomSheet(cartons[index]);
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Supprimer le carton"),
                                  content: const Text(
                                    "Voulez-vous vraiment supprimer ce carton ?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Annuler"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        deleteAndRefresh(cartons[index]['trackingCarton']);
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Supprimer"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),

        floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const AjoutGrouper()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
