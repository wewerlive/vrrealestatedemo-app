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
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devices'),
        leading: IconButton(
          icon: const Icon(Icons.vrpano_rounded),
          onPressed: () {},
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Handle more button press
            },
          ),
        ],
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
            .headlineSmall,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount;
          if (constraints.maxWidth < 600) {
            crossAxisCount = 2; // For phones
          } else if (constraints.maxWidth < 900) {
            crossAxisCount = 3; // For small tablets
          } else {
            crossAxisCount = 4; // For large tablets
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 3 / 2,
              ),
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
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
                        builder: (context) =>
                          EstatesPage(deviceID: device['deviceID']!),
                      ),
                      );
                    });
                    // final channel = WebSocketChannel.connect(
                    //   Uri.parse(dotenv.env['WEBSOCKET_URL']!),
                    // );

                    // _handleWebSocket(channel, device['deviceID'], context, index);
                  },
                  child: Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Icon(
                            Icons.home,
                            size: 48.0,
                            color: Colors.blueAccent,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                device['deviceName']!,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                device['deviceID']!,
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                device['status']!,
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: device['status'] == 'Active'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
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
