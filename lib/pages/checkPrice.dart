import 'package:flutter/material.dart';
import 'package:goodsprice/services/databaseHelper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:goodsprice/constants/stores.dart';

class checkPrice extends StatefulWidget {
  const checkPrice({super.key});

  @override
  State<checkPrice> createState() => _checkPriceState();
}

class _checkPriceState extends State<checkPrice> {
  List<Map<String, dynamic>>? _results;

  // Function to obtain the item names and stores
  Future<List<Map<String, dynamic>>> suggestionBuilder(String input) async {
    final db = await DatabaseHelper.instance.database;
    return await db.rawQuery('''
        SELECT
            item_name
        FROM ItemNames
        WHERE item_name LIKE ?
      ''', ['%$input%']);
  }

  // FUnction to query the database of the item name, return a list of stores and price
  Future<List<Map<String, dynamic>>> queryPriceData(String item_name) async {
    final db = await DatabaseHelper.instance.database;
    return await db.rawQuery('''
        SELECT
            StoreNames.store_name,
            Price.price
        FROM Price
        JOIN StoreNames ON StoreNames.store_id = Price.store_id
        JOIN ItemNames ON ItemNames.item_id = Price.item_id
        WHERE ItemNames.item_name LIKE ?
      ''', ['%$item_name%']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Check price"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SearchAnchor(
              viewBackgroundColor: Colors.grey[200],
              builder: (BuildContext context, SearchController controller) {
                return SearchBar(
                  controller: controller,
                  padding: const WidgetStatePropertyAll<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                  // When user taps on the search bar
                  onTap: () {
                    controller.openView();
                  },
                  // For showing and hiding suggestions
                  onTapOutside: (_) {
                    FocusScope.of(context).unfocus(); // Exit typing mode
                  },

                  // Called everytime when the text in the Search Bar changes
                  onChanged: (_) {
                    controller.openView();
                  },
                  // Called everytune when Enter is pressed
                  onSubmitted: (_) {},

                  leading: const Icon(Icons.search),
                  hintText: "Enter item name",
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                  autoFocus: true,
                  elevation: MaterialStateProperty.all(0),
                );
              },
              suggestionsBuilder:
                  (BuildContext context, SearchController controller) async {
                final String input = controller.value.text;
                List<Map<String, dynamic>> options =
                    await suggestionBuilder(input);
                return options.map(
                  (option) {
                    return ListTile(
                      title: Text(option['item_name']),
                      onTap: () async {
                        controller.closeView(option['item_name']);
                        List<Map<String, dynamic>> results =
                            await queryPriceData(option['item_name']);
                        setState(() {
                          _results = results;
                        });
                      },
                    );
                  },
                ).toList();
              },
            ),
            _results != null && _results!.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                      // [{'store_name' : XXX, 'price' : 0.1} , {}, {}]
                      itemCount: _results!.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            onTap: () {},
                            leading: SizedBox(
                              width: 100,
                              child: Image.asset(
                                  "assets/${Stores[_results![index]["store_name"]]}"),
                            ),
                            title: Text(
                                "RM    ${_results![index]["price"].toStringAsFixed(2)}"),
                          ),
                        );
                      },
                    ),
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
