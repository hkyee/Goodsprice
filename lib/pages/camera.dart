import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:goodsprice/models/7eleven.dart';

class scanResult extends StatefulWidget {
  const scanResult({super.key});

  @override
  State<scanResult> createState() => _cameraState();
}

class _cameraState extends State<scanResult> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image; // Holds the Captures image (not to gallery)
  List<String> _extractedText = [];
  String _extractedPrice = "";
  String _extractedItemName = "";

  // Function to edit item name
  void _editItemName() {
    TextEditingController controller =
        TextEditingController(text: _extractedItemName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Item Name"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: "Enter correct item name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Close dialog
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _extractedItemName = controller.text;
                });
                Navigator.pop(context);
              },
              child: Text(
                "Save",
                style: TextStyle(color: Colors.white),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  // Function to edit price name
  void _editPrice() {
    TextEditingController controller =
        TextEditingController(text: _extractedPrice);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Price"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: "Enter correct price"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Close dialog
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _extractedPrice = controller.text;
                });
                Navigator.pop(context);
              },
              child: Text(
                "Save",
                style: TextStyle(color: Colors.white),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  // Function END

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Capture Image"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _image == null
                  ? Text("No image selected")
                  // _image!.path , tells Dart to trust the image to not be null
                  : Image.file(
                      File(_image!.path),
                      height: 200.0,
                    ), // Show iamge without saving
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      _image = await openCamera(context);
                      setState(() {
                        _image = _image;
                        // Could be redundant
                      });
                    },
                    child: Text("Open Camera"),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        _extractedText = await scanText(File(_image!.path));
                        _extractedPrice = extractPriceData(_extractedText);
                        setState(() {
                          _extractedPrice = _extractedPrice;
                        });
                      },
                      child: Text("Scan for Prices")),
                ],
              ),
              SizedBox(height: 20.0),
              Text(
                "Extracted Text:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Table(
                  // Adds border
                  border: TableBorder.all(),
                  columnWidths: {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(3),
                  },
                  children: [
                    TableRow(children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Item Name",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Price",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ]),
                    TableRow(children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("item_name"),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("$_extractedPrice"),
                      )
                    ])
                  ],
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _editItemName();
                    },
                    child: Text("Edit item name"),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.amber),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _editPrice();
                    },
                    child: Text("Edit price"),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.amber),
                    ),
                  ),
                ],
              )
            ],
          ),
        ));
  }
}
