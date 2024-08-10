import 'package:flutter/material.dart';

class EstatesPage extends StatefulWidget {
  final String deviceID;

  const EstatesPage({Key? key, required this.deviceID}) : super(key: key);

  @override
  _EstatesPageState createState() => _EstatesPageState();
}

class _EstatesPageState extends State<EstatesPage> {
  final List<Map<String, dynamic>> estates = [
    {
      'estateName': 'Estate 1',
      'estateID': 'EST001',
      'scenes': ['Living Room', 'Kitchen', 'Bedroom'],
      'status': 'Active'
    },
    {
      'estateName': 'Estate 2',
      'estateID': 'EST002',
      'scenes': ['Office', 'Dining Room'],
      'status': 'Inactive'
    },
    {
      'estateName': 'Estate 3',
      'estateID': 'EST003',
      'scenes': ['Garden', 'Garage', 'Pool'],
      'status': 'Active'
    },
    {
      'estateName': 'Estate 4',
      'estateID': 'EST004',
      'scenes': ['Basement', 'Attic'],
      'status': 'Inactive'
    },
    {
      'estateName': 'Estate 5',
      'estateID': 'EST005',
      'scenes': ['Patio', 'Balcony'],
      'status': 'Active'
    },
    {
      'estateName': 'Estate 6',
      'estateID': 'EST006',
      'scenes': ['Guest Room', 'Home Theater'],
      'status': 'Inactive'
    },
    {
      'estateName': 'Estate 7',
      'estateID': 'EST007',
      'scenes': ['Gym', 'Library'],
      'status': 'Active'
    },
    {
      'estateName': 'Estate 8',
      'estateID': 'EST008',
      'scenes': ['Laundry Room', 'Mudroom'],
      'status': 'Inactive'
    },
    {
      'estateName': 'Estate 9',
      'estateID': 'EST009',
      'scenes': ['Nursery', 'Playroom'],
      'status': 'Active'
    },
    {
      'estateName': 'Estate 10',
      'estateID': 'EST010',
      'scenes': ['Study', 'Workshop'],
      'status': 'Inactive'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Estates for Device ${widget.deviceID}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            shadows: [
              Shadow(
                blurRadius: 6.0,
                color: Colors.black.withOpacity(0.8),
                offset: const Offset(1, 1),
              ),
            ],
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline,
                color: Theme.of(context).colorScheme.onPrimary),
            onPressed: () {
              // Add action for info button
            },
          ),
          IconButton(
            icon: Icon(Icons.settings,
                color: Theme.of(context).colorScheme.onPrimary),
            onPressed: () {
              // Add action for settings button
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primaryContainer,
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primaryContainer,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  double cardWidth;
                  int crossAxisCount;

                  if (constraints.maxWidth > 1200) {
                    crossAxisCount = 3;
                    cardWidth = constraints.maxWidth / 3 - 32;
                  } else if (constraints.maxWidth > 600) {
                    crossAxisCount = 2;
                    cardWidth = constraints.maxWidth / 2 - 24;
                  } else {
                    crossAxisCount = 1;
                    cardWidth = constraints.maxWidth - 16;
                  }

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: cardWidth / (cardWidth * 0.9),
                      ),
                      itemCount: estates.length,
                      itemBuilder: (context, index) {
                        final estate = estates[index];
                        return _buildEstateCard(estate, theme, cardWidth);
                      },
                    ),
                  );
                },
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height:
                    100, // Adjust this value to control the height of the gradient
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        theme.colorScheme.onSurface.withOpacity(1),
                        theme.colorScheme.onSurface.withOpacity(0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstateCard(
      Map<String, dynamic> estate, ThemeData theme, double cardWidth) {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: theme.colorScheme.surface.withOpacity(0.8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(
              Icons.home_work,
              size: cardWidth * 0.2,
              color: theme.colorScheme.secondary,
            ),
            Text(
              estate['estateName'],
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              estate['estateID'],
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            _buildStatusChip(estate['status'], theme),
            const SizedBox(height: 8),
            _buildScenesChips(estate['scenes'], theme),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, ThemeData theme) {
    Color chipColor;
    IconData iconData;

    switch (status) {
      case 'Active':
        chipColor = theme.colorScheme.secondary;
        iconData = Icons.check_circle;
        break;
      case 'Inactive':
        chipColor = theme.colorScheme.error;
        iconData = Icons.error;
        break;
      default:
        chipColor = theme.colorScheme.primary;
        iconData = Icons.sync;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, color: theme.colorScheme.onSecondary, size: 16),
          const SizedBox(width: 6),
          Text(
            status,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScenesChips(List<String> scenes, ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: scenes
          .map((scene) => Chip(
                label: Text(
                  scene,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                backgroundColor: theme.colorScheme.primary.withOpacity(0.7),
              ))
          .toList(),
    );
  }
}
