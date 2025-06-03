import 'package:flutter/material.dart';

import 'examples/custom_states_example.dart';
import 'examples/gridview_example.dart';
import 'examples/listview_example.dart';
import 'examples/slivergrid_example.dart';
import 'examples/sliverlist_example.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto Paginated View Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoPaginatedView Examples'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildExampleCard(
            context,
            'ListView Example',
            'A basic implementation with ListView.builder',
            Icons.list,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ListViewExample()),
            ),
          ),
          _buildExampleCard(
            context,
            'GridView Example',
            'Using AutoPaginatedView with GridView.builder',
            Icons.grid_4x4,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GridViewExample()),
            ),
          ),
          _buildExampleCard(
            context,
            'SliverList Example',
            'Implementation with CustomScrollView and SliverList',
            Icons.view_list,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SliverListExample()),
            ),
          ),
          _buildExampleCard(
            context,
            'SliverGrid Example',
            'Implementation with CustomScrollView and SliverGrid',
            Icons.grid_view,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SliverGridExample()),
            ),
          ),
          _buildExampleCard(
            context,
            'Custom States Example',
            'Customized loading, error and empty states',
            Icons.settings,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CustomStatesExample()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
