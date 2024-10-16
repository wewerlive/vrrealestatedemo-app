import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:vrrealstatedemo/screens/scene_page.dart';
import 'package:vrrealstatedemo/utils/progressbar.dart';
import 'package:vrrealstatedemo/utils/socket_manager.dart';

class EstatesPage extends StatefulWidget {
  final String deviceID;

  const EstatesPage({super.key, required this.deviceID});

  @override
  State<EstatesPage> createState() => _EstatesPageState();
}

class _EstatesPageState extends State<EstatesPage> {
  static const String _apiBaseUrl =
      'https://secondary-mindy-twinverse-5a55a10e.koyeb.app';

  List<Estate> estates = [];
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  bool isLoading = false;
  final SocketManager _socketManager = SocketManager();

  @override
  void initState() {
    super.initState();
    _fetchEstates();
  }

  Future<void> _fetchEstates() async {
    if (!mounted) return;

    setState(() => isLoading = true);

    final userId = await secureStorage.read(key: 'user_id');
    if (userId == null) {
      _handleError('User ID not found. Please log in again.');
      return;
    }

    try {
      final response = await _getEstates(userId);
      final estates = _parseEstatesResponse(response);
      if (mounted) {
        setState(() {
          this.estates = estates;
          isLoading = false;
        });
        _showSnackBar('Estates loaded successfully', isError: false);
      }
    } catch (e) {
      _handleError('Failed to fetch estates: ${e.toString()}');
    }
  }

  Future<http.Response> _getEstates(String userId) async {
    final response = await http.get(
      Uri.parse('$_apiBaseUrl/users/$userId/headsets/${widget.deviceID}/estates'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw TimeoutException('Request timed out'),
    );

    if (response.statusCode != 200) {
      throw HttpException('Failed to load estates: ${response.statusCode}');
    }

    return response;
  }

  List<Estate> _parseEstatesResponse(http.Response response) {
    final List<dynamic> responseData = json.decode(response.body);
    // print(responseData);
    return responseData.map((json) => Estate.fromJson(json)).toList();
  }

  void _handleError(String message) {
    if (mounted) {
      setState(() => isLoading = false);
      _showSnackBar(message, isError: true);
    }
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
        onPressed: () => Navigator.pushReplacementNamed(context, '/devices'),
        icon: const Icon(Icons.arrow_back),
      ),
      title: Text('Estates for Device ${widget.deviceID}'),
      backgroundColor: theme.colorScheme.surface,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _fetchEstates,
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
            : RefreshIndicator(
                onRefresh: _fetchEstates,
                child: _buildEstateList(theme, isWideScreen),
              ),
      ),
    );
  }

  Widget _buildEstateList(ThemeData theme, bool isWideScreen) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWideScreen ? 3 : 1,
        childAspectRatio: isWideScreen ? 1 : 16 / 9,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: estates.length,
      itemBuilder: (context, index) {
        final estate = estates[index];
        return _buildEstateCard(estate, theme, index);
      },
    );
  }

  Widget _buildEstateCard(Estate estate, ThemeData theme, int index) {
    return Card(
      elevation: 8.0,
      shadowColor: Colors.white.withOpacity(0.8),
      semanticContainer: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            image: AssetImage(estate.scenes.isNotEmpty
                ? estate.scenes[0].imageUrl
                : 'assets/placeholder.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              theme.colorScheme.primaryContainer.withOpacity(0.8),
              BlendMode.lighten,
            ),
          ),
        ),
        child: InkWell(
          onTap: () => _selectEstate(index),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        estate.estateName,
                        style: theme.textTheme.titleLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildStatusChip(estate.status, theme),
                  ],
                ),
                Text(
                  'ID: ${estate.estateID}',
                  style: theme.textTheme.bodySmall,
                ),
                const Spacer(),
                _buildEstateStats(theme, estate),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, ThemeData theme) {
    final chipData = _getStatusChipData(status);
    return Chip(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      avatar: Icon(chipData.icon, color: theme.colorScheme.surface, size: 18),
      label: Text(
        status,
        style: TextStyle(
            color: theme.colorScheme.surface, fontWeight: FontWeight.bold),
      ),
      backgroundColor: chipData.color,
    );
  }

  ({Color color, IconData icon}) _getStatusChipData(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return (color: Colors.green, icon: Icons.check_circle);
      case 'unavailable':
        return (color: Colors.red, icon: Icons.cancel);
      default:
        return (color: Colors.orange, icon: Icons.warning);
    }
  }

  Widget _buildEstateStats(ThemeData theme, Estate estate) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: estate.scenes.map((scene) {
        return Chip(
          label: Text(scene.sceneName),
          backgroundColor: theme.colorScheme.secondary,
          labelStyle: TextStyle(color: theme.colorScheme.primary),
        );
      }).toList(),
    );
  }

  void _selectEstate(int index) {
    if (index >= 0 && index < estates.length) {
      _socketManager.sendSceneChangeCommand('s$index', widget.deviceID);
      _navigateToScenePage(estates[index]);
    } else {
      _showSnackBar('Invalid estate selection', isError: true);
    }
  }

  void _navigateToScenePage(Estate estate) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScenePage(
          estateID: estate.estateID,
          deviceID: widget.deviceID,
          estateName: estate.estateName,
          allScenes: estate.scenes,
          currentScene: estate.scenes.isNotEmpty ? estate.scenes[0] : null,
          nextScene: estate.scenes.length > 1 ? estate.scenes[1] : null,
        ),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: isError ? 5 : 3),
        action: isError
            ? SnackBarAction(
                label: 'Retry',
                onPressed: _fetchEstates,
              )
            : null,
      ),
    );
  }
}

class Estate {
  final String estateID;
  final String estateName;
  final String status;
  final List<Scene> scenes;

  Estate({
    required this.estateID,
    required this.estateName,
    required this.status,
    required this.scenes,
  });

  factory Estate.fromJson(Map<String, dynamic> json) {
    return Estate(
      estateID: json['estateID']?.toString() ?? '',
      estateName: json['estateName']?.toString() ?? 'Unknown Estate',
      status: json['status']?.toString() ?? 'Unknown',
      scenes: (json['scenes'] as List<dynamic>?)
              ?.map((sceneJson) => Scene.fromJson(sceneJson))
              .toList() ??
          [],
    );
  }
}

class Scene {
  final String id;
  final String sceneName;
  final String imageUrl;

  Scene({
    required this.id,
    required this.sceneName,
    required this.imageUrl,
  });

  factory Scene.fromJson(Map<String, dynamic> json) {
    return Scene(
      id: json['id']?.toString() ?? '',
      sceneName: json['sceneName']?.toString() ??
          json['scneName']?.toString() ??
          'Unknown',
      imageUrl: json['imageUrl']?.toString() ?? 'assets/estate.jpg',
    );
  }
}
