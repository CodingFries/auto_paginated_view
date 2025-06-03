import 'package:auto_paginated_view/auto_paginated_view.dart';
import 'package:flutter/material.dart';

import '../data/mock_data_service.dart';

/// Example showing how to use AutoPaginatedView with SliverGrid in a CustomScrollView
class SliverGridExample extends StatefulWidget {
  const SliverGridExample({super.key});

  @override
  State<SliverGridExample> createState() => _SliverGridExampleState();
}

class _SliverGridExampleState extends State<SliverGridExample> {
  final MockDataService _dataService = MockDataService();
  final List<Map<String, dynamic>> _items = [];
  int _currentPage = 0;
  bool _hasMoreItems = true;

  @override
  void initState() {
    super.initState();
    // Initialize the data service with image items
    _dataService.initDataStore('images');
  }

  /// Load more items from the mock data service
  Future<String?> _loadMoreItems() async {
    try {
      final newItems = await _dataService.getItems('images', _currentPage);

      if (newItems.isEmpty) {
        setState(() {
          _hasMoreItems = false;
        });
        return null;
      }

      setState(() {
        _items.addAll(newItems.cast<Map<String, dynamic>>());
        _currentPage++;
        _hasMoreItems = _dataService.hasMoreItems('images', _currentPage);
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
            title: const Text('SliverGrid Example'),
            expandedHeight: 200.0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade900, Colors.purple.shade500],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Photo Gallery',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  setState(() {
                    _items.clear();
                    _currentPage = 0;
                    _hasMoreItems = true;
                    _dataService.clearData('images');
                  });
                },
              ),
            ],
          ),

          // Header section
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Scroll down to load more images automatically',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // AutoPaginatedView with SliverGrid
          AutoPaginatedView(
            items: _items,
            hasReachedEnd: !_hasMoreItems,
            onLoadMore: _loadMoreItems,
            isInsideSliverView:
                true, // Important: set this to true for sliver usage
            // Builder for each individual item
            itemBuilder: (context, index) {
              final item = _items[index];
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(item['imageUrl']),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    item['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },

            // Builder for the SliverGrid container
            builder: (context, itemCount, itemBuilder) {
              return SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  itemBuilder,
                  childCount: itemCount,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.0,
                ),
              );
            },
          ),

          // Footer spacer
          SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }
}
