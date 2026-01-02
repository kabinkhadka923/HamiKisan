import 'package:flutter/material.dart';
import '../../services/kalimati_storage_service.dart';
import '../../models/weather_models.dart';

class KalimatiItemsScreen extends StatefulWidget {
  const KalimatiItemsScreen({super.key});

  @override
  State<KalimatiItemsScreen> createState() => _KalimatiItemsScreenState();
}

class _KalimatiItemsScreenState extends State<KalimatiItemsScreen> {
  final _storageService = KalimatiStorageService();
  List<MarketPrice> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    await _storageService.initialize();
    final items = await _storageService.loadItems();
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (context) => _ItemFormDialog(
        onSave: (item) async {
          await _storageService.addItem(item);
          _loadItems();
        },
      ),
    );
  }

  void _editItem(int index) {
    showDialog(
      context: context,
      builder: (context) => _ItemFormDialog(
        item: _items[index],
        onSave: (item) async {
          await _storageService.updateItem(index, item);
          _loadItems();
        },
      ),
    );
  }

  void _deleteItem(int index) async {
    await _storageService.deleteItem(index);
    _loadItems();
  }

  void _bulkImport() {
    showDialog(
      context: context,
      builder: (context) => _BulkImportDialog(
        onSave: (items) async {
          for (var item in items) {
            await _storageService.addItem(item);
          }
          _loadItems();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalimati Market Items', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4CAF50),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _bulkImport,
            tooltip: 'Bulk Import',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addItem,
            tooltip: 'Add Single Item',
          ),
        ],
      ),
      body: _items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('No items yet', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                  const SizedBox(height: 8),
                  Text('Tap + to add single item or upload icon for bulk import', 
                    style: TextStyle(color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                ],
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
                    title: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Min: Rs.${item.minPrice.toStringAsFixed(2)} | Max: Rs.${item.maxPrice.toStringAsFixed(2)} | Avg: Rs.${item.avgPrice.toStringAsFixed(2)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editItem(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteItem(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _ItemFormDialog extends StatefulWidget {
  final MarketPrice? item;
  final Function(MarketPrice) onSave;

  const _ItemFormDialog({this.item, required this.onSave});

  @override
  State<_ItemFormDialog> createState() => _ItemFormDialogState();
}

class _ItemFormDialogState extends State<_ItemFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _minController;
  late TextEditingController _maxController;
  late TextEditingController _avgController;
  String _unit = 'केजी';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.productName ?? '');
    _minController = TextEditingController(text: widget.item?.minPrice.toStringAsFixed(0) ?? '');
    _maxController = TextEditingController(text: widget.item?.maxPrice.toStringAsFixed(0) ?? '');
    _avgController = TextEditingController(text: widget.item?.avgPrice.toStringAsFixed(0) ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item == null ? 'Add Item' : 'Edit Item'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name (कृषि उपज)'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _unit,
                decoration: const InputDecoration(labelText: 'Unit (ईकाइ)'),
                items: const [
                  DropdownMenuItem(value: 'केजी', child: Text('केजी (KG)')),
                  DropdownMenuItem(value: 'के.जी.', child: Text('के.जी. (KG)')),
                  DropdownMenuItem(value: 'दर्जन', child: Text('दर्जन (Dozen)')),
                  DropdownMenuItem(value: 'प्रति गोटा', child: Text('प्रति गोटा (Per Piece)')),
                ],
                onChanged: (v) => setState(() => _unit = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _minController,
                decoration: const InputDecoration(labelText: 'Minimum Price (न्यूनतम)'),
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _maxController,
                decoration: const InputDecoration(labelText: 'Maximum Price (अधिकतम)'),
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _avgController,
                decoration: const InputDecoration(labelText: 'Average Price (औसत)'),
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final item = MarketPrice(
                productName: _nameController.text,
                minPrice: double.parse(_minController.text),
                maxPrice: double.parse(_maxController.text),
                avgPrice: double.parse(_avgController.text),
                priceChangePercent: 0,
                location: 'Kathmandu',
                timestamp: DateTime.now(),
                demandIndex: 0.7,
                scarcityIndex: 0.5,
              );
              widget.onSave(item);
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _minController.dispose();
    _maxController.dispose();
    _avgController.dispose();
    super.dispose();
  }
}

class _BulkImportDialog extends StatefulWidget {
  final Function(List<MarketPrice>) onSave;

  const _BulkImportDialog({required this.onSave});

  @override
  State<_BulkImportDialog> createState() => _BulkImportDialogState();
}

class _BulkImportDialogState extends State<_BulkImportDialog> {
  final _textController = TextEditingController();
  String _status = '';

  void _parseAndSave() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      setState(() => _status = 'Please paste data');
      return;
    }

    try {
      final lines = text.split('\n');
      final items = <MarketPrice>[];
      int parsed = 0;

      for (var line in lines) {
        if (line.trim().isEmpty) continue;
        
        // Parse format: ProductName | Unit | Min | Max | Avg
        // Or: ProductName\tUnit\tMin\tMax\tAvg (tab separated)
        final parts = line.contains('|') 
            ? line.split('|').map((e) => e.trim()).toList()
            : line.split('\t').map((e) => e.trim()).toList();
        
        if (parts.length >= 5) {
          try {
            final name = parts[0];
            final minPrice = double.parse(parts[2].replaceAll(RegExp(r'[^0-9.]'), ''));
            final maxPrice = double.parse(parts[3].replaceAll(RegExp(r'[^0-9.]'), ''));
            final avgPrice = double.parse(parts[4].replaceAll(RegExp(r'[^0-9.]'), ''));
            
            items.add(MarketPrice(
              productName: name,
              minPrice: minPrice,
              maxPrice: maxPrice,
              avgPrice: avgPrice,
              priceChangePercent: 0,
              location: 'Kathmandu',
              timestamp: DateTime.now(),
              demandIndex: 0.7,
              scarcityIndex: 0.5,
            ));
            parsed++;
          } catch (e) {
            // Skip invalid lines
          }
        }
      }

      if (items.isEmpty) {
        setState(() => _status = 'No valid items found. Format: Name | Unit | Min | Max | Avg');
        return;
      }

      widget.onSave(items);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully imported $parsed items')),
      );
    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bulk Import Kalimati Items'),
      content: SizedBox(
        width: 600,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Paste data in format:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey.shade100,
              child: const Text(
                'गोलभेडा ठूलो(भारतीय) | केजी | 100 | 110 | 105\n'
                'आलु रातो | के.जी. | 50 | 60 | 55\n'
                'प्याज सुकेको | के.जी. | 32 | 35 | 33.50',
                style: TextStyle(fontSize: 11, fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _textController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Paste all items here (one per line)...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            if (_status.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(_status, style: TextStyle(color: _status.contains('Error') ? Colors.red : Colors.orange)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _parseAndSave,
          child: const Text('Import All'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
