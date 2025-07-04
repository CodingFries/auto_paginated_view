import 'dart:async';

import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// A widget that implements automatic pagination for list-based views.
///
/// [AutoPaginatedView] wraps any list-based widget (ListView, GridView, etc.) and
/// adds automatic pagination capabilities, handling loading states, errors, and empty states.
///
/// It automatically triggers loading more items when the user scrolls to the end of the list,
/// displaying appropriate loading indicators, error messages, and retry options.
///
/// Usage example:
/// ```dart
/// AutoPaginatedView(
///   items: myItemsList,
///   hasReachedEnd: !hasMoreItems,
///   onLoadMore: () async {
///     try {
///       await loadMoreItems();
///       return null; // Success
///     } catch (e) {
///       return e.toString(); // Error message
///     }
///   },
///   itemBuilder: (context, index) => MyItemWidget(item: myItemsList[index]),
///   builder: (context, itemCount, itemBuilder) => ListView.builder(
///     itemCount: itemCount,
///     itemBuilder: itemBuilder,
///   ),
/// )
/// ```
class AutoPaginatedView extends StatefulWidget {
  /// Creates an auto-paginated view.
  ///
  /// The [items], [hasReachedEnd], [onLoadMore], [itemBuilder], and [builder] parameters
  /// are required.
  const AutoPaginatedView({
    super.key,
    required this.items,
    required this.hasReachedEnd,
    required this.onLoadMore,
    this.onEmptyStateRetry,
    this.onErrorStateRetry,
    required this.itemBuilder,
    required this.builder,
    this.loadingStateBuilder,
    this.errorStateBuilder,
    this.emptyStateBuilder,
    this.isInsideSliverView = false,
    this.emptyStateHeight,
    this.visibilityThreshold = 0,
    this.autoLoadInitially = true,
    this.autoRefreshOnEmptyList = true,
    this.autoRefreshOnListChange = true,
  });

  /// The list of items to display.
  final List items;

  /// Whether all available items have been loaded.
  ///
  /// When `true`, the widget will stop trying to load more items.
  final bool hasReachedEnd;

  /// Callback function to load more items.
  ///
  /// This function should return a `Future<String?>` where:
  /// - `null` indicates success
  /// - A non-null String represents an error message
  ///
  /// Example:
  /// ```
  /// onLoadMore: () async {
  ///   try {
  ///     await fetchMoreItems();
  ///     return null; // Success
  ///   } catch (e) {
  ///     return 'Failed to load: ${e.message}'; // Error message
  ///   }
  /// }
  /// ```
  final Future<String?> Function() onLoadMore;

  /// Callback function to retry loading when in empty state.
  ///
  /// This function is called when the user taps the retry button in the empty state.
  /// If not provided, [onLoadMore] will be used as the fallback.
  ///
  /// This function should return a `Future<String?>` where:
  /// - `null` indicates success
  /// - A non-null String represents an error message
  final Future<String?> Function()? onEmptyStateRetry;

  /// Callback function to retry loading when in error state.
  ///
  /// This function is called when the user taps the retry button in the error state.
  /// If not provided, [onLoadMore] will be used as the fallback.
  ///
  /// This function should return a `Future<String?>` where:
  /// - `null` indicates success
  /// - A non-null String represents an error message
  final Future<String?> Function()? onErrorStateRetry;

  /// Builder for individual items in the list.
  ///
  /// This function is responsible for building the widget for each item at the specified index.
  ///
  /// Example:
  /// ```
  /// itemBuilder: (context, index) => ListTile(
  ///   title: Text(items[index].title),
  ///   subtitle: Text(items[index].description),
  /// )
  /// ```
  final Widget Function(BuildContext, int) itemBuilder;

  /// Builder for the list container (ListView, GridView, etc.).
  ///
  /// This function receives:
  /// - BuildContext
  /// - itemCount (includes items plus potentially a loading indicator)
  /// - itemBuilder function to use for building individual items
  ///
  /// Example:
  /// ```
  /// builder: (context, itemCount, itemBuilder) => ListView.builder(
  ///   itemCount: itemCount,
  ///   itemBuilder: itemBuilder,
  ///   padding: EdgeInsets.all(16),
  /// )
  /// ```
  final Widget Function(
    BuildContext context,
    int itemCount,
    Widget Function(BuildContext, int) itemBuilder,
  )
  builder;

  /// Custom builder for the loading state widget.
  ///
  /// If not provided, a default loading indicator will be used.
  ///
  /// Example:
  /// ```
  /// loadingStateBuilder: () => Center(
  ///   child: Column(
  ///     children: [
  ///       CircularProgressIndicator(),
  ///       SizedBox(height: 16),
  ///       Text('Loading more items...'),
  ///     ],
  ///   ),
  /// )
  /// ```
  final Widget Function()? loadingStateBuilder;

  /// Custom builder for the error state widget.
  ///
  /// If not provided, a default error widget with retry button will be used.
  /// The function receives the error message and a callback to retry loading.
  ///
  /// Example:
  /// ```
  /// errorStateBuilder: (error, onRetry) => Center(
  ///   child: Column(
  ///     children: [
  ///       Icon(Icons.error, color: Colors.red),
  ///       Text('Error: $error'),
  ///       ElevatedButton(
  ///         onPressed: onRetry,
  ///         child: Text('Try Again'),
  ///       ),
  ///     ],
  ///   ),
  /// )
  /// ```
  final Widget Function(String error, VoidCallback onRetry)? errorStateBuilder;

  /// Custom builder for the empty state widget.
  ///
  /// If not provided, a default "No items found" message will be displayed.
  ///
  /// Example:
  /// ```
  /// emptyStateBuilder: () => Center(
  ///   child: Column(
  ///     mainAxisAlignment: MainAxisAlignment.center,
  ///     children: [
  ///       Text('No items available'),
  ///       ElevatedButton(
  ///         onPressed: onRefresh,
  ///         child: Text('Refresh'),
  ///       ),
  ///     ],
  ///   ),
  /// )
  /// ```
  final Widget Function(VoidCallback onRefresh)? emptyStateBuilder;

  /// Whether the widget is being used inside a sliver view.
  ///
  /// When `true`, empty states will be wrapped in a [SliverToBoxAdapter].
  final bool isInsideSliverView;

  /// Height for the empty state widget.
  ///
  /// If not provided, the empty state will take its natural height.
  final double? emptyStateHeight;

  /// Visibility threshold for triggering the loading of more items.
  ///
  /// A value between 0.0 and 1.0 representing how visible the loading indicator
  /// must be before triggering a load more action.
  final double visibilityThreshold;

  /// Whether to automatically load items when the widget is first built.
  final bool autoLoadInitially;

  /// Whether to automatically refresh when the list becomes empty.
  final bool autoRefreshOnEmptyList;

  /// Whether to automatically refresh when the list changes (useful when refreshing,
  /// e.g., after a pull-to-refresh).
  final bool autoRefreshOnListChange;

  @override
  State<AutoPaginatedView> createState() => _AutoPaginatedViewState();
}

class _AutoPaginatedViewState extends State<AutoPaginatedView> {
  /// Indicates if a loading operation is in progress.
  bool _isLoading = false;

  /// Stores the current error message, if any.
  String? _error;

  /// Tracks if the loading indicator is currently visible to the user.
  bool _isLoadingIndicatorVisible = false;

  /// Stores the previous item count to detect changes in the list.
  /// Used for the autoRefreshOnEmptyList functionality to detect when a list becomes empty.
  int _oldItemCount = 0;

  /// Stores the previous list of items to detect changes.
  /// Used for the autoRefreshOnListChange functionality to detect when the list changes.
  List? _oldList;

  @override
  void initState() {
    super.initState();

    if (widget.autoLoadInitially) {
      _callFunctionWithLoading(widget.onLoadMore);
    }
  }

  @override
  void didUpdateWidget(covariant AutoPaginatedView oldWidget) {
    if ((widget.autoRefreshOnEmptyList && _oldItemCount > 0) ||
        (widget.autoRefreshOnListChange && _oldList != widget.items) &&
            widget.items.isEmpty) {
      _callFunctionWithLoading(widget.onLoadMore);
    }

    _oldList = widget.items;
    _oldItemCount = widget.items.length;

    super.didUpdateWidget(oldWidget);
  }

  /// Checks if the loading indicator is visible and loads more items if needed.
  void _checkVisibility() {
    // Only schedule a future if the widget is still mounted
    if (!mounted) return;

    Future.delayed(Duration(seconds: 1), () {
      if (_isLoadingIndicatorVisible && !_isLoading && !widget.hasReachedEnd) {
        // Check mounted state again before setState
        if (!mounted) return;

        // Call your function if the item is visible
        _callFunctionWithLoading(widget.onLoadMore);
      }
    });
  }

  /// Executes the provided function while managing loading state and error handling.
  ///
  /// This method sets the loading state to true, calls the provided function,
  /// handles any errors that occur, and updates the error state accordingly.
  /// Finally, it resets the loading state and checks visibility for potential
  /// additional loading triggers.
  void _callFunctionWithLoading(Function function) async {
    setStateIfMounted(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await function();
      if (!mounted) return; // Safety check

      if (result != null) {
        setStateIfMounted(() {
          _error = result;
        });
      }
    } catch (e) {
      setStateIfMounted(() {
        _error = e.toString();
      });
    } finally {
      setStateIfMounted(() {
        _isLoading = false;
      });

      _checkVisibility();
    }
  }

  /// Safely updates the widget state if it's still mounted.
  ///
  /// This helper method ensures state changes are only performed on mounted widgets
  /// to avoid "setState() called after dispose()" errors.
  ///
  /// The [callback] parameter contains the function with state changes to apply.
  void setStateIfMounted(VoidCallback callback) {
    if (mounted) {
      setState(() {
        callback();
      });
    } else {
      // Execute callback even when widget is not mounted
      // This allows state variables to be updated even if UI won't reflect it
      callback();
    }
  }

  /// Builds the widget to display when the list is empty.
  Widget _emptyListBuilder() {
    return Center(
      child: SizedBox(
        height: widget.emptyStateHeight,
        child: Builder(
          builder: (context) {
            if (_isLoading) {
              return _buildLoadingState();
            } else if (_error != null) {
              return _buildErrorState(_error!);
            } else {
              return _buildEmptyState();
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      if (widget.isInsideSliverView) {
        // If inside a SliverView, return a SliverToBoxAdapter
        return SliverToBoxAdapter(child: _emptyListBuilder());
      }

      return _emptyListBuilder();
    }

    int itemCount = widget.items.length + (widget.hasReachedEnd ? 0 : 1);

    // Use the provided builder function
    return widget.builder(context, itemCount, (context, index) {
      if (index < widget.items.length) {
        return widget.itemBuilder(context, index);
      }

      if (_error != null) {
        return _buildErrorState(_error!);
      }

      return VisibilityDetector(
        key: Key('load_more_detector'),
        onVisibilityChanged: (VisibilityInfo info) {
          _isLoadingIndicatorVisible =
              info.visibleFraction > widget.visibilityThreshold;
          if (!_isLoading &&
              !widget.hasReachedEnd &&
              _isLoadingIndicatorVisible) {
            _callFunctionWithLoading(widget.onLoadMore);
          }
        },
        child: _buildLoadingState(),
      );
    });
  }

  /// Builds the loading state widget.
  Widget _buildLoadingState() {
    return widget.loadingStateBuilder?.call() ?? const _LoadingWidget();
  }

  /// Builds the error state widget with the given error message.
  Widget _buildErrorState(String error) {
    return widget.errorStateBuilder?.call(
          error,
          () => _callFunctionWithLoading(
            widget.onErrorStateRetry ?? widget.onLoadMore,
          ),
        ) ??
        _ErrorWidget(
          error: error,
          onRetry: () {
            _callFunctionWithLoading(
              widget.onErrorStateRetry ?? widget.onLoadMore,
            );
          },
        );
  }

  /// Builds the empty state widget.
  Widget _buildEmptyState() {
    return widget.emptyStateBuilder?.call(
          () => _callFunctionWithLoading(
            widget.onEmptyStateRetry ?? widget.onLoadMore,
          ),
        ) ??
        _ErrorWidget(
          error: 'No items found',
          onRetry:
              () => _callFunctionWithLoading(
                widget.onEmptyStateRetry ?? widget.onLoadMore,
              ),
        );
  }
}

/// Default loading indicator widget.
class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return Center(child: CircularProgressIndicator());
  }
}

/// Default error display widget with retry functionality.
class _ErrorWidget extends StatelessWidget {
  const _ErrorWidget({required this.error, required this.onRetry});

  /// The error message to display to the user.
  final String error;

  /// Callback function executed when the user taps the retry button.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(onPressed: onRetry, icon: Icon(Icons.refresh)),
          Text(error),
        ],
      ),
    );
  }
}
