import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import '../model/colis_model.dart';
import 'detaille_info_colis.dart';

class ColisListPage extends StatefulWidget {
  @override
  _ColisListPageState createState() => _ColisListPageState();
}

class _ColisListPageState extends State<ColisListPage> {
  List<ColisModel> colisList = [];
  List<ColisModel> allColisList = [];
  List<ColisModel> scannedColisList = [];
  ColisModel? colis;
  final List<String> etat = [
    'Arrivé en chine',
    'En cours d\'envoie',
    'Arrivé à Mada',
    'Récupéré',
    'Retour en chine',
  ];
  List<ColisModel> filteredColisList = [];

  final List<String> modeEnvoie = ['Express', 'Maritimes', 'Batterie'];
  String? selectedEtat, selectedMode;
  String? idToDelete;
  String searchText = '';
  final codeclientFilterController = TextEditingController();
  var selectedtype, selectedtype2;
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  void showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Filtres',
            style: TextStyle(color: Colors.blue),
          ), // Titre du dialogue
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Ajoutez ici vos champs de filtre TextField
                TextField(
                  controller: codeclientFilterController,
                  decoration: InputDecoration(
                    labelText: 'Code client',
                  ),
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Mode d\'envoi',
                  ),
                  value: selectedtype2,
                  onChanged: (value) {
                    setState(() {
                      selectedtype2 = value;
                    });
                  },
                  items: modeEnvoie.map((value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Etat',
                  ),
                  value: selectedtype,
                  onChanged: (value) {
                    setState(() {
                      selectedtype = value;
                    });
                  },
                  items: etat.map((value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Filtrer'), // Bouton de filtrage
              onPressed: () {
                fetchDataWithFilters();
                Navigator.of(context).pop(); // Ferme le dialogue
              },
            ),
            TextButton(
              child: Text('Annuler'), // Bouton d'annulation
              onPressed: () {
                Navigator.of(context).pop(); // Ferme le dialogue
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchDataWithFilters() async {
    setState(() {
      isLoading = true; // Indicate that loading is in progress
    });

    String apiUrl = 'https://s-tradingmadagasikara.com/getColisfiltered.php';

    if (codeclientFilterController.text.isNotEmpty) {
      apiUrl += '?codeClient=${codeclientFilterController.text}';
    }

    if (selectedMode != null) {
      apiUrl += apiUrl.contains('?') ? '&' : '?';
      apiUrl += 'modeEnvoie=${selectedMode}';
    }

    if (selectedEtat != null) {
      apiUrl += apiUrl.contains('?') ? '&' : '?';
      apiUrl += 'etat=${selectedEtat}';
    }

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == 1) {
          final List<dynamic> colisData = jsonData['colis'];
          setState(() {
            colis = colisData.isNotEmpty
                ? ColisModel.fromJson(colisData.first)
                : null;
            colisList =
                colisData.map((json) => ColisModel.fromJson(json)).toList();
            isLoading = false; // Indicate that loading is complete
          });
          print('Fetched filtered colis data: ${colisList.length} items');
        } else {
          print('Failed to load filtered colis list');
          throw Exception('Failed to load filtered colis list');
        }
      } else {
        print('Failed to fetch filtered data from the server');
        throw Exception('Failed to fetch filtered data from the server');
      }
    } catch (error) {
      print('Error: $error');
      setState(() {
        isLoading = false; // Indicate that loading has failed
      });
    }
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http
          .get(Uri.parse('https://s-tradingmadagasikara.com/getColis.php'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == 1) {
          final List<dynamic> colisData = jsonData['colis'];
          setState(() {
            colis = colisData.isNotEmpty
                ? ColisModel.fromJson(colisData.first)
                : null;
            allColisList =
                colisData.map((json) => ColisModel.fromJson(json)).toList();
            colisList = List.from(
                allColisList); // Copiez les données dans la liste non filtrée
            isLoading = false;
          });
          print('Fetched colis data: ${colisList.length} items');
        } else {
          print('Failed to load colis list');
          throw Exception('Failed to load colis list');
        }
      } else {
        print('Failed to fetch data from the server');
        throw Exception('Failed to fetch data from the server');
      }
    } catch (error) {
      print('Error: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Update the colis record
  Future<void> updateColisInAPI(ColisModel colis) async {
    final Map<String, dynamic> data = {
      'id': colis.id,
      'tracking': colis.tracking,
      'codeClient': colis.codeClient,
      'poids': colis.poids,
      'volume': colis.volume,
      'facture': colis.facture,
      'modeEnvoie': colis.modeEnvoie,
      'etat': colis.etat,
    };

    final response = await http.put(
      Uri.parse('https://s-tradingmadagasikara.com/updateColis.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      print('${response.body}');
      Fluttertoast.showToast(msg: "Modification avec succès");
      print('Colis updated successfully');
    } else {
      print('Failed to update colis: ${response.body}');
    }
  }

  void _deleteColis(String idToDelete) async {
    print('ID à supprimer : $idToDelete');

    final response = await http.delete(
      Uri.parse(
          'https://s-tradingmadagasikara.com/deleteColis.php?id=$idToDelete'),
    );

    if (response.statusCode == 200) {
      setState(() {
        colisList.removeWhere((colis) => colis.id == idToDelete);
      });

      print('Colis supprimé avec succès');

      // Ajoutez ici l'appel pour récupérer à nouveau les données
      fetchData();
    } else {
      print('Échec de la suppression du colis: ${response.body}');
    }
  }

  void _showDeleteConfirmationDialog(String? idToDelete) {
    if (idToDelete != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Confirmer la suppression"),
            content: Text("Voulez-vous vraiment supprimer ce colis ?"),
            actions: <Widget>[
              TextButton(
                child: Text("Annuler"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text("Supprimer"),
                onPressed: () {
                  _deleteColis(idToDelete);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      // Gérez le cas où idToDelete est nul
    }
  }

  Future<void> scanBarcode() async {
    final barcode = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666',
      'Annuler',
      true,
      ScanMode.BARCODE,
    );

    if (barcode == '-1') {
      return;
    }

    List<ColisModel> matchingColisList = [];

    for (var colis in colisList) {
      if (colis.tracking == barcode) {
        matchingColisList.add(colis);
      }
    }

    if (matchingColisList.isNotEmpty) {
      setState(() {
        scannedColisList = matchingColisList;
      });
    } else {
      Fluttertoast.showToast(msg: 'Colis non trouvé : $barcode');
    }
  }

  void showEditBottomSheet(ColisModel colis) {
    TextEditingController tempPoidsController = TextEditingController();
    TextEditingController tempVolumeController = TextEditingController();
    TextEditingController tempFactureController = TextEditingController();

    // Copiez les valeurs initiales dans les contrôleurs temporaires
    tempPoidsController.text = colis?.poids?.toString() ?? '';
    tempVolumeController.text = colis?.volume?.toString() ?? '';
    tempFactureController.text = colis?.facture?.toString() ?? '';
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  "Modifier un colis",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Tracking Colis"),
                  controller:
                      TextEditingController(text: colis?.tracking ?? ''),
                  enabled: false,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Code Client"),
                  controller:
                      TextEditingController(text: colis?.codeClient ?? ''),
                  enabled: false,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Poids en kg"),
                  keyboardType: TextInputType.number,
                  controller: tempPoidsController,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Volume en m3"),
                  keyboardType: TextInputType.number,
                  controller: tempVolumeController,
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: "frais de livr + commission en Ar"),
                  keyboardType: TextInputType.number,
                  controller: tempFactureController,
                ),
                DropdownButton<String>(
                  items: etat
                      .map((value) => DropdownMenuItem(
                            value: value,
                            enabled: true,
                            child: Text(
                              value,
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ))
                      .toList(),
                  onChanged: (newSelectedEtat) {
                    setState(() {
                      selectedEtat = newSelectedEtat!;
                      colis?.etat = newSelectedEtat;
                    });
                  },
                  value: selectedEtat ?? colis?.etat,
                  isExpanded: false,
                  hint: const Text(
                    'Choisissez un état',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                DropdownButton<String>(
                  items: modeEnvoie
                      .map((value) => DropdownMenuItem(
                            value: value,
                            enabled: true,
                            child: Text(
                              value,
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ))
                      .toList(),
                  onChanged: (selectedmodeenvoi) {
                    setState(() {
                      selectedMode = selectedmodeenvoi!;
                      colis?.modeEnvoie = selectedmodeenvoi;
                    });
                  },
                  value: selectedMode ?? colis?.modeEnvoie,
                  isExpanded: false,
                  hint: const Text(
                    'Choisissez un mode envoi',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (colis != null) {
                      updateColisInAPI(colis);
                      print("Updated Colis: ${colis.toString()}");
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text("Sauvegarder"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchData().catchError((error) {
      print('Error: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    List<ColisModel> filteredColisList = searchText.isEmpty
        ? scannedColisList.isNotEmpty
            ? scannedColisList
            : colisList
        : scannedColisList.isNotEmpty
            ? scannedColisList.where((colis) {
                return colis.tracking?.contains(searchText) == true ||
                    colis.etat?.contains(searchText) == true;
              }).toList()
            : colisList.where((colis) {
                return colis.tracking?.contains(searchText) == true ||
                    colis.etat?.contains(searchText) == true;
              }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Card(
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.filter_list, color: Colors.blue[400]),
                onPressed: () {
                  showFilterDialog();
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.search,
                  color: Colors.blue,
                ),
                onPressed: () {
                  scanBarcode();
                },
              ),
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: 'Recherche...',
                  ),
                  onChanged: (val) {
                    setState(() {
                      searchText = val;
                      filterColisList();
                    });
                  },
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.clear, // Utilisez l'icône de suppression
                  color: Colors.blue,
                ),
                onPressed: () {
                  searchController.clear();
                  setState(() {
                    searchText = ''; // Réinitialisez la recherche
                    colisList = List.from(
                        allColisList); // Réinitialisez la liste avec toutes les données
                  }); // Effacez le champ de recherche
                },
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                if (scannedColisList.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: scannedColisList.length,
                      itemBuilder: (context, index) {
                        final colis = scannedColisList[index];
                        return buildColisListTile(colis);
                      },
                    ),
                  ),
                if (filteredColisList.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredColisList.length,
                      itemBuilder: (context, index) {
                        final colis = filteredColisList[index];
                        return buildColisListTile(colis);
                      },
                    ),
                  ),
              ],
            ),
    );
  }

  double customCalcul(
      String selectedType, double poids, double volume, int fraisDelivraison) {
    int prixExpress = 88000;
    int prixBatterie = 185000;
    int prixMaritime = 2136000;

    double resd = 0.0;
    double res2 = 0.0;

    if (selectedType == "Express" && volume == 0) {
      resd = prixExpress * poids;
      return resd + fraisDelivraison;
    }

    if (selectedType == "Express" && volume < 0.006 && poids == 0) {
      resd = volume * prixExpress;
      res2 = (resd / 0.006);
      return res2 + fraisDelivraison;
    }

    if (selectedType == "Express" && volume > 0.006 && poids == 0) {
      resd = volume * prixExpress;
      return resd + fraisDelivraison;
    }

    if (selectedType == "Maritimes" && poids == 0) {
      resd = volume * prixMaritime;
      return resd + fraisDelivraison;
    }

    if (selectedType == "Batterie" && volume == 0) {
      resd = prixBatterie * poids;
      return resd + fraisDelivraison;
    }

    return 0.0; // Valeur par défaut, vous pouvez ajuster selon votre logique.
  }

  void filterColisList() {
    setState(() {
      filteredColisList =
          scannedColisList.isNotEmpty ? scannedColisList : colisList;
      if (searchText.isNotEmpty) {
        final String searchTerm = searchText.toLowerCase();
        filteredColisList = filteredColisList
            .where((colis) =>
                colis.tracking?.toLowerCase().contains(searchTerm) == true ||
                colis.etat?.toLowerCase().contains(searchTerm) == true)
            .toList();
      }
    });
  }

  Widget buildColisListTile(ColisModel colis) {
    return Card(
      child: ListTile(
        title: Text(
          'Tracking Colis: ${colis.tracking ?? 'Tracking non disponible'}',
          style: const TextStyle(
            fontSize: 20,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'État: ${colis.etat ?? 'État non disponible'}',
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
                showEditBottomSheet(colis);
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.delete,
                color: Colors.blue,
              ),
              onPressed: () {
                if (colis.id != null) {
                  idToDelete = colis.id.toString();
                  _showDeleteConfirmationDialog(idToDelete);
                }
              },
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ColisDetailPage(colis: colis),
            ),
          );
        },
      ),
    );
  }
}
