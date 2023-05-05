import 'package:flutter/material.dart';
import 'package:shopping_list/models/grocery_item.dart';

class ShoppingListItem extends StatelessWidget {
  const ShoppingListItem(this.item, this.onDismissed, {Key? key}) : super(key: key);

  final GroceryItem item;
  final Function(GroceryItem) onDismissed;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item),
      onDismissed: (_) => onDismissed(item),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 25,
          height: 25,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: item.category.color,
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontSize: 16),
        ),
        trailing: Text(
          "${item.quantity}",
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}
