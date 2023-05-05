import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/categories.dart';

import '../models/grocery_item.dart';

class NewItemScreen extends StatefulWidget {
  const NewItemScreen({Key? key}) : super(key: key);

  @override
  State<NewItemScreen> createState() => _NewItemScreenState();
}

class _NewItemScreenState extends State<NewItemScreen> {
  final _formKey = GlobalKey<FormState>();

  var _enteredName;
  var _enteredQuantity;
  var _enteredCategory = categories[Categories.vegetables]!;
  var _isSending = false;

  _saveItem() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isSending = true;
    });

    final url = Uri.https(
        "flutter-learning-9a6b5-default-rtdb.europe-west1.firebasedatabase.app",
        "shopping-list.json");
    final response = await post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode({
        "name": _enteredName,
        "quantity": _enteredQuantity,
        "category": _enteredCategory.title,
      }),
    );
    if (!context.mounted) return;

    final Map<String, dynamic> data = json.decode(response.body);

    final newItem = GroceryItem(
      id: data["name"],
      name: _enteredName,
      quantity: _enteredQuantity,
      category: _enteredCategory,
    );

    Navigator.pop(context, newItem);
  }

  _resetForm() {
    _formKey.currentState!.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add a new item"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length < 2) {
                    return "Please enter a name";
                  }
                  return null;
                },
                onSaved: (value) => _enteredName = value!,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: "1",
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Quantity"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter a quantity";
                        }
                        //Check if value is an integer
                        if (int.tryParse(value) == null ||
                            int.parse(value) < 1) {
                          return "Please enter a valid number";
                        }
                        return null;
                      },
                      onSaved: (value) => _enteredQuantity = int.parse(value!),
                    ),
                  ),
                  const SizedBox(width: 25),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _enteredCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 15,
                                  height: 15,
                                  margin: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    color: category.value.color,
                                  ),
                                ),
                                Text(category.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) =>
                          setState(() => _enteredCategory = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: _isSending ? null : _resetForm,
                      child: const Text("Reset")),
                  ElevatedButton(
                    onPressed: _isSending ? null : _saveItem,
                    child: _isSending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text("Add Item"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
