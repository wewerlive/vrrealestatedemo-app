import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:vrrealstatedemo/screens/estate_page.dart';
import 'package:vrrealstatedemo/utils/progressbar.dart';

class Device {
  final String id;
  final String deviceId;
  final String deviceName;
  String status;
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
      deviceId: json['deviceID'],
      deviceName: json['deviceName'],
      status: json['status'],
      estateIDs: List<String>.from(json['estateIDs']),
    );
  }
}

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  List<Device> devices = [];
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  bool isLoading = false;
  // late SocketManager _socketManager;
  // StreamSubscription? _deviceStatusSubscription;

  @override
  void initState() {
    super.initState();
    // _initializeSocketManager();
    fetchDevices();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWideScreen = MediaQuery.of(context).size.width > 1024;

    return Scaffold(
      backgroundColor: theme.colorScheme.primaryContainer,
      appBar: AppBar(
        title: Text(
          'Devices',
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
        toolbarHeight: kToolbarHeight + 40, // Adjust the toolbar height
        actions: [
          IconButton(
            icon: Icon(Icons.support_rounded,
                color: theme.colorScheme.onPrimary, size: 28),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: IconButton(
              icon: Icon(Icons.logout_outlined,
                  color: theme.colorScheme.onPrimary, size: 28),
              onPressed: () => _handleLogout(),
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
              : RefreshIndicator(
                  onRefresh: fetchDevices,
                  child: _buildDeviceList(theme, isWideScreen),
                ),
        ),
      ),
    );
  }

  // Future<void> _initializeSocketManager() async {
  //   _socketManager = SocketManager();
  //   await _socketManager.initializeSocket();
  //   _listenToDeviceStatusUpdates();
  // }

  // void _listenToDeviceStatusUpdates() {
  //   _deviceStatusSubscription =
  //       _socketManager.deviceStatusStream.listen((data) {
  //     print('Device status update: $data');
  //     final updatedDeviceIndex =
  //         devices.indexWhere((device) => device.deviceId == data['deviceId']);
  //     if (updatedDeviceIndex != -1) {
  //       setState(() {
  //         for (var i = 0; i < devices.length; i++) {
  //           devices[i].status = i == updatedDeviceIndex ? 'Online' : 'Offline';
  //         }
  //       });
  //     }
  //   }, onError: (error) {
  //     _showSnackBar('Error updating device status', isError: true);
  //   });
  // }

  Future<void> fetchDevices() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    final id = await secureStorage.read(key: 'user_id');
    String errorMessage;

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.10:3000/headsets/$id'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        setState(() {
          devices = responseData.entries.map((entry) {
            final deviceData = entry.value as Map<String, dynamic>;
            return Device(
              id: entry.key,
              deviceId: deviceData['deviceID'],
              deviceName: deviceData['deviceName'],
              status: deviceData['status'],
              estateIDs: List<String>.from(deviceData['estateIDs']),
            );
          }).toList();
        });
        _showSnackBar('Devices loaded successfully', isError: false);
      } else {
        throw HttpException('Failed to load devices: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage = 'Failed to fetch devices: ${e.toString()}';
      if (mounted) {
        _showSnackBar(errorMessage, isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildDeviceCard(Device device, ThemeData theme, int index) {
    bool isOnline = device.status == 'Online';

    return Card(
      elevation: 6.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: const AssetImage('assets/quest.jpg'),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer
                                .withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primaryContainer
                                    .withOpacity(0.4),
                                spreadRadius: 3,
                                blurRadius: 4,
                                offset: const Offset(0, 1.8),
                              ),
                            ],
                          ),
                          child: Icon(Icons.devices,
                              color: theme.colorScheme.surface, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                device.deviceName,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.normal,
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
                                device.deviceId,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
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
                      ],
                    ),
                  ),
                  if (isOnline)
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EstatesPage(deviceID: device.deviceId),
                          ),
                        );
                      },
                      child: Chip(
                        avatar: Icon(
                          Icons.arrow_forward,
                          color: theme.colorScheme.surface,
                          size: 18,
                        ),
                        label: Text(
                          'View Estates',
                          style: TextStyle(
                            color: theme.colorScheme.surface,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: theme.colorScheme.primaryContainer,
                        elevation: 6,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: theme.colorScheme.primaryContainer,
                            width: 1,
                          ),
                        ),
                        shadowColor: theme.colorScheme.primary.withOpacity(0.5),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _buildStatusChip(device.status, theme, index, device),
              const SizedBox(height: 16),
              _buildDeviceStats(theme, device),
            ],
          ),
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

  Widget _buildDeviceStats(ThemeData theme, Device device) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatItem(theme, 'Usage', '75%', Icons.pie_chart),
        _buildStatItem(theme, 'Estates',
            '${(device.estateIDs as List?)?.length ?? 0}', Icons.apartment),
      ],
    );
  }

  Widget _buildStatItem(
      ThemeData theme, String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, color: theme.colorScheme.primaryContainer, size: 16),
            const SizedBox(width: 4),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(
      String status, ThemeData theme, int index, Device device) {
    Color iconColor;
    IconData iconData;

    switch (status) {
      case 'Online':
        iconColor = Colors.green;
        iconData = Icons.power_settings_new;
        break;
      case 'Offline':
        iconColor = Colors.red;
        iconData = Icons.power_settings_new;
        break;
      default:
        iconColor = Colors.grey;
        iconData = Icons.error_outline;
    }

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Icon(
          iconData,
          key: ValueKey<String>(status),
          color: iconColor,
          size: 32,
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    await secureStorage.delete(key: 'user_id');
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
                onPressed: () {
                  fetchDevices();
                },
              )
            : null,
      ),
    );
  }
}
