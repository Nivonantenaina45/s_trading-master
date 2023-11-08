import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final apiUrl = 'https://s-tradingmadagasikara.com/cartonfetch.php';
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
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'An error occurred: $e';
      });
    }
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
        title: const Text("Détailles"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.calculate,
              color: Colors.white,
            ),
            onPressed: () {
              //_calculateTotal();
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
                    child: ListView.builder(
                      itemCount: trackingColisList.length,
                      itemBuilder: (context, index) {
                        final tracking =
                            trackingColisList[index]["trackingColis"];
                        if (tracking != null) {
                          return GestureDetector(
                            onTap: () {
                              // Handle tap action
                              // You can navigate to the details screen or perform other actions.
                            },
                            child: Card(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        tracking,
                                        style: const TextStyle(
                                            fontSize: 22,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () {
                                          // Add logic to delete the colis
                                          _deleteColis(tracking);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
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

  void _deleteColis(String tracking) {
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
                // Add logic to delete the colis using the 'tracking' value
                // The 'tracking' variable contains the tracking value of the selected item
                // You can use it to perform the deletion.
              },
              child: const Text("Supprimer"),
            ),
          ],
        );
      },
    );
  }
}
