import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:vrrealstatedemo/screens/EstatesPage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  _DevicesPageState createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  // final List<Map<String, String>> devices = [
  //   {'deviceName': 'Device 1', 'deviceID': 'ID001', 'status': 'Inactive'},
  //   {'deviceName': 'Device 2', 'deviceID': 'ID002', 'status': 'Active'},
  //   {'deviceName': 'Device 3', 'deviceID': 'ID003', 'status': 'Inactive'},
  //   {'deviceName': 'Device 4', 'deviceID': 'ID004', 'status': 'Active'},
  //   {'deviceName': 'Device 5', 'deviceID': 'ID005', 'status': 'Inactive'},
  //   {'deviceName': 'Device 6', 'deviceID': 'ID006', 'status': 'Active'},
  //   {'deviceName': 'Device 7', 'deviceID': 'ID007', 'status': 'Inactive'},
  //   {'deviceName': 'Device 8', 'deviceID': 'ID008', 'status': 'Active'},
  //   {'deviceName': 'Device 9', 'deviceID': 'ID009', 'status': 'Inactive'},
  //   {'deviceName': 'Device 10', 'deviceID': 'ID010', 'status': 'Active'},
  // ];

  bool isLoading = false;
  List<Map<String, String>> devices = [];

  @override
  void initState() {
    super.initState();
    fetchDevices();
  }

  Future<void> fetchDevices() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(dotenv.env['API_URL']!));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          devices = data.map((item) => Map<String, String>.from(item)).toList();
          isLoading = false;
        });
        _showSnackBar('Devices loaded successfully', isError: false);
      } else {
        throw HttpException('Failed to load devices: ${response.statusCode}');
      }
    } on HttpException catch (e) {
      _handleError('HTTP Error: ${e.message}');
    } on SocketException catch (_) {
      _handleError('Network error. Please check your internet connection.');
    } on FormatException catch (_) {
      _handleError('Error parsing data. Please try again later.');
    } catch (e) {
      _handleError('An unexpected error occurred: $e');
    }
  }

  void _handleError(String errorMessage) {
    print('Error fetching devices: $errorMessage');
    setState(() {
      isLoading = true;
      devices = []; // Clear the devices list in case of an error
    });
    _showSnackBar(errorMessage, isError: true);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return; // Check if the widget is still in the tree

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: isError ? 5 : 3),
        action: isError
            ? SnackBarAction(
                label: 'Retry',
                onPressed: () {
                  fetchDevices(); // Retry fetching devices
                },
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Devices',
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
        leading: Icon(Icons.vrpano_rounded,
            color: Theme.of(context).colorScheme.onPrimary),
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
          child: isLoading
              ? Center(
                  child: StyledCircularProgressIndicator(
                    size: 80.0,
                    strokeWidth: 8.0,
                    backgroundColor: Colors.grey,
                    valueColor: Theme.of(context).colorScheme.secondary,
                  ),
                )
              : Stack(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        double cardWidth;
                        int crossAxisCount;

                        if (constraints.maxWidth > 1200) {
                          crossAxisCount = 3;
                          cardWidth = constraints.maxWidth / 3 -
                              32; // Account for padding
                        } else if (constraints.maxWidth > 600) {
                          crossAxisCount = 2;
                          cardWidth = constraints.maxWidth / 2 -
                              24; // Account for padding
                        } else {
                          crossAxisCount = 1;
                          cardWidth =
                              constraints.maxWidth - 16; // Account for padding
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
                            itemCount: devices.length,
                            itemBuilder: (context, index) {
                              final device = devices[index];
                              return _buildDeviceCard(
                                  device, theme, cardWidth, index);
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

  Widget _buildDeviceCard(Map<String, String> device, ThemeData theme,
      double cardWidth, int index) {
    const Color primaryContainer = Color(0xFF998AE9);

    return Card(
      elevation: 6.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: const AssetImage('assets/quest.jpg'),
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
                      Icons.devices,
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
                          device['deviceName'] ?? 'Unknown Device',
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
                          device['deviceID'] ?? 'No ID',
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
              _buildStatusChip(device['status'] ?? 'Unknown', theme,
                  primaryContainer, index, device),
              const Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: List.generate(
                    4,
                    (index) => Padding(
                      padding: EdgeInsets.only(right: index * 15.0),
                      child: Container(
                        width: 30,
                        height: 40,
                        decoration: BoxDecoration(
                          color: [
                            Colors.orange,
                            Colors.yellow,
                            Colors.lightBlue,
                            Colors.lightGreen
                          ][index]
                              .withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ).reversed.toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, ThemeData theme,
      Color primaryContainer, int index, Map<String, String> device) {
    Color chipColor;
    IconData iconData;

    switch (status) {
      case 'Active':
        chipColor = theme.colorScheme.onSecondary;
        iconData = Icons.check_circle;
        break;
      case 'Inactive':
        chipColor = theme.colorScheme.error;
        iconData = Icons.error;
        break;
      default:
        chipColor = primaryContainer;
        iconData = Icons.sync;
    }

    return InkWell(
      onTap: () {
        setState(() {
          devices[index]['status'] = 'Connecting...';
        });
        Future.delayed(const Duration(seconds: 2), () {
          setState(() {
            devices[index]['status'] = 'Active';
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EstatesPage(deviceID: device['deviceID']!),
            ),
          );
        });

        // final channel = WebSocketChannel.connect(
        //   Uri.parse(dotenv.env['WEBSOCKET_URL']!),
        // );
        // _handleWebSocket(channel, device['deviceID'], context, index);
      },
      child: Container(
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
      ),
    );
  }

  void _handleWebSocket(WebSocketChannel channel, String? deviceID,
      BuildContext context, int index,
      {int attempt = 0}) {
    channel.sink.add(deviceID);

    setState(() {
      devices[index]['status'] = 'Connecting...';
    });

    channel.stream.listen((message) {
      if (message == 'connection_successful') {
        // Update device status to online
        setState(() {
          devices[index]['status'] = 'Active';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Device is online'),
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EstatesPage(deviceID: deviceID!),
          ),
        );
      }
    }, onError: (error) {
      setState(() {
        devices[index]['status'] = 'Inactive';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('WebSocket error: $error'),
        ),
      );
    }, onDone: () {
      setState(() {
        devices[index]['status'] = 'Inactive';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('WebSocket connection closed'),
        ),
      );

      // Attempt to reconnect with exponential backoff
      int delay = (attempt + 1) * 2;
      Future.delayed(Duration(seconds: delay), () {
        setState(() {
          devices[index]['status'] = 'connection_pending';
        });
        final newChannel = WebSocketChannel.connect(
          Uri.parse(dotenv.env['WEBSOCKET_URL']!),
        );
        _handleWebSocket(newChannel, deviceID, context, index,
            attempt: attempt + 1);
      });
    });
  }
}

class StyledCircularProgressIndicator extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color backgroundColor;
  final Color valueColor;

  const StyledCircularProgressIndicator({
    super.key,
    this.size = 50.0,
    this.strokeWidth = 5.0,
    this.backgroundColor = Colors.grey,
    this.valueColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: valueColor.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(strokeWidth * 2.5),
        child: Stack(
          children: [
            CircularProgressIndicator(
              strokeWidth: strokeWidth,
              backgroundColor: backgroundColor,
              valueColor: AlwaysStoppedAnimation<Color>(valueColor),
            ),
          ],
        ),
      ),
    );
  }
}
