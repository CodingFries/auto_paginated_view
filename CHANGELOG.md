## 1.2.0 - July 04, 2025

* Added new functionality:
  * Added `autoRefreshOnEmptyList` parameter to automatically refresh when the list becomes empty
  * Added `autoRefreshOnListChange` parameter to automatically refresh when the list changes (useful for pull-to-refresh scenarios)
  * Enhanced pull-to-refresh functionality to work properly with empty states

## 1.1.0 - June 17, 2025

* Added new functionality:
  * `setStateIfMounted` utility method to safely update state even when widget is unmounted
  * Improved state management to prevent "setState() called after dispose()" errors
  * State variables now update properly even when UI can't reflect changes
* Documentation improvements:
  * Enhanced README layout with better organized example GIFs
  * Improved visual presentation of examples in documentation
  * Added more detailed parameter descriptions
* Example app improvements:
  * Updated example app README with clearer instructions
  * Added screenshots and feature demonstrations

## 1.0.0

* Initial release of AutoPaginatedView
* Features:
  * Support for ListView, GridView, SliverList, and SliverGrid
  * Automatic loading when scrolling to the end of the list
  * Built-in loading, error, and empty state handling
  * Customizable state builders
  * Support for pull-to-refresh when used with RefreshIndicator
