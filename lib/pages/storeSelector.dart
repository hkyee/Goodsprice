import 'package:flutter/material.dart';

class storeSelector extends StatefulWidget {
  const storeSelector({super.key});

  @override
  State<storeSelector> createState() => _storeSelectorState();
}

class _storeSelectorState extends State<storeSelector> {
  Map<String, String> Stores = {
    '7 Eleven': '7eleven.png',
    'NSK Trade City': 'NSK.jpg',
    'KK Mart': 'KK_Mart.png',
    '99 Speedmart': '99SM.png',
    'NSK Trade City': 'NSK.jpg',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text("Choose a Store"),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: Stores.length,
        itemBuilder: (context, index) {
          List<String> storeNames = Stores.keys.toList();
          List<String> storeLogos = Stores.values.toList();
          return Card(
            child: ListTile(
              onTap: () {
                Navigator.pop(context, storeNames[index]);
              },
              leading: SizedBox(
                width: 100,
                child: Image.asset("assets/" + storeLogos[index]),
              ),
              title: Text(storeNames[index]),
            ),
          );
        },
      ),
    );
  }
}
