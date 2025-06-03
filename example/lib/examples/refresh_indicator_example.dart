import 'package:auto_paginated_view/auto_paginated_view.dart';
import 'package:flutter/material.dart';

import '../data/mock_data_service.dart';

/// Example showing how to use AutoPaginatedView with a RefreshIndicator
/// to enable pull-to-refresh functionality
class RefreshIndicatorExample extends StatefulWidget {
  const RefreshIndicatorExample({super.key});

  @override
  State<RefreshIndicatorExample> createState() =>
      _RefreshIndicatorExampleState();
}

class _RefreshIndicatorExampleState extends State<RefreshIndicatorExample> {
  final MockDataService _dataService = MockDataService();
  final List<Map<String, dynamic>> _items = [];
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

  /// Refresh the entire list from the beginning
  Future<void> _refreshList() async {
    setState(() {
      _items.clear();
      _currentPage = 0;
      _hasMoreItems = true;
      _dataService.clearData('text');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pull-to-Refresh Example')),
      body: RefreshIndicator(
        // Trigger the refresh function when pulled down
        onRefresh: _refreshList,
        child: AutoPaginatedView(
          // The list of items to display
          items: _items,

          // Whether we have loaded all available items
          hasReachedEnd: !_hasMoreItems,

          // Function to load more items when the user scrolls to the end
          onLoadMore: _loadMoreItems,

          // Builder for each individual item
          itemBuilder: (context, index) {
            final item = _items[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text(
                  item['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(item['description']),
                    const SizedBox(height: 4),
                    Text(
                      'Pull down to refresh or scroll to load more...',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
                isThreeLine: true,
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  child: Text('${item['id'] + 1}'),
                ),
              ),
            );
          },

          // Custom empty state builder to provide instructions for the RefreshIndicator
          emptyStateBuilder:
              () => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.arrow_downward,
                    size: 48,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Pull down to load items',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No items loaded yet',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),

          // Builder for the list container
          builder: (context, itemCount, itemBuilder) {
            return ListView.builder(
              // Add physics that work well with RefreshIndicator
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8.0),
              itemCount: itemCount,
              itemBuilder: itemBuilder,
            );
          },
        ),
      ),
    );
  }
}
