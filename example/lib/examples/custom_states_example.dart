import 'package:auto_paginated_view/auto_paginated_view.dart';
import 'package:flutter/material.dart';

import '../data/mock_data_service.dart';

/// Example showing how to use AutoPaginatedView with customized states
class CustomStatesExample extends StatefulWidget {
  const CustomStatesExample({super.key});

  @override
  State<CustomStatesExample> createState() => _CustomStatesExampleState();
}

class _CustomStatesExampleState extends State<CustomStatesExample> {
  final MockDataService _dataService = MockDataService();
  final List<Map<String, dynamic>> _items = [];
  int _currentPage = 0;
  bool _hasMoreItems = true;
  bool _forceError = false;
  bool _showEmptyState = false;

  @override
  void initState() {
    super.initState();
    // Initialize the data service
    _dataService.initDataStore('text');
  }

  /// Load more items from the mock data service with optional forced error
  Future<String?> _loadMoreItems() async {
    // Force an error if the toggle is on
    if (_forceError) {
      return 'This is a forced error for demonstration purposes.';
    }

    // Return empty list if empty state toggle is on
    if (_showEmptyState && _items.isEmpty) {
      return null;
    }

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
      appBar: AppBar(title: const Text('Custom States Example')),
      body: Column(
        children: [
          // Control panel to toggle different states
          _buildControlPanel(),

          // Divider
          const Divider(height: 1, thickness: 1),

          // The AutoPaginatedView with custom state builders
          Expanded(
            child: AutoPaginatedView(
              items: _items,
              hasReachedEnd: !_hasMoreItems,
              onLoadMore: _loadMoreItems,
              autoLoadInitially: true,

              // Custom loading state builder
              loadingStateBuilder:
                  () => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Loading items...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

              // Custom error state builder
              errorStateBuilder:
                  (error, onRetry) => Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 60,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Oops! Something went wrong',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error,
                            style: const TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: onRetry,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try Again'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade400,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

              // Custom empty state builder
              emptyStateBuilder:
                  () => Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.network(
                            'https://placehold.co/150/png?text=Empty',
                            width: 120,
                            height: 120,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'No Items Found',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'There are no items to display right now.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _showEmptyState = false;
                                _forceError = false;
                              });
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Load Items'),
                          ),
                        ],
                      ),
                    ),
                  ),

              // Builder for each individual item
              itemBuilder: (context, index) {
                final item = _items[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 5.0,
                  ),
                  child: ListTile(
                    title: Text(item['title']),
                    subtitle: Text(item['description']),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text('${item['id'] + 1}'),
                    ),
                  ),
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
          ),
        ],
      ),
    );
  }

  /// Control panel widgets to toggle different states
  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Control Panel',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            children: [
              // Reset button
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _items.clear();
                        _currentPage = 0;
                        _hasMoreItems = true;
                        _forceError = false;
                        _showEmptyState = false;
                        _dataService.clearData('text');
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ),

              // Force error toggle
              Expanded(
                child: Row(
                  children: [
                    Checkbox(
                      value: _forceError,
                      onChanged: (value) {
                        setState(() {
                          _forceError = value ?? false;
                          _showEmptyState = false;
                          if (_forceError) {
                            _items.clear();
                          }
                        });
                      },
                    ),
                    Expanded(
                      child: Text(
                        'Show Error State',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Empty state toggle
              Expanded(
                child: Row(
                  children: [
                    Checkbox(
                      value: _showEmptyState,
                      onChanged: (value) {
                        setState(() {
                          _showEmptyState = value ?? false;
                          _forceError = false;
                          if (_showEmptyState) {
                            _items.clear();
                          }
                        });
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'Show Empty State',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
