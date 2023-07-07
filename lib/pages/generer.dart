import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';

class Generer extends StatefulWidget {
  const Generer({Key? key}) : super(key: key);

  @override
  State<Generer> createState() => _GenererState();
}

class _GenererState extends State<Generer> {
  final controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Generer"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: BarcodeWidget(
                  barcode: Barcode.code128(),
                  data: controller.text??'hello world',
                  width: 200,
                  height: 200,
                  drawText: false,
                ),
              ),
              Text(
                controller.text,
                style: TextStyle(fontSize: 20, color: Colors.black54),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(child: buildTextField(context)),
                  const SizedBox(width: 12),
                  FloatingActionButton(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(Icons.done, size: 30),
                    onPressed: () => setState(() {}),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(BuildContext context) => TextField(
        controller: controller,
        style: const TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        decoration: InputDecoration(
          hintText: 'Entrer le donné',
          hintStyle: const TextStyle(color: Colors.grey),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      );
}
