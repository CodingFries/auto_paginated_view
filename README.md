# AutoPaginatedView

A Flutter widget that simplifies implementing automatic pagination in list-based views. This package helps you create paginated lists with minimal code while handling loading states, errors, and empty states.

[![pub package](https://img.shields.io/pub/v/auto_paginated_view.svg)](https://pub.dev/packages/auto_paginated_view)

## Features

- 📋 **Universal List Support**: Works with ListView, GridView, SliverList, SliverGrid, and custom list implementations
- 🔄 **Automatic Loading**: Triggers loading of more items when the user reaches the end of the list
- ⚠️ **Error Handling**: Built-in error handling with customizable error widgets and retry functionality
- 🔍 **Empty State Handling**: Displays appropriate widgets when the list is empty
- 🎨 **Customizable**: Allows full customization of loading, error, and empty state widgets
- 🔧 **Highly Configurable**: Flexible parameters for customizing behavior and appearance

## Getting Started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  auto_paginated_view: ^1.0.0
```

Then run:

```
flutter pub get
```

## Usage

### Basic ListView Example

```dart
import 'package:auto_paginated_view/auto_paginated_view.dart';
import 'package:flutter/material.dart';

AutoPaginatedView(
  items: myItemsList,
  hasReachedEnd: !hasMoreItems,
  onLoadMore: () async {
    try {
      await loadMoreItems();
      return null; // Success
    } catch (e) {
      return e.toString(); // Error message
    }
  },
  itemBuilder: (context, index) => ListTile(
    title: Text(myItemsList[index].title),
    subtitle: Text(myItemsList[index].description),
  ),
  builder: (context, itemCount, itemBuilder) => ListView.builder(
    itemCount: itemCount,
    itemBuilder: itemBuilder,
  ),
)
```

### GridView Example

```dart
AutoPaginatedView(
  items: myImagesList,
  hasReachedEnd: !hasMoreImages,
  onLoadMore: () async {
    try {
      await fetchMoreImages();
      return null;
    } catch (e) {
      return e.toString();
    }
  },
  itemBuilder: (context, index) => Image.network(myImagesList[index].url),
  builder: (context, itemCount, itemBuilder) => GridView.builder(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
    ),
    itemCount: itemCount,
    itemBuilder: itemBuilder,
  ),
)
```

### SliverList Example

```dart
CustomScrollView(
  slivers: [
    SliverAppBar(
      title: Text('My Sliver List'),
      floating: true,
    ),
    AutoPaginatedView(
      items: myItemsList,
      hasReachedEnd: !hasMoreItems,
      onLoadMore: () async {
        try {
          await loadMoreItems();
          return null;
        } catch (e) {
          return e.toString();
        }
      },
      itemBuilder: (context, index) => ListTile(
        title: Text(myItemsList[index].title),
      ),
      builder: (context, itemCount, itemBuilder) => SliverList(
        delegate: SliverChildBuilderDelegate(
          itemBuilder,
          childCount: itemCount,
        ),
      ),
      isInsideSliverView: true,
    ),
  ],
)
```

### Custom State Builders

```dart
AutoPaginatedView(
  items: myItemsList,
  hasReachedEnd: !hasMoreItems,
  onLoadMore: loadMoreFunction,
  itemBuilder: itemBuilderFunction,
  builder: listBuilderFunction,
  // Custom loading state
  loadingStateBuilder: () => Center(
    child: Column(
      children: [
        CircularProgressIndicator(color: Colors.blue),
        SizedBox(height: 8),
        Text('Loading more items...'),
      ],
    ),
  ),
  // Custom error state
  errorStateBuilder: (error, retry) => Center(
    child: Column(
      children: [
        Icon(Icons.error, color: Colors.red, size: 48),
        Text('Oops! $error'),
        ElevatedButton(
          onPressed: retry,
          child: Text('Try Again'),
        ),
      ],
    ),
  ),
  // Custom empty state
  emptyStateBuilder: () => Center(
    child: Column(
      children: [
        Icon(Icons.inbox, color: Colors.grey, size: 48),
        Text('No items available'),
        ElevatedButton(
          onPressed: loadMoreFunction,
          child: Text('Refresh'),
        ),
      ],
    ),
  ),
)
```

## Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `items` | `List` | The list of items to display |
| `hasReachedEnd` | `bool` | Whether all available items have been loaded |
| `onLoadMore` | `Future<String?> Function()` | Callback to load more items. Returns null on success or error message on failure |
| `itemBuilder` | `Widget Function(BuildContext, int)` | Builder for individual items in the list |
| `builder` | `Widget Function(BuildContext, int, Widget Function(BuildContext, int))` | Builder for the list container (ListView, GridView, etc.) |
| `loadingStateBuilder` | `Widget Function()?` | Custom builder for the loading state widget |
| `errorStateBuilder` | `Widget Function(String, VoidCallback)?` | Custom builder for the error state widget |
| `emptyStateBuilder` | `Widget Function()?` | Custom builder for the empty state widget |
| `isInsideSliverView` | `bool` | Whether the widget is being used inside a sliver view |
| `emptyStateHeight` | `double?` | Height for the empty state widget |
| `visibilityThreshold` | `double` | Visibility threshold for triggering loading more items |
| `autoLoadInitially` | `bool` | Whether to automatically load items when the widget is first built |
| `autoRefreshOnEmptyList` | `bool` | Whether to automatically refresh when the list becomes empty |

## Advanced Usage

See the `/example` folder for complete sample applications demonstrating different use cases and configurations.

## Contributing

Contributions are welcome! If you find a bug or want a feature, please open an issue.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
