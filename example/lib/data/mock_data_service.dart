import 'dart:math';

/// A mock service that simulates API calls for loading paginated data
class MockDataService {
  final Random _random = Random();
  final int _pageSize = 20;
  final Map<String, List<dynamic>> _dataStore = {};
  final int _maxItems = 100; // Maximum number of items that can be generated

  /// Initialize the data service with a specific data type
  void initDataStore(String key) {
    if (!_dataStore.containsKey(key)) {
      _dataStore[key] = [];
    }
  }

  /// Get items for a specific page
  ///
  /// Returns a Future that completes with a list of items
  /// Simulates network delay with a random duration
  Future<List<dynamic>> getItems(String key, int page) async {
    initDataStore(key);

    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1000)));
    return [];

    // Simulate error sometimes (approximately 10% of the time)
    if (_random.nextDouble() < 0.1) {
      throw Exception('Failed to load data from server');
    }

    final startIndex = page * _pageSize;

    // Check if we've reached the max items
    if (startIndex >= _maxItems) {
      return [];
    }

    // Generate new items if needed
    if (_dataStore[key]!.length < startIndex + _pageSize) {
      _generateItems(key, startIndex + _pageSize);
    }

    // Get the items for this page
    final endIndex = min(startIndex + _pageSize, _dataStore[key]!.length);
    return _dataStore[key]!.sublist(startIndex, endIndex);
  }

  /// Clear all data for a specific key
  void clearData(String key) {
    if (_dataStore.containsKey(key)) {
      _dataStore[key] = [];
    }
  }

  /// Check if there are more items available to load
  bool hasMoreItems(String key, int currentPage) {
    return (currentPage + 1) * _pageSize < _maxItems;
  }

  /// Generate mock items based on the data type
  void _generateItems(String key, int upToIndex) {
    final currentLength = _dataStore[key]!.length;

    for (int i = currentLength; i < min(upToIndex, _maxItems); i++) {
      switch (key) {
        case 'text':
          _dataStore[key]!.add({
            'id': i,
            'title': 'Item ${i + 1}',
            'description': 'This is the description for item ${i + 1}',
          });
          break;

        case 'images':
          // Generate a random color for the image
          final color = '${_random.nextInt(9999)}';
          _dataStore[key]!.add({
            'id': i,
            'title': 'Image ${i + 1}',
            'imageUrl':
                'https://placehold.co/150/${color.padLeft(6, '0')}/FFF/png',
          });
          break;

        case 'contacts':
          final names = [
            'John',
            'Jane',
            'Alex',
            'Maria',
            'David',
            'Sara',
            'Michael',
            'Emma',
            'James',
            'Olivia',
          ];
          final lastNames = [
            'Smith',
            'Johnson',
            'Williams',
            'Brown',
            'Jones',
            'Garcia',
            'Miller',
            'Davis',
            'Rodriguez',
            'Martinez',
          ];

          final name = names[_random.nextInt(names.length)];
          final lastName = lastNames[_random.nextInt(lastNames.length)];

          _dataStore[key]!.add({
            'id': i,
            'name': '$name $lastName',
            'email':
                '${name.toLowerCase()}.${lastName.toLowerCase()}@example.com',
            'avatarUrl': 'https://i.pravatar.cc/150?img=${(i % 70) + 1}',
          });
          break;

        default:
          _dataStore[key]!.add({'id': i, 'title': 'Generic Item ${i + 1}'});
      }
    }
  }
}
