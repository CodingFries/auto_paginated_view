import 'dart:async';

import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AutoPaginatedView extends StatefulWidget {
  const AutoPaginatedView({
    super.key,
    required this.items,
    required this.hasReachedEnd,
    required this.onLoadMore,
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
  });

  final List items;

  final bool hasReachedEnd;

  final Future<String?> Function() onLoadMore;

  final Widget Function(BuildContext, int) itemBuilder;

  final Widget Function(
    BuildContext context,
    int itemCount,
    Widget Function(BuildContext, int) itemBuilder,
  )
  builder;

  final Widget Function()? loadingStateBuilder;

  final Widget Function(String error, VoidCallback onRetry)? errorStateBuilder;

  final Widget Function()? emptyStateBuilder;

  final bool isInsideSliverView;

  final double? emptyStateHeight;

  final double visibilityThreshold;

  final bool autoLoadInitially;

  final bool autoRefreshOnEmptyList;

  @override
  State<AutoPaginatedView> createState() => _AutoPaginatedViewState();
}

class _AutoPaginatedViewState extends State<AutoPaginatedView> {
  bool _isLoading = false;

  String? _error;

  bool _isLoadingIndicatorVisible = false;

  @override
  void initState() {
    super.initState();

    if (widget.autoLoadInitially) {
      _loadMore();
    }
  }

  @override
  void didUpdateWidget(covariant AutoPaginatedView oldWidget) {
    if (widget.autoRefreshOnEmptyList &&
        oldWidget.items.isNotEmpty &&
        widget.items.isEmpty) {
      _loadMore();
    }

    super.didUpdateWidget(oldWidget);
  }

  void _checkVisibility() {
    Future.delayed(Duration(seconds: 1), () {
      if (_isLoadingIndicatorVisible && !_isLoading && !widget.hasReachedEnd) {
        // Call your function if the item is visible
        _loadMore();
      }
    });
  }

  void _loadMore() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await widget.onLoadMore();
      if (result != null) {
        setState(() {
          _error = result;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });

      _checkVisibility();
    }
  }

  Widget _emptyListBuilder() {
    return SizedBox(
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
            _loadMore();
          }
        },
        child: _buildLoadingState(),
      );
    });
  }

  Widget _buildLoadingState() {
    return widget.loadingStateBuilder?.call() ?? const _LoadingWidget();
  }

  Widget _buildErrorState(String error) {
    return widget.errorStateBuilder?.call(error, _loadMore) ??
        _ErrorWidget(error: error, onRetry: _loadMore);
  }

  Widget _buildEmptyState() {
    return widget.emptyStateBuilder?.call() ??
        const _TextWidget(text: 'No items found');
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return Center(child: CircularProgressIndicator());
  }
}

class _TextWidget extends StatelessWidget {
  const _TextWidget({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(text));
  }
}

class _ErrorWidget extends StatelessWidget {
  const _ErrorWidget({required this.error, required this.onRetry});

  final String error;

  final Function onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(onPressed: () => onRetry(), icon: Icon(Icons.refresh)),
        Text(error),
      ],
    );
  }
}
