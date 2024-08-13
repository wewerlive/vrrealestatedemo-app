import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Estate {
  final String estateName;
  final String estateID;
  final List<Scene> scenes;
  final String status;

  Estate({
    required this.estateName,
    required this.estateID,
    required this.scenes,
    required this.status,
  });

  factory Estate.fromJson(Map<String, dynamic> json) {
    return Estate(
      estateName: json['estateName'] ?? '',
      estateID: json['estateID'] ?? '',
      scenes: (json['scenes'] as List<dynamic>?)
              ?.map((scene) => Scene.fromJson(scene))
              .toList() ??
          [],
      status: json['status'] ?? '',
    );
  }
}

class Scene {
  final String id;
  final String sceneName;
  final String imageUrl;

  Scene({required this.id, required this.sceneName, required this.imageUrl});

  factory Scene.fromJson(Map<String, dynamic> json) {
    return Scene(
      id: json['id'] ?? '',
      sceneName: json['sceneName'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

class EstatesPage extends StatefulWidget {
  final String deviceID;

  const EstatesPage({super.key, required this.deviceID});

  @override
  _EstatesPageState createState() => _EstatesPageState();
}

class _EstatesPageState extends State<EstatesPage> {
  List<Estate> estates = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchEstates();
  }

  Future<void> fetchEstates() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          'http://<ip-address>:8080/data/projects?deviceID=${widget.deviceID}'));

      if (response.statusCode == 200) {
        final List<dynamic> estatesJson = json.decode(response.body)['estates'];
        setState(() {
          estates = estatesJson.map((json) => Estate.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load estates');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Failed to fetch estates: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showScenesCarousel(BuildContext context, List<Scene> scenes) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              children: [
                Expanded(
                  child: CarouselView(
                    padding: const EdgeInsets.all(25.0),
                    elevation: 6.0,
                    itemSnapping: true,
                    itemExtent: MediaQuery.of(context).size.width * 0.6,
                    shrinkExtent: MediaQuery.of(context).size.width * 0.6,
                    children:
                        scenes.map((scene) => _buildSceneCard(scene)).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
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
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: cardWidth / (cardWidth * 0.75),
                            ),
                            itemCount: estates.length,
                            itemBuilder: (context, index) {
                              final estate = estates[index];
                              return _buildEstateCard(
                                  estate, theme, cardWidth, index);
                            },
                          ),
                        );
                      },
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 100,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              theme.colorScheme.onSurface.withOpacity(0.9),
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
      floatingActionButton: FloatingActionButton(
        onPressed: fetchEstates,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildEstateCard(
      Estate estate, ThemeData theme, double cardWidth, int index) {
    const Color primaryContainer = Color(0xFF998AE9);

    return GestureDetector(
      onTap: () {
        _showScenesCarousel(context, estate.scenes);
      },
      child: Card(
        elevation: 6.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: AssetImage(estate.scenes[0].imageUrl),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                primaryContainer.withOpacity(0.6),
                BlendMode.lighten,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: primaryContainer.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryContainer.withOpacity(0.4),
                            spreadRadius: 3,
                            blurRadius: 4,
                            offset: const Offset(0, 1.8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.home_work,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            estate.estateName,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.normal,
                              color: Colors.grey[900],
                              shadows: [
                                Shadow(
                                  blurRadius: 2.0,
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            estate.estateID,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600.withOpacity(0.8),
                              shadows: [
                                Shadow(
                                  blurRadius: 2.0,
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildStatusChip(
                    estate.status, theme, primaryContainer, index, estate),
                const Spacer(),
                _buildScenesChips(estate.scenes, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, ThemeData theme,
      Color primaryContainer, int index, Estate estate) {
    Color chipColor;
    IconData iconData;

    switch (status) {
      case 'Available':
        chipColor = theme.colorScheme.onSecondary;
        iconData = Icons.check_circle;
        break;
      case 'Unavailable':
        chipColor = theme.colorScheme.error;
        iconData = Icons.error;
        break;
      default:
        chipColor = primaryContainer;
        iconData = Icons.sync;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: chipColor.withOpacity(0.4),
            spreadRadius: 3,
            blurRadius: 4,
            offset: const Offset(0, 1.8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            status,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScenesChips(List<Scene> scenes, ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: scenes
          .map((scene) => Chip(
                label: Text(
                  scene.sceneName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                backgroundColor: theme.colorScheme.primary.withOpacity(0.7),
              ))
          .toList(),
    );
  }

  Widget _buildSceneCard(Scene scene) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              scene.imageUrl,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scene.sceneName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 3.0,
                          color: Colors.black,
                          offset: Offset(1.0, 1.0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap to explore',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
