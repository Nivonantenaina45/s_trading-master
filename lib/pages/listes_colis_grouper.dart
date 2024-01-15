import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/colis_model.dart';
import 'detaille_info_colis.dart';

class ListColis extends StatefulWidget {
  ListColis({required this.tracking});

  final String tracking;



  @override
  State<ListColis> createState() => _ListColisState();
}

class _ListColisState extends State<ListColis> {
  List<dynamic> trackingColisList = [];
  bool isLoading = true;
  String errorMessage = '';
  int numberOfTrackingColis = 0;
  ColisModel? _fetchedColis;

  @override
  void initState() {
    super.initState();
    _fetchColisDetails(widget.tracking);

  }
  void _deleteColis(String trackingColis) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmer la suppression",
              style: TextStyle(color: Colors.blue)),
          content: const Text(
            "Êtes-vous sûr de vouloir supprimer ce colis ?",
            style: TextStyle(color: Colors.grey),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog

                // Appeler la fonction pour supprimer le trackingColis
                await _performDeleteColis(trackingColis);
              },
              child: const Text("Supprimer"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performDeleteColis(String trackingColis) async {
    // Appeler l'API PHP pour supprimer le trackingColis
    final apiUrl =
        'https://s-tradingmadagasikara.com/deleteTrack.php?trackingColis=$trackingColis';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["success"] == 1) {
          // La suppression a réussi, actualiser la liste
          _fetchColisDetails(widget.tracking);
          // Afficher un message de succès
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Colis supprimé avec succès"),
              backgroundColor: Colors.blue,
            ),
          );
        } else {
          // Afficher un message d'échec
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Erreur lors de la suppression du colis"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Afficher un message d'erreur de requête
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur de requête: ${response.statusCode}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

 /* Future<void> _fetchColisDetails(String trackingCarton) async {
    final apiUrl = 'https://s-tradingmadagasikara.com/cartonfetch.php?trackingCarton=$trackingCarton';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          trackingColisList = data;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load data';
        });
      }

      // Mettez à jour le nombre de colis associés au carton
      numberOfTrackingColis = 0; // Mettez à jour la variable de classe
      List<Future<void>> fetchColisDetailsFutures = [];

      for (int i = 0; i < trackingColisList.length; i++) {
        final tracking = trackingColisList[i]["trackingColis"];
        if (tracking != null) {
          List<String> colisList = tracking.split(',');
          numberOfTrackingColis += colisList.length;

          // Create a list of futures for fetching details for each trackingColis
          fetchColisDetailsFutures.addAll(colisList.map((colisTracking) {
            return _fetchColisDetail(colisTracking);
          }));
        }
      }

      // Wait for all fetchColisDetail operations to complete
      await Future.wait(fetchColisDetailsFutures);

      print("Nombre de colis associés au carton : $numberOfTrackingColis");
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'An error occurred: $e';
      });
    }
  }
*/


  Future<void> _calculateTotal() async {
    double totalWeightExpress = 0;
    double totalWeightBatterie = 0;
    double totalVolumeMaritimes = 0;

    // Liste pour stocker tous les colis de la liste affichée
    List<String> allColisList = [];

    // Calculer les totaux en parcourant la liste des colis affichés
    for (int i = 0; i < trackingColisList.length; i++) {
      final trackingColis = trackingColisList[i]["trackingColis"];
      if (trackingColis != null) {
        List<String> colisList = trackingColis.split(',');
        allColisList.addAll(colisList);
      }
    }

    // Calculer les totaux en parcourant la liste des tous les colis
    for (int j = 0; j < allColisList.length; j++) {
      final colis = allColisList[j];

      // Obtenez le modèle de colis en appelant _fetchColisDetail
      ColisModel? colisModel = await _fetchColisDetail(colis);

      // Ajouter les détails du colis aux totaux appropriés
      if (colisModel != null) {
        if (colisModel.modeEnvoie == "Express") {
          totalWeightExpress += colisModel.poids ?? 0;
        } else if (colisModel.modeEnvoie == "Batterie") {
          totalWeightBatterie += colisModel.poids ?? 0;
        }

        if (colisModel.modeEnvoie == "Maritimes" && colisModel.volume != null) {
          totalVolumeMaritimes += colisModel.volume!;
        }
      }
    }

    // Afficher un dialog avec le total calculé
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Total des colis dans le carton",
              style: TextStyle(color: Colors.blue)),
          content: Text(
            "Le nombre total de colis dans le carton est : ${allColisList.length}\n"
                "Le poids total en mode Express est : $totalWeightExpress\n"
                "Le poids total en mode Batterie est : $totalWeightBatterie\n"
                "Le volume total en mode Maritimes est : $totalVolumeMaritimes",
            style: TextStyle(color: Colors.grey),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer le dialog
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    if (errorMessage.isNotEmpty) {
      return Center(
        child: Text(errorMessage),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.calculate,
              color: Colors.white,
            ),
            onPressed: () {
              _calculateTotal();
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Tracking Carton:",
              style: const TextStyle(
                  fontSize: 24,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              widget.tracking,
              style: const TextStyle(
                  fontSize: 24,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Listes des colis:",
              style: const TextStyle(
                  fontSize: 24,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold),
            ),
            // Display the list of trackingColis
            Expanded(
              child:ListView.builder(
                itemCount: trackingColisList.length,
                itemBuilder: (context, index) {
                  final trackingColis = trackingColisList[index]["trackingColis"];
                  if (trackingColis != null) {
                    // Split the trackingColis string by comma to get individual items
                    List<String> colisList = trackingColis.split(',');
                    // Create a ListTile for each colis
                    List<Widget> colisWidgets = colisList.map((colis) {
                      return GestureDetector(
                        onTap: () async {
                          String trackingColis = colis;
                          print("Numéro de suivi du colis: $trackingColis");

                          // Obtenez le modèle de colis en appelant _fetchColisDetail
                          ColisModel? colisModel = await _fetchColisDetail(trackingColis);

                          if (colisModel != null) {
                            print("Détails du colis: $colisModel");

                            // Utilisez Navigator pour naviguer à la page suivante en passant le modèle de colis comme argument
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ColisDetailPage(colis: colisModel),
                              ),
                            );
                          } else {
                            // Handle the case where _fetchedColis is null
                            print("Erreur: Détails du colis non disponibles");
                          }
                        },
                        child: Card(
                          child: ListTile(
                            title: Text(
                              colis.trim(), // Remove leading/trailing whitespaces
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.blue,
                              ),
                              onPressed: () {
                                _deleteColis(colis.trim());
                              },
                            ),
                          ),
                        ),
                      );
                    }).toList();

                    return Column(
                      children: colisWidgets,
                    );
                  } else {
                    return Container(); // Skip items with null tracking
                  }
                },
              ),
            ),


          ],
        ),
      ),
    );
  }
  Future<void> _fetchColisDetails(String trackingCarton) async {
    final apiUrl = 'https://s-tradingmadagasikara.com/cartonfetch.php?trackingCarton=$trackingCarton';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          trackingColisList = data;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load data';
        });
      }

      int updatedNumberOfTrackingColis = 0; // Mettez à jour la variable de classe
      List<ColisModel> fetchedColisList = [];

      for (int i = 0; i < trackingColisList.length; i++) {
        final tracking = trackingColisList[i]["trackingColis"];
        if (tracking != null) {
          List<String> colisList = tracking.split(',');
          updatedNumberOfTrackingColis += colisList.length;

          // Create a list of futures for fetching details for each trackingColis
          List<Future<void>> fetchColisDetailsFutures = colisList.map((colisTracking) async {
            ColisModel? fetchedColis = await _fetchColisDetail(colisTracking);
            if (fetchedColis != null) {
              fetchedColisList.add(fetchedColis);
            }
          }).toList();

          // Wait for all fetchColisDetail operations to complete
          await Future.wait(fetchColisDetailsFutures);
        }
      }

      // Now, fetchedColisList contains all the details of colis associated with the trackingCarton
      // Use fetchedColisList as needed

      setState(() {
        numberOfTrackingColis = updatedNumberOfTrackingColis;
      });

      print("Nombre de colis associés au carton : $numberOfTrackingColis");

      for (int i = 0; i < fetchedColisList.length; i++) {
        print("Détails du colis $i : ${fetchedColisList[i]}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'An error occurred: $e';
      });
    }
  }



  Future<ColisModel?> _fetchColisDetail(String trackingColis) async {
    final colisApiUrl = 'https://s-tradingmadagasikara.com/getColisFiltred.php?tracking=$trackingColis';

    try {
      final colisResponse = await http.get(Uri.parse(colisApiUrl));

      print("API Response for $trackingColis: ${colisResponse.body}"); // Print the API response

      if (colisResponse.statusCode == 200) {
        final colisData = json.decode(colisResponse.body);

        if (colisData is Map<String, dynamic> && colisData["success"] == 1) {
          final dynamic colisListData = colisData["colis"];

          if (colisListData is List) {
            final List<dynamic> colisList = colisListData;

            if (colisList.isNotEmpty) {
              // Handle the colis details
              ColisModel fetchedColis = ColisModel.fromJson(colisList.first); // Assuming you have a fromJson method in your ColisModel class
              print("Colis details for $trackingColis: $fetchedColis");
              return fetchedColis;
            } else {
              print("No colis details found for $trackingColis");
              return null;
            }
          } else {
            print("Error: 'colis' field is not a List for $trackingColis");
            return null;
          }
        } else {
          print("Error: ${colisData["message"]} for $trackingColis");
          return null;
        }
      } else {
        print("Error fetching colis details, Status Code: ${colisResponse.statusCode} for $trackingColis");
        return null;
      }
    } catch (e) {
      print("Error fetching colis details for $trackingColis: $e");
      return null;
    }
  }


/*void _deleteColis(String tracking) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmer la suppression",
              style: TextStyle(color: Colors.blue)),
          content: const Text(
            "Êtes-vous sûr de vouloir supprimer ce colis ?",
            style: TextStyle(color: Colors.grey),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

              },
              child: const Text("Supprimer"),
            ),
          ],
        );
      },
    );
  }*/
}
