# AutoPaginatedView Example

This example project demonstrates how to use the `auto_paginated_view` Flutter package to implement automatic pagination in various list views.

## Examples Included

This project includes several examples demonstrating different use cases:

- **ListView Example**: A basic implementation with ListView.builder
- **GridView Example**: Shows how to use AutoPaginatedView with GridView.builder
- **Pull-to-Refresh Example**: Demonstrates combining AutoPaginatedView with RefreshIndicator
- **SliverList Example**: Shows how to use AutoPaginatedView with SliverList
- **SliverGrid Example**: Demonstrates AutoPaginatedView with SliverGrid

## Getting Started

1. Ensure you have Flutter installed on your machine
2. Clone the repository
3. Run the project:
   ```
   cd example
   flutter pub get
   flutter run
   ```

## Features Demonstrated

- Automatic loading of more items when reaching the end of the list
- Error handling and retry functionality
- Empty state handling
- Different list layouts (linear, grid)
- Pull-to-refresh functionality
- Customization of loading, error, and empty state widgets

## Screenshots

| ListView | GridView | Pull-to-Refresh |
|----------|----------|-----------------|
| ![ListView Example](https://raw.githubusercontent.com/CodingFries/auto_paginated_view/main/gifs/listview.gif) | ![GridView Example](https://raw.githubusercontent.com/CodingFries/auto_paginated_view/main/gifs/gridview.gif) | ![Pull-to-Refresh Example](https://raw.githubusercontent.com/CodingFries/auto_paginated_view/main/gifs/pull_to_refresh.gif) |

<div style="width:66%;">
<table>
  <tr>
    <th>SliverList</th>
    <th>SliverGrid</th>
  </tr>
  <tr>
    <td align="center"><img src="https://raw.githubusercontent.com/CodingFries/auto_paginated_view/main/gifs/sliverlist.gif" alt="SliverList Example"></td>
    <td align="center"><img src="https://raw.githubusercontent.com/CodingFries/auto_paginated_view/main/gifs/slivergrid.gif" alt="SliverGrid Example"></td>
  </tr>
</table>
</div>

## Learn More

For more information on the AutoPaginatedView package, visit the [GitHub repository](https://github.com/CodingFries/auto_paginated_view) or [pub.dev page](https://pub.dev/packages/auto_paginated_view).
