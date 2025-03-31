import 'package:flutter/material.dart';

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  String selectedStore = "Select store";

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
                onPressed: () {},
              ))),
          Container(
            margin: EdgeInsets.all(50.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/camera');
              },
              child: Text("Capture Image"),
            ),
          ),
          TextButton.icon(
            onPressed: () async {
              dynamic result =
                  await Navigator.pushNamed(context, '/storeSelector');
              setState(() {
                selectedStore = result.toString();
              });
            },
            label: Text(selectedStore),
            icon: Icon(Icons.edit_location),
          )
        ]));
  }
}
