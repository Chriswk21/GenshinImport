import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../theme/genshin_theme.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<Item> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    setState(() => _isLoading = true);
    try {
      final items = await ApiService.getItems();
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Failed to fetch items: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? GenshinTheme.accentRed : GenshinTheme.primaryGold,
        content: Text(
          message,
          style: TextStyle(
            color: isError ? Colors.white : GenshinTheme.bgDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _openItemFormDialog({Item? item}) {
    final isEditing = item != null;
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(text: isEditing ? item.name : '');
    final descriptionController = TextEditingController(text: isEditing ? item.description : '');
    final stockController = TextEditingController(text: isEditing ? item.stock.toString() : '');
    final imageController = TextEditingController(text: isEditing ? item.image : '');
    final priceController = TextEditingController(text: isEditing ? item.price.toString() : '');

    String selectedType = isEditing ? item.type : 'Weapon';
    bool isUploading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                isEditing ? '👑 EDIT TEYVAT ITEM' : '👑 INSERT NEW TEYVAT ITEM',
                style: GoogleFonts.cinzel(color: GenshinTheme.primaryGold, fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(labelText: 'Item Name', hintText: 'e.g. Primordial Jade Winged-Spear'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Required: Item name is required.';
                            }
                            if (value.trim().length < 3) {
                              return 'Validation Failure: Name must be at least 3 characters.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: selectedType,
                          decoration: const InputDecoration(labelText: 'Item Type'),
                          dropdownColor: GenshinTheme.bgCard,
                          items: const [
                            DropdownMenuItem(value: 'Weapon', child: Text('Weapon')),
                            DropdownMenuItem(value: 'Artifact', child: Text('Artifact')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() => selectedType = value);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(labelText: 'Description / Lore', hintText: 'Enter weapon background story...'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Required: Description is required.';
                            }
                            if (value.trim().length < 5) {
                              return 'Validation Failure: Description must be at least 5 characters.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: stockController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Stock', hintText: 'e.g. 10'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Required: Stock quantity is required.';
                            }
                            final stock = int.tryParse(value);
                            if (stock == null) return 'Validation Failure: Stock must be a valid integer.';
                            if (stock < 0) return 'Validation Failure: Stock quantity cannot be negative.';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: priceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Price (Mora)', hintText: 'e.g. 1200'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Required: Price value is required.';
                            }
                            final price = double.tryParse(value);
                            if (price == null) return 'Validation Failure: Price must be a valid number.';
                            if (price < 0) return 'Validation Failure: Price cannot be negative.';
                            return null;
                          },
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: GenshinTheme.buildItemImage(
                                    imageController.text,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    iconSize: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: isUploading
                                      ? const Center(child: CircularProgressIndicator(color: GenshinTheme.primaryGold))
                                      : ElevatedButton.icon(
                                          icon: const Icon(Icons.upload_file),
                                          label: Text(
                                            imageController.text.isNotEmpty ? 'CHANGE IMAGE' : 'UPLOAD IMAGE',
                                            style: GoogleFonts.cinzel(fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: GenshinTheme.bgCard,
                                            foregroundColor: GenshinTheme.primaryGold,
                                            side: const BorderSide(color: GenshinTheme.primaryGold, width: 1.2),
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                          ),
                                          onPressed: () async {
                                            final ImagePicker picker = ImagePicker();
                                            setDialogState(() => isUploading = true);
                                            
                                            try {
                                              final XFile? imageFile = await picker.pickImage(
                                                source: ImageSource.gallery,
                                                imageQuality: 85,
                                              );
                                              
                                              if (imageFile != null) {
                                                final bytes = await imageFile.readAsBytes();
                                                final uploadResult = await ApiService.uploadImage(bytes, imageFile.name);
                                                
                                                if (uploadResult['success'] == true) {
                                                  setDialogState(() {
                                                    imageController.text = uploadResult['imageUrl'];
                                                    isUploading = false;
                                                  });
                                                  _showSnackBar('Image uploaded successfully from device!');
                                                } else {
                                                  setDialogState(() => isUploading = false);
                                                  _showSnackBar(uploadResult['message'] ?? 'Image upload failed.', isError: true);
                                                }
                                              } else {
                                                setDialogState(() => isUploading = false);
                                              }
                                            } catch (e) {
                                              setDialogState(() => isUploading = false);
                                              _showSnackBar('Image Picker Error: $e', isError: true);
                                            }
                                          },
                                        ),
                                ),
                              ],
                            ),
                            
                            FormField<String>(
                              validator: (value) {
                                if (imageController.text.isEmpty) {
                                  return 'Required: Please pick and upload an image.';
                                }
                                return null;
                              },
                              builder: (state) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (state.hasError)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          state.errorText!,
                                          style: const TextStyle(
                                            color: GenshinTheme.accentRed,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) {
                      _showSnackBar('Form Validation failed. Please fix form errors.', isError: true);
                      return;
                    }

                    final token = Provider.of<AuthProvider>(context, listen: false).token;
                    if (token == null) return;
                    final navigator = Navigator.of(context);

                    final payload = {
                      'name': nameController.text.trim(),
                      'type': selectedType,
                      'description': descriptionController.text.trim(),
                      'stock': int.parse(stockController.text),
                      'image': imageController.text.trim(),
                      'price': double.parse(priceController.text),
                    };

                    Map<String, dynamic> response;
                    if (isEditing) {
                      response = await ApiService.updateItem(token, item.id, payload);
                    } else {
                      response = await ApiService.createItem(token, payload);
                    }

                    if (response['success'] == true) {
                      if (mounted) _showSnackBar(isEditing ? 'Item updated successfully!' : 'Item inserted successfully!');
                      navigator.pop();
                      _fetchItems();
                    } else {
                      if (mounted) _showSnackBar(response['message'] ?? 'Write request failed.', isError: true);
                    }
                  },
                  child: Text(isEditing ? 'UPDATE' : 'INSERT'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(Item item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            '⚠️ BANISH WEAPON',
            style: GoogleFonts.cinzel(color: GenshinTheme.accentRed, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to permanently delete "${item.name}" from the database? This action is irreversible.',
            style: GoogleFonts.inter(color: GenshinTheme.textParchment),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: GenshinTheme.accentRed,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final token = Provider.of<AuthProvider>(context, listen: false).token;
                if (token == null) return;
                final navigator = Navigator.of(context);

                final response = await ApiService.deleteItem(token, item.id);
                if (response['success'] == true) {
                  if (mounted) _showSnackBar('"${item.name}" has been deleted.');
                  navigator.pop();
                  _fetchItems();
                } else {
                  if (mounted) _showSnackBar(response['message'] ?? 'Delete operation failed.', isError: true);
                  navigator.pop();
                }
              },
              child: const Text('DELETE'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: GenshinTheme.bgCard,
        iconTheme: const IconThemeData(color: GenshinTheme.primaryGold),
        title: Text(
          'INVENTORY MANAGEMENT',
          style: GoogleFonts.cinzel(
            color: GenshinTheme.primaryGold,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: GenshinTheme.primaryGold, size: 28),
            tooltip: 'Add New Item',
            onPressed: () => _openItemFormDialog(),
          ),
        ],
      ),
      body: Container(
        decoration: GenshinTheme.mysticBackground,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: GenshinTheme.primaryGold))
            : _items.isEmpty
                ? Center(
                    child: Text(
                      'No inventory to display. Press + to add a weapon.',
                      style: GoogleFonts.cinzel(color: GenshinTheme.textMuted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: GenshinTheme.buildItemImage(
                              item.image,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              iconSize: 20,
                            ),
                          ),
                          title: Text(
                            item.name,
                            style: GoogleFonts.cinzel(
                              fontWeight: FontWeight.bold,
                              color: GenshinTheme.primaryGold,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Type: ${item.type} | Stock: ${item.stock}',
                                style: GoogleFonts.inter(color: GenshinTheme.textMuted, fontSize: 12),
                              ),
                              Text(
                                '${item.price.toStringAsFixed(0)} Mora',
                                style: GoogleFonts.inter(
                                  color: GenshinTheme.textParchment,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.amber),
                                onPressed: () => _openItemFormDialog(item: item),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: GenshinTheme.accentRed),
                                onPressed: () => _confirmDelete(item),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
