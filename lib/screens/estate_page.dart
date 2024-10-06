import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vrrealstatedemo/utils/progressbar.dart';
import 'package:vrrealstatedemo/screens/scene_page.dart';
import 'package:vrrealstatedemo/utils/socket_manager.dart';

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
  final SocketManager _socketManager = SocketManager();
  // ignore: unused_field
  StreamSubscription? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _initializeSocketAndFetchEstates();
  }

  Future<void> _initializeSocketAndFetchEstates() async {
    setState(() {
      isLoading = true;
    });

    try {
      await _socketManager.initializeSocket();
      await fetchEstates();
      _listenToLocationUpdates();
    } catch (e) {
      _showErrorSnackBar('Failed to initialize: ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchEstates() async {
    try {
      final response = await http.get(Uri.parse(
          'https://secondary-mindy-twinverse-5a55a10e.koyeb.app/users/${widget.deviceID}/estates'));

      if (response.statusCode == 200) {
        final List<dynamic> estatesJson = json.decode(response.body);
        setState(() {
          estates = estatesJson.map((json) => Estate.fromJson(json)).toList();
        });
      } else {
        throw Exception('Failed to load estates');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to fetch estates: ${e.toString()}');
    }
  }

  void _listenToLocationUpdates() {
    _locationSubscription = _socketManager.locationStream.listen(
      (index) => _handleLocationUpdate(index),
      onError: (error) => _showErrorSnackBar('Location update error: $error'),
    );
  }

  void _handleLocationUpdate(String index) {
    print(index);
    final parsedIndex = int.tryParse(index);
    if (parsedIndex != null &&
        parsedIndex >= 0 &&
        parsedIndex < estates.length) {
      final selectedEstate = estates[parsedIndex];
      _navigateToScenePage(selectedEstate);
    } else {
      _showErrorSnackBar('Invalid estate index received');
    }
  }

  void _navigateToScenePage(Estate estate) {
    if (!mounted) return;
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScenePage(
          allScenes: estate.scenes,
          currentScene: estate.scenes.isNotEmpty ? estate.scenes[0] : null,
          estateName: estate.estateName,
          estateID: estate.estateID,
          nextScene: estate.scenes.length > 1 ? estate.scenes[1] : null,
        ),
      ),
    );
  }

  void _selectEstate(int index) {
  if (index >= 0 && index < estates.length) {
    _socketManager.sendSceneChangeCommand('s$index', widget.deviceID);
    _showLoadingDialog();
  } else {
    _showErrorSnackBar('Invalid estate selection');
  }
}

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWideScreen = MediaQuery.of(context).size.width > 1024;

    return Scaffold(
      backgroundColor: theme.colorScheme.primaryContainer,
      appBar: _buildAppBar(theme),
      body: _buildBody(theme, isWideScreen),
    );
  }

  AppBar _buildAppBar(ThemeData theme) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: theme.colorScheme.onPrimary),
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
    );
  }

  Widget _buildBody(ThemeData theme, bool isWideScreen) {
    return Container(
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
    );
  }

  Widget _buildEstateList(ThemeData theme, bool isWideScreen) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWideScreen ? 3 : 1,
        childAspectRatio: isWideScreen ? 1 : 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: isWideScreen ? 16 : 16,
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
    return AspectRatio(
      aspectRatio: isWideScreen ? 1 : 0.7,
      child: GestureDetector(
        onTap: () => _selectEstate(index),
        child: Card(
          elevation: 6.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: _buildEstateCardContent(estate, theme, index),
        ),
      ),
    );
  }

  Widget _buildEstateCardContent(Estate estate, ThemeData theme, int index) {
    return AnimatedContainer(
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildEstateHeader(estate, theme),
            _buildSceneChips(estate.scenes, theme, index),
          ],
        ),
      ),
    );
  }

  Widget _buildEstateHeader(Estate estate, ThemeData theme) {
    return Row(
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
                  color: theme.colorScheme.primary.withOpacity(0.8),
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
    );
  }

  Widget _buildSceneChips(
      List<Scene> scenes, ThemeData theme, int estateIndex) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: scenes.map((scene) => _buildSceneChip(scene, theme)).toList(),
    );
  }

  Widget _buildSceneChip(Scene scene, ThemeData theme) {
    return Chip(
      label: Text(
        scene.sceneName,
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
    );
  }

  Widget _buildStatusChip(String status, ThemeData theme) {
    final chipData = _getStatusChipData(status);
    return Chip(
      avatar: Icon(chipData.icon, color: theme.colorScheme.surface, size: 18),
      label: Text(
        status,
        style: TextStyle(
          color: theme.colorScheme.surface,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      backgroundColor: chipData.color,
      elevation: 6,
      shadowColor: chipData.color.withOpacity(0.8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: chipData.color, width: 1),
      ),
    );
  }

  ({Color color, IconData icon}) _getStatusChipData(String status) {
    switch (status) {
      case 'Available':
        return (color: Colors.green, icon: Icons.check_circle);
      case 'Unavailable':
        return (color: Colors.red, icon: Icons.cancel);
      default:
        return (color: Colors.orange, icon: Icons.warning);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
