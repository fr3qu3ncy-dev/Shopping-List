import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/categories.dart';
import 'package:shopping_list/widgets/shopping_list_item.dart';

import '../models/grocery_item.dart';
import 'new_item_screen.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({Key? key}) : super(key: key);

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final List<GroceryItem> _items = [];
  late Future<List<GroceryItem>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _itemsFuture = _loadItems();
  }

  Future<List<GroceryItem>> _loadItems() async {
    final url = Uri.https(
        "flutter-learning-9a6b5-default-rtdb.europe-west1.firebasedatabase.app",
        "shopping-list.json");

    final response = await get(url);

    if (response.statusCode >= 400) {
      throw Exception("Failed to load items: ${response.body}");
    }

    if (response.body == "null") {
      return [];
    }

    final newItems = <GroceryItem>[];
    Map<String, dynamic> dataMap = json.decode(response.body);
    for (final item in dataMap.entries) {
      final name = item.value["name"];
      int quantity = item.value["quantity"];
      String category = item.value["category"];

      newItems.add(
        GroceryItem(
            id: item.key,
            name: name,
            quantity: quantity,
            category:
                categories[Categories.values.byName(category.toLowerCase())] ??
                    categories[Categories.vegetables]!),
      );
    }
    return newItems;
  }

  _addItem() async {
    final newItem = await Navigator.push<GroceryItem>(context,
        MaterialPageRoute(builder: (context) => const NewItemScreen()));

    if (newItem == null) return;

    setState(() {
      _items.add(newItem);
    });
  }

  _removeItem(GroceryItem item) async {
    final index = _items.indexOf(item);
    setState(() {
      _items.remove(item);
    });

    final url = Uri.https(
        "flutter-learning-9a6b5-default-rtdb.europe-west1.firebasedatabase.app",
        "shopping-list/${item.id}.json");

    final response = await delete(url);

    if (response.statusCode >= 400) {
      setState(() {
        _items.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Groceries"),
        actions: [
          IconButton(
            onPressed: () => _addItem(),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24)),
              );
            }
            if (snapshot.data!.isEmpty) {
              return const Center(
                child: Text('No items found.\nTry adding some!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24)),
              );
            }

            _items.addAll(snapshot.data as List<GroceryItem>);
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) =>
                  ShoppingListItem(snapshot.data![index], _removeItem),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
