import 'package:auto_paginated_view/auto_paginated_view.dart';
import 'package:flutter/material.dart';

import '../data/mock_data_service.dart';

/// Example showing how to use AutoPaginatedView with SliverList in a CustomScrollView
class SliverListExample extends StatefulWidget {
  const SliverListExample({super.key});

  @override
  State<SliverListExample> createState() => _SliverListExampleState();
}

class _SliverListExampleState extends State<SliverListExample> {
  final MockDataService _dataService = MockDataService();
  final List<Map<String, dynamic>> _items = [];
  int _currentPage = 0;
  bool _hasMoreItems = true;

  @override
  void initState() {
    super.initState();
    // Initialize the data service with contact items
    _dataService.initDataStore('contacts');
  }

  /// Load more items from the mock data service
  Future<String?> _loadMoreItems() async {
    try {
      final newItems = await _dataService.getItems('contacts', _currentPage);

      if (newItems.isEmpty) {
        setState(() {
          _hasMoreItems = false;
        });
        return null;
      }

      setState(() {
        _items.addAll(newItems.cast<Map<String, dynamic>>());
        _currentPage++;
        _hasMoreItems = _dataService.hasMoreItems('contacts', _currentPage);
      });

      return null; // Success
    } catch (e) {
      return e.toString(); // Return the error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar as a sliver
          SliverAppBar(
            title: const Text('SliverList Example'),
            floating: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  setState(() {
                    _items.clear();
                    _currentPage = 0;
                    _hasMoreItems = true;
                    _dataService.clearData('contacts');
                  });
                },
              ),
            ],
          ),

          // Header section
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade200,
              child: const Text(
                'Contact List',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // AutoPaginatedView with SliverList
          AutoPaginatedView(
            items: _items,
            hasReachedEnd: !_hasMoreItems,
            onLoadMore: _loadMoreItems,
            emptyStateHeight: 300,
            isInsideSliverView:
                true, // Important: set this to true for sliver usage
            // Builder for each individual item
            itemBuilder: (context, index) {
              final item = _items[index];
              return ListTile(
                title: Text(item['name']),
                subtitle: Text(item['email']),
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(item['avatarUrl']),
                ),
              );
            },

            // Builder for the SliverList container
            builder: (context, itemCount, itemBuilder) {
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  itemBuilder,
                  childCount: itemCount,
                ),
              );
            },
          ),

          // Footer
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: const Text('End of contacts'),
            ),
          ),
        ],
      ),
    );
  }
}
