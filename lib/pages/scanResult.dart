import 'dart:ffi';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:camera/camera.dart';
import 'package:goodsprice/services/boxPainter.dart';
import 'package:goodsprice/services/databaseHelper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';

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
  List<String> _matchedResults = [];

  // Function to edit item name
  void _editItemName() async {
    List<String> matchedResults = [];
    String? _selected;
    bool correctedName = false;
    // Function to get similar results using FuzzyWuzzy
    Future<List<String>> getSimilarResult(String scanned_item_name) async {
      final db = await DatabaseHelper.instance.database;
      final itemNames = await db.rawQuery('''
        SELECT
            item_name
        FROM ItemNames
      ''');

      for (var itemName in itemNames) {
        int score = partialRatio(scanned_item_name.toLowerCase(),
            itemName['item_name'].toString().toLowerCase());
        if (score >= 70) {
          matchedResults.add(itemName['item_name'].toString());
        }
      }
      return matchedResults;
    }

    _matchedResults = await getSimilarResult(_extractedItemName);
    // Convert matchedResults (List<String>) into a list of DropdownMenuEntry
    List<DropdownMenuEntry<String>> dropdownMenuEntries =
        matchedResults.map((item) {
      return DropdownMenuEntry<String>(
        label: item,
        value: item,
      );
    }).toList();

    if (matchedResults.isNotEmpty) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Did you mean"),
            content: DropdownMenu(
              dropdownMenuEntries: dropdownMenuEntries,
              hintText: "Select",
              onSelected: (String? selected) {
                setState(() {
                  _selected = selected!;
                });
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Close dialog
                  Navigator.pop(context);
                },
                child: Text("No"),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _extractedItemName = _selected!;
                    correctedName = true;
                  });
                  Navigator.pop(context);
                },
                child: Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                ),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                ),
              ),
            ],
          );
        },
      );
    }

    TextEditingController controller =
        TextEditingController(text: _extractedItemName);
    if (!correctedName) {
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
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                ),
              ),
            ],
          );
        },
      );
    }
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

  // Function to update database
  Future<void> updateDatabase(
      String extractedItemName, String extractedPrice, String storeName) async {
    // A inner function to get ID
    Future<int?> getIdFromName(Database db, String tableName, String columnId,
        String columnName, String name) async {
      List<Map<String, dynamic>> rows = await db.rawQuery('''
    SELECT $columnId FROM $tableName WHERE $columnName = ?
  ''', [name]);

      return rows.isNotEmpty ? rows.first[columnId] as int : null;
    }

    final db = await DatabaseHelper.instance.database;
    // Update itemName
    await db.execute('''
      INSERT OR IGNORE INTO ItemNames (item_name) VALUES ("$extractedItemName")
      ''');
    // Update storeName
    await db.execute('''
      INSERT OR IGNORE INTO StoreNames (store_name) VALUES ("$storeName")
      ''');

    // Update Price
    int? itemId = await getIdFromName(
        db, "ItemNames", "item_id", "item_name", extractedItemName);
    // debugPrint("ITEM ID = $itemId");
    int? storeId = await getIdFromName(
        db, "StoreNames", "store_id", "store_name", storeName);
    // debugPrint("STORE ID = $storeId");
    await db.execute('''
      INSERT OR REPLACE INTO Price (item_id, store_id, price) VALUES (?, ?, ?)
      ''', [itemId, storeId, extractedPrice]);
  }

  // Function END

  @override
  void initState() {
    super.initState();

    // Fetch from route only once, this is to avoid conflict with setState() when updating corrected price and name;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        final args =
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

        setState(
          () {
            _extractedPrice = args['price'];
            _extractedItemName = args['itemName'];
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    String imagePath = args['imagePath'];
    // _extractedPrice = args['price'];
    // _extractedItemName = args['itemName'];
    Rect priceTagBox = args['priceTagBox'];
    List<TextBlock> textBlocks = args['textBlocks'];
    List<int> imageRes = args['imageRes'];
    String storeName = args['storeName'];

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
                      height: imageRes[0] * constraints.maxWidth / imageRes[1],
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
            ),
            SizedBox(
              height: 10.0,
            ),
            ElevatedButton(
              onPressed: () async {
                updateDatabase(_extractedItemName, _extractedPrice, storeName);
                final snackBar = SnackBar(
                  content: const Text('Successfully submitted!'),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
              child: Text("Submit"),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.amber),
              ),
            )
          ],
        ),
      ),
    );
  }
}
