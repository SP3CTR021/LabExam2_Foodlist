import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'crud_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CrudService service = CrudService();
  final TextEditingController nameCtrl = TextEditingController();

  bool showFavorites = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LabExam2_Belena'),
        centerTitle: true,

        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                showFavorites = !showFavorites;
              });
            },
            icon: Icon(
              showFavorites ? Icons.favorite : Icons.favorite_border,
              color: const Color.fromARGB(255, 31, 92, 235),
            ),
          ),
        ],
      ),

      // ADD ITEM
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 6, 68, 185),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => openAddDialog(context),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream:
            showFavorites // if pressed kay makita ang fave list
            ? service.getFavoriteItems()
            : service.getItems(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Text(
                showFavorites ? "No favorite items!" : "No items found!",
                style: const TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(7),
            itemCount: docs.length,

            itemBuilder: (context, index) {
              final item = docs[index];
              final data = item.data() as Map<String, dynamic>;

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(12),
                ),

                margin: const EdgeInsets.symmetric(vertical: 6),

                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),

                  title: Text(
                    data['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () =>
                            addFavorite(item.id, data['isFavorite'] ?? false),
                        icon: Icon(
                          data['isFavorite'] ?? false
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: const Color.fromARGB(255, 27, 118, 175),
                        ),
                      ),

                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => openEditDialog(context, item),
                      ),

                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, item.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // FAVORITE
  void addFavorite(String id, bool currentFavorite) {
    service.updateFavorite(id, !currentFavorite);
  }

  // DELETE UI
  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Item"),

        content: const Text("Are you sure you want to delete this item?"),

        actions: [
          TextButton(
            onPressed: () {
              service.deleteItems(id);
              Navigator.pop(context);
            },

            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  // ADD UI
  void openAddDialog(BuildContext context) {
    nameCtrl.clear();

    showDialog(
      context: context,

      builder: (_) => AlertDialog(
        title: const Text("Add Item"),

        content: TextField(
          controller: nameCtrl,

          decoration: InputDecoration(
            labelText: "Name",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),

            child: const Text('Cancel'),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 60, 139, 242),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),

            onPressed: () async {
              if (nameCtrl.text.isNotEmpty) {
                await service.addItems(nameCtrl.text);

                if (context.mounted) Navigator.pop(context);
              }
            },

            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // EDIT UI
  void openEditDialog(BuildContext context, DocumentSnapshot item) {
    final data = item.data() as Map<String, dynamic>;
    nameCtrl.text = data['name'] ?? '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Item"),
        content: TextField(
          controller: nameCtrl,
          decoration: InputDecoration(
            labelText: "Name",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                service.updateItems(item.id, nameCtrl.text);
                Navigator.pop(context);
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 51, 158, 211),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
