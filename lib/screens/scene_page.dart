import 'package:flutter/material.dart';
import 'package:vrrealstatedemo/screens/estate_page.dart';
import 'package:flutter/services.dart';
import 'package:vrrealstatedemo/utils/socket_manager.dart';

class ScenePage extends StatefulWidget {
  final List<Scene> allScenes;
  final Scene? currentScene;
  final String estateName;
  final String estateID;
  final Scene? nextScene;

  const ScenePage({
    super.key,
    this.currentScene,
    required this.estateID,
    required this.estateName,
    required this.allScenes,
    this.nextScene,
  });

  @override
  State<ScenePage> createState() => _ScenePageState();
}

class _ScenePageState extends State<ScenePage> {
  String currentLocation = '';
  late final SocketManager _socketManager = SocketManager();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _socketManager.locationStream.listen((message) {
      setState(() {
        currentLocation = message;
      });
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            widget.currentScene!.imageUrl,
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          Positioned(
            top: 40,
            left: 20,
            child: Material(
              elevation: 8,
              shadowColor: Colors.black.withOpacity(0.8),
              shape: const CircleBorder(),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Material(
              elevation: 8,
              shadowColor: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
              color: Colors.black.withOpacity(0.5),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.currentScene!.sceneName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.estateName,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (widget.nextScene != null)
            Positioned(
              bottom: 20,
              left: 20,
              child: Material(
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10),
                child: GestureDetector(
                  onTap: () => _showScenesCarousel(context),
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: AssetImage(widget.nextScene!.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black.withOpacity(0.3),
                      ),
                      child: Center(
                        child: Text(
                          widget.nextScene!.sceneName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showScenesCarousel(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(10),
            height: MediaQuery.of(context).size.height * 0.8,
            width: MediaQuery.of(context).size.width * 0.8,
            child: CarouselView(
              onTap: (int index) {
                Scene selectedScene = widget.allScenes[index];
                Scene nextScene = _getNextScene(selectedScene);
                _socketManager.sendMessage('t$index');
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScenePage(
                      allScenes: widget.allScenes,
                      currentScene: selectedScene,
                      estateID: widget.estateID,
                      estateName: widget.estateName,
                      nextScene: nextScene,
                    ),
                  ),
                );
              },
              itemSnapping: true,
              itemExtent: double.maxFinite,
              shrinkExtent: 100,
              controller: CarouselController(
                initialItem: widget.currentScene != null
                    ? widget.allScenes.indexOf(widget.currentScene!)
                    : 0,
              ),
              children: widget.allScenes.map((scene) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: AssetImage(scene.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black.withOpacity(0.3),
                    ),
                    child: Center(
                      child: Text(
                        scene.sceneName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Scene _getNextScene(Scene currentScene) {
    int currentIndex = widget.allScenes.indexOf(currentScene);
    if (currentIndex < widget.allScenes.length - 1) {
      return widget.allScenes[currentIndex + 1];
    }
    // If we've reached the end, return the first scene
    return widget.allScenes[0];
  }
}
