import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vrrealstatedemo/screens/device_page.dart';

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

  const EstatesPage({
    super.key, 
    required this.deviceID,
  });

  @override
  State<EstatesPage> createState() => _EstatesPageState();
}


class _EstatesPageState extends State<EstatesPage> {
  List<Estate> estates = [];
  bool isLoading = false;
  int? expandedEstateIndex;

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
          'https://vrerealestatedemo-backend.globeapp.dev/data/projects?deviceID=${widget.deviceID}'));

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWideScreen = MediaQuery.of(context).size.width > 1024;

    return Scaffold(
      backgroundColor: theme.colorScheme.primaryContainer,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Estates for Device ${widget.deviceID}',
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            shadows: [
              Shadow(
                blurRadius: 6.0,
                color: Colors.black.withOpacity(0.8),
                offset: const Offset(1, 1),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.9),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)),
        ),
        toolbarHeight: kToolbarHeight + 40,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline,
                color: theme.colorScheme.onPrimary, size: 28),
            onPressed: () {
              // Add action for info button
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: IconButton(
              icon: Icon(Icons.refresh,
                  color: theme.colorScheme.onPrimary, size: 28),
              onPressed: fetchEstates,
            ),
          ),
        ],
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
          child: isLoading
              ? Center(
                  child: StyledCircularProgressIndicator(
                    size: 80.0,
                    strokeWidth: 8.0,
                    backgroundColor: Colors.grey,
                    valueColor: theme.colorScheme.secondary,
                  ),
                )
              : _buildEstateList(theme, isWideScreen),
        ),
      ),
    );
  }

  Widget _buildEstateList(ThemeData theme, bool isWideScreen) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWideScreen ? 3 : 1,
        childAspectRatio: isWideScreen ? 1 : 0.7, // Adjusted for mobile screens
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: estates.length,
      itemBuilder: (context, index) {
        final estate = estates[index];
        return _buildEstateCard(estate, theme, index, isWideScreen);
      },
    );
  }

  Widget _buildEstateCard(
      Estate estate, ThemeData theme, int index, bool isWideScreen) {
    bool isExpanded = expandedEstateIndex == index;

    return AspectRatio(
      aspectRatio: isWideScreen ? 1 : 0.7,
      child: Card(
        elevation: 6.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: AssetImage(estate.scenes.isNotEmpty
                  ? estate.scenes[0].imageUrl
                  : 'assets/placeholder.jpg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                theme.colorScheme.primaryContainer.withOpacity(0.6),
                BlendMode.lighten,
              ),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                estate.estateName,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
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
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.8),
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
                        _buildStatusChip(estate.status, theme),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSceneChips(estate.scenes, theme, index),
                  ],
                ),
              ),
              if (isExpanded)
                Expanded(child: _buildCarousel(estate.scenes, theme)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, ThemeData theme) {
    Color chipColor;
    IconData iconData;

    switch (status) {
      case 'Available':
        chipColor = Colors.green;
        iconData = Icons.check_circle;
        break;
      case 'Unavailable':
        chipColor = Colors.red;
        iconData = Icons.cancel;
        break;
      default:
        chipColor = Colors.orange;
        iconData = Icons.warning;
    }

    return Chip(
      avatar: Icon(iconData, color: theme.colorScheme.surface, size: 18),
      label: Text(
        status,
        style: TextStyle(
          color: theme.colorScheme.surface,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      backgroundColor: chipColor,
      elevation: 6,
      shadowColor: chipColor.withOpacity(0.8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: chipColor,
          width: 1,
        ),
      ),
    );
  }

  Widget _buildSceneChips(
      List<Scene> scenes, ThemeData theme, int estateIndex) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              expandedEstateIndex =
                  expandedEstateIndex == estateIndex ? null : estateIndex;
            });
          },
          child: Chip(
            avatar: Icon(
              expandedEstateIndex == estateIndex
                  ? Icons.expand_less
                  : Icons.expand_more,
              color: theme.colorScheme.surface,
              size: 18,
            ),
            label: Text(
              'Scenes (${scenes.length})',
              style: TextStyle(
                color: theme.colorScheme.surface,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            backgroundColor: theme.colorScheme.primaryContainer,
            elevation: 4,
            shadowColor: theme.colorScheme.primary.withOpacity(0.8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: theme.colorScheme.primaryContainer,
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCarousel(List<Scene> scenes, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)
        ],
      ),
      height: 250,
      child: PageView.builder(
        itemCount: scenes.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    scenes[index].imageUrl,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.9),
                            Colors.transparent
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            scenes[index].sceneName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Tap to explore',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
