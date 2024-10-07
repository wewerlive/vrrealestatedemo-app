import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:vrrealstatedemo/screens/estate_page.dart';
import 'package:vrrealstatedemo/utils/progressbar.dart';
import 'package:vrrealstatedemo/utils/socket_manager.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  static const String _userIdKey = 'user_id';
  static const String _apiBaseUrl = 'https://secondary-mindy-twinverse-5a55a10e.koyeb.app';

  List<Device> devices = [];
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  bool isLoading = false;
  final SocketManager _socketManager = SocketManager();

  @override
  void initState() {
    super.initState();
    _initializeSocketAndFetchDevices();
  }

  Future<void> _initializeSocketAndFetchDevices() async {
    await _socketManager.initializeSocket();
    await fetchDevices();
    _listenToDeviceUpdates();
  }

  void _listenToDeviceUpdates() {
    _socketManager.deviceStatusStream.listen((data) {
      if (mounted) {
        final updatedDevice = Device.fromJson(data);
        setState(() {
          final index = devices.indexWhere((d) => d.id == updatedDevice.id);
          if (index != -1) {
            devices[index] = updatedDevice;
          }
        });
      }
    });
  }

  Future<void> fetchDevices() async {
    if (!mounted) return;

    setState(() => isLoading = true);

    final id = await secureStorage.read(key: _userIdKey);
    if (id == null) {
      _handleError('User ID not found. Please log in again.');
      return;
    }

    try {
      final response = await _getDevices(id);
      final devices = _parseDevicesResponse(response);

      if (mounted) {
        setState(() {
          this.devices = devices;
          isLoading = false;
        });
        _showSnackBar('Devices loaded successfully', isError: false);
      }
    } catch (e) {
      _handleError('Failed to fetch devices: ${e.toString()}');
    }
  }

  Future<http.Response> _getDevices(String userId) async {
    final response = await http.get(
      Uri.parse('$_apiBaseUrl/headsets/$userId'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw TimeoutException('Request timed out'),
    );

    if (response.statusCode != 200) {
      throw HttpException('Failed to load devices: ${response.statusCode}');
    }

    return response;
  }

  List<Device> _parseDevicesResponse(http.Response response) {
    final Map<String, dynamic> responseData = json.decode(response.body);
    return responseData.entries.map((entry) {
      final deviceData = entry.value as Map<String, dynamic>;
      return Device(
        id: entry.key,
        deviceId: deviceData['deviceID'] ?? '',
        deviceName: deviceData['deviceName'] ?? 'Unknown Device',
        status: deviceData['status'] ?? 'Unknown',
        estateIDs: List<String>.from(deviceData['estateIDs'] ?? []),
      );
    }).toList();
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
      title: const Text('Devices'),
      backgroundColor: theme.colorScheme.surface,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: _handleLogout,
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
                onRefresh: fetchDevices,
                child: _buildDeviceList(theme, isWideScreen),
              ),
      ),
    );
  }

  Widget _buildDeviceList(ThemeData theme, bool isWideScreen) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWideScreen ? 3 : 1,
        childAspectRatio: isWideScreen ? 1 : 16 / 9,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        return _buildDeviceCard(device, theme, index);
      },
    );
  }

  Widget _buildDeviceCard(Device device, ThemeData theme, int index) {
    return Card(
      elevation: 8.0,
      shadowColor: Colors.white.withOpacity(0.8),
      semanticContainer: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            image: const AssetImage('assets/quest.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              theme.colorScheme.primaryContainer.withOpacity(0.8),
              BlendMode.lighten,
            ),
          ),
        ),
        child: InkWell(
          onTap: () => _navigateToEstatePage(device),
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
                        device.deviceName,
                        style: theme.textTheme.titleLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildStatusChip(device.status, theme, index, device),
                  ],
                ),
                Text(
                  'ID: ${device.deviceId}',
                  style: theme.textTheme.bodySmall,
                ),
                const Spacer(),
                _buildDeviceStats(theme, device),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, ThemeData theme, int index, Device device) {
    Color iconColor;
    IconData iconData;

    switch (status.toLowerCase()) {
      case 'online':
        iconColor = Colors.green;
        iconData = Icons.check_circle;
        break;
      case 'offline':
        iconColor = Colors.red;
        iconData = Icons.cancel;
        break;
      default:
        iconColor = Colors.grey;
        iconData = Icons.help;
    }

    return Chip(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      avatar: Icon(iconData, color: iconColor, size: 18),
      label: Text(status),
      backgroundColor: theme.colorScheme.surface,
    );
  }

  Widget _buildDeviceStats(ThemeData theme, Device device) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatItem(theme, 'Usage', '75%', Icons.pie_chart),
        _buildStatItem(theme, 'Estates', '${device.estateIDs.length}', Icons.apartment),
      ],
    );
  }

  Widget _buildStatItem(ThemeData theme, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.bodySmall),
        Text(value, style: theme.textTheme.titleMedium),
      ],
    );
  }

  void _navigateToEstatePage(Device device) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EstatesPage(deviceID: device.id),
      ),
    );
  }

  Future<void> _handleLogout() async {
    await secureStorage.delete(key: _userIdKey);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
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
                onPressed: fetchDevices,
              )
            : null,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class Device {
  final String id;
  final String deviceId;
  final String deviceName;
  final String status;
  final List<String> estateIDs;

  Device({
    required this.id,
    required this.deviceId,
    required this.deviceName,
    required this.status,
    required this.estateIDs,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'],
      deviceId: json['deviceID'] ?? '',
      deviceName: json['deviceName'] ?? 'Unknown Device',
      status: json['status'] ?? 'Unknown',
      estateIDs: List<String>.from(json['estateIDs'] ?? []),
    );
  }
}
