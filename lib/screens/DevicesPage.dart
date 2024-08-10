import 'package:flutter/material.dart';
import 'package:vrrealstatedemo/screens/EstatesPage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  _DevicesPageState createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  final List<Map<String, String>> devices = [
    {'deviceName': 'Device 1', 'deviceID': 'ID001', 'status': 'Inactive'},
    {'deviceName': 'Device 2', 'deviceID': 'ID002', 'status': 'Inactive'},
    {'deviceName': 'Device 3', 'deviceID': 'ID003', 'status': 'Inactive'},
    {'deviceName': 'Device 4', 'deviceID': 'ID004', 'status': 'Inactive'},
    {'deviceName': 'Device 5', 'deviceID': 'ID005', 'status': 'Inactive'},
    {'deviceName': 'Device 6', 'deviceID': 'ID006', 'status': 'Inactive'},
    {'deviceName': 'Device 7', 'deviceID': 'ID007', 'status': 'Inactive'},
    {'deviceName': 'Device 8', 'deviceID': 'ID008', 'status': 'Inactive'},
    {'deviceName': 'Device 9', 'deviceID': 'ID009', 'status': 'Inactive'},
    {'deviceName': 'Device 10', 'deviceID': 'ID010', 'status': 'Inactive'},
    {'deviceName': 'Device 11', 'deviceID': 'ID011', 'status': 'Inactive'},
    {'deviceName': 'Device 12', 'deviceID': 'ID012', 'status': 'Inactive'},
  ];

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
          child: Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  double cardWidth;
                  int crossAxisCount;

                  if (constraints.maxWidth > 1200) {
                    crossAxisCount = 3;
                    cardWidth =
                        constraints.maxWidth / 3 - 32; // Account for padding
                  } else if (constraints.maxWidth > 600) {
                    crossAxisCount = 2;
                    cardWidth =
                        constraints.maxWidth / 2 - 24; // Account for padding
                  } else {
                    crossAxisCount = 1;
                    cardWidth =
                        constraints.maxWidth - 16; // Account for padding
                  }

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
    return InkWell(
      onTap: () {
        setState(() {
          devices[index]['status'] = 'connection_pending';
        });
        Future.delayed(Duration(seconds: 2), () {
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
      child: Card(
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
                Icons.home,
                size: cardWidth * 0.2,
                color: theme.colorScheme.secondary,
              ),
              Text(
                device['deviceName']!,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                device['deviceID']!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              _buildStatusChip(device['status']!, theme),
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
