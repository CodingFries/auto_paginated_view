import 'package:auto_paginated_view/auto_paginated_view.dart';
import 'package:flutter/material.dart';

import '../data/mock_data_service.dart';

/// Example showing how to use AutoPaginatedView with a basic ListView
class ListViewExample extends StatefulWidget {
  const ListViewExample({super.key});

  @override
  State<ListViewExample> createState() => _ListViewExampleState();
}

class _ListViewExampleState extends State<ListViewExample> {
  final MockDataService _dataService = MockDataService();
  List<Map<String, dynamic>> _items = [];
  int _currentPage = 0;
  bool _hasMoreItems = true;

  @override
  void initState() {
    super.initState();
    // Initialize the data service with text items
    _dataService.initDataStore('text');
  }

  /// Load more items from the mock data service
  Future<String?> _loadMoreItems() async {
    try {
      final newItems = await _dataService.getItems('text', _currentPage);

      if (newItems.isEmpty) {
        setState(() {
          _hasMoreItems = false;
        });
        return null;
      }

      setState(() {
        _items.addAll(newItems.cast<Map<String, dynamic>>());
        _currentPage++;
        _hasMoreItems = _dataService.hasMoreItems('text', _currentPage);
      });

      return null; // Success
    } catch (e) {
      return e.toString(); // Return the error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ListView Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _currentPage = 0;
                _items = [];
                _hasMoreItems = true;
                _dataService.clearData('text');
              });
            },
          ),
        ],
      ),
      body: AutoPaginatedView(
        // The list of items to display
        items: _items,

        // Whether we have loaded all available items
        hasReachedEnd: !_hasMoreItems,

        // Function to load more items when the user scrolls to the end
        onLoadMore: _loadMoreItems,

        // Height for the empty state when no items are available
        emptyStateHeight: 300,

        // Builder for each individual item
        itemBuilder: (context, index) {
          final item = _items[index];
          return ListTile(
            title: Text(item['title']),
            subtitle: Text(item['description']),
            leading: CircleAvatar(child: Text('${item['id'] + 1}')),
          );
        },

        // Builder for the list container
        builder: (context, itemCount, itemBuilder) {
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: itemCount,
            itemBuilder: itemBuilder,
          );
        },
      ),
    );
  }
}
