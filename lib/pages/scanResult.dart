import 'package:flutter/material.dart';
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:goodsprice/models/7eleven.dart';
import 'package:camera/camera.dart';
import 'package:goodsprice/services/boxPainter.dart';

class scanResult extends StatefulWidget {
  const scanResult({super.key});

  @override
  State<scanResult> createState() => _ScanresultState();
}

class _ScanresultState extends State<scanResult> {
  Image? _image; // Holds the Captures image (not to gallery)
  List<String> _extractedText = [];
  String _extractedPrice = "";
  String _extractedItemName = "";
  double constraintWidth = 0;

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
              }, // LMAO
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
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    String imagePath = args['imagePath'];
    _extractedPrice = args['price'];
    _extractedItemName = args['itemName'];
    Rect priceTagBox = args['priceTagBox'];
    List<TextBlock> textBlocks = args['textBlocks'];
    List<int> imageRes = args['imageRes'];

    return Scaffold(
        appBar: AppBar(
          title: Text("Scan Results"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // _image = Image.file(File(imagePath)),
              // _image!.path , tells Dart to trust the image to not be null
              Stack(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      constraintWidth = constraints.maxWidth;
                      // this is determined by EdgeInsets
                      // debugPrint("Image width : ${constraints.maxWidth}");
                      // debugPrint(
                      //     "Image height : ${imageRes[0] * constraints.maxWidth / imageRes[1]}");
                      return SizedBox(
                        // Set dimensions of the image
                        width: constraints.maxWidth,
                        height:
                            imageRes[0] * constraints.maxWidth / imageRes[1],
                        // BoxFit.contain = Ensure all of the image fit the box
                        // BoxFit.cover = The image might be cropped to cover the specified height
                        child: Image.file(File(imagePath), fit: BoxFit.contain),
                      );
                    },
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: TextBoundingBoxPainter(
                        priceTagBox,
                        textBlocks,
                        imageRes,
                        constraintWidth,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40.0),
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
                    0: FlexColumnWidth(3),
                    1: FlexColumnWidth(2),
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
                        child: Text("$_extractedItemName"),
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
