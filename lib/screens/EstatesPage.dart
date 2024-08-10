import 'package:flutter/material.dart';

class Scene {
  final IconData icon;
  final String name;

  Scene({required this.icon, required this.name});
}

class Estate {
  final IconData icon;
  final String name;
  final List<Scene> scenes;

  Estate({required this.icon, required this.name, required this.scenes});
}

class EstatesPage extends StatelessWidget {
  final String deviceID;

  const EstatesPage({super.key, required this.deviceID});

  @override
  Widget build(BuildContext context) {
    // Sample data (unchanged)
    final List<Estate> estates = [
      Estate(
        icon: Icons.home,
        name: 'Estate 1',
        scenes: [
          Scene(icon: Icons.lightbulb, name: 'Light'),
          Scene(icon: Icons.tv, name: 'TV'),
          Scene(icon: Icons.lock, name: 'Lock'),
        ],
      ),
      Estate(
        icon: Icons.apartment,
        name: 'Estate 2',
        scenes: [
          Scene(icon: Icons.lightbulb, name: 'Light'),
          Scene(icon: Icons.tv, name: 'TV'),
          Scene(icon: Icons.lock, name: 'Lock'),
        ],
      ),
      Estate(
        icon: Icons.home,
        name: 'Estate 1',
        scenes: [
          Scene(icon: Icons.lightbulb, name: 'Light'),
          Scene(icon: Icons.tv, name: 'TV'),
          Scene(icon: Icons.lock, name: 'Lock'),
        ],
      ),
      Estate(
        icon: Icons.apartment,
        name: 'Estate 2',
        scenes: [
          Scene(icon: Icons.lightbulb, name: 'Light'),
          Scene(icon: Icons.tv, name: 'TV'),
          Scene(icon: Icons.lock, name: 'Lock'),
        ],
      ),
      Estate(
        icon: Icons.home,
        name: 'Estate 1',
        scenes: [
          Scene(icon: Icons.lightbulb, name: 'Light'),
          Scene(icon: Icons.tv, name: 'TV'),
          Scene(icon: Icons.lock, name: 'Lock'),
        ],
      ),
      Estate(
        icon: Icons.apartment,
        name: 'Estate 2',
        scenes: [
          Scene(icon: Icons.lightbulb, name: 'Light'),
          Scene(icon: Icons.tv, name: 'TV'),
          Scene(icon: Icons.lock, name: 'Lock'),
        ],
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estates'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 8.0,
        shadowColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black54),
        toolbarTextStyle: Theme.of(context)
            .textTheme
            .apply(bodyColor: Colors.black54)
            .bodySmall,
        titleTextStyle: Theme.of(context)
            .textTheme
            .apply(bodyColor: Colors.black54)
            .titleLarge,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _getCrossAxisCount(constraints.maxWidth),
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: _getChildAspectRatio(constraints.maxWidth),
              ),
              itemCount: estates.length,
              itemBuilder: (context, index) {
                return EstateCard(
                  estate: estates[index],
                );
              },
            );
          },
        ),
      ),
    );
  }

  int _getCrossAxisCount(double width) {
    if (width < 600) return 1; // For smaller phones
    if (width < 900) return 2; // For larger phones and small tablets
    return 3; // For larger tablets
  }

  double _getChildAspectRatio(double width) {
    if (width < 600) return 16 / 9; // More rectangular for phones
    return 3 / 4; // Original aspect ratio for larger devices
  }
}

class EstateCard extends StatelessWidget {
  final Estate estate;

  const EstateCard({
    Key? key,
    required this.estate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallDevice = constraints.maxWidth < 600;
        return InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tapped on ${estate.name}')),
            );
          },
          child: Card(
            elevation: 6.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: isSmallDevice
                  ? _buildHorizontalLayout()
                  : _buildVerticalLayout(context),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerticalLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(estate.icon, size: 50.0, color: Colors.blue),
        const SizedBox(height: 12.0),
        Text(
          estate.name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12.0),
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: estate.scenes.map((scene) {
                return SceneItem(scene: scene);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalLayout() {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(estate.icon, size: 40.0, color: Colors.blue),
              const SizedBox(height: 8.0),
              Text(
                estate.name,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: estate.scenes.map((scene) {
                return SceneItem(scene: scene);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class SceneItem extends StatelessWidget {
  final Scene scene;

  const SceneItem({Key? key, required this.scene}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
      child: TextButton(
        onPressed: () {
          // Handle scene item tap event
        },
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.white),
          padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 4.0)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: const BorderSide(color: Colors.grey),
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(scene.icon, size: 24.0, color: Colors.grey),
            const SizedBox(width: 4.0),
            Text(
              scene.name,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
