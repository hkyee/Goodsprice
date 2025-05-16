import 'package:flutter/material.dart';
import 'package:goodsprice/constants/scanBoxDimensions.dart';

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  String selectedStore = "Select store";
  // Map<String, Map<String, double>> scanBoxDimensions = {
  //   '7 Eleven': {'width': 250, 'height': 250},
  //   'NSK Trade City': {'width': 20, 'height': 20},
  //   'KK Mart': {'width': 20, 'height': 20},
  //   '99 Speedmart': {'width': 20, 'height': 20},
  //   'Supervalue': {'width': 350, 'height': 150},
  // };
  double scanBoxHeight = 0;
  double scanBoxWidth = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber,
          title: Text("GoodsPrice"),
        ),
        body: Column(children: [
          Container(
              margin: EdgeInsets.fromLTRB(20.0, 100.0, 20.0, 0),
              child: Center(
                  child: ElevatedButton(
                child: Text("Check Price Database"),
                onPressed: () {
                  Navigator.pushNamed(context, '/checkPrice');
                },
              ))),
          Container(
            margin: EdgeInsets.all(50.0),
            child: ElevatedButton(
              onPressed: () {
                // An example to push arguments to new page
                Navigator.pushNamed(
                  context,
                  '/camera',
                  arguments: {
                    'width': scanBoxWidth,
                    'height': scanBoxHeight,
                    'storeName': selectedStore
                  },
                );
              },
              child: Text("Scan Price Tag"),
            ),
          ),
          TextButton.icon(
            onPressed: () async {
              // An example to get variables from page
              dynamic result =
                  await Navigator.pushNamed(context, '/storeSelector');
              setState(() {
                selectedStore = result.toString();
                if (scanBoxDimensions.containsKey(selectedStore)) {
                  scanBoxWidth =
                      (scanBoxDimensions[selectedStore]?['width'] ?? 0);
                  scanBoxHeight =
                      (scanBoxDimensions[selectedStore]?['height'] ?? 0);
                }
              });
            },
            label: Text(selectedStore),
            icon: Icon(Icons.edit_location),
          )
        ]));
  }
}
