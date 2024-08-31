import 'package:flutter/material.dart';
import 'package:vrrealstatedemo/screens/estate_page.dart';
import 'package:flutter/services.dart';

class ScenePage extends StatefulWidget {
  final Scene currentScene;
  final List<Scene> allScenes;
  final String estateID;
  final Scene? nextScene;
  final String estateName;

  const ScenePage({
    super.key,
    required this.currentScene,
    required this.estateID,
    required this.estateName,
    required this.allScenes,
    this.nextScene,
  });

  @override
  State<ScenePage> createState() => _ScenePageState();
}

class _ScenePageState extends State<ScenePage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
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
            widget.currentScene.imageUrl,
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
                      widget.currentScene.sceneName,
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
            height: 300,
            width: double.infinity,
            child: CarouselView(
              // padding: const EdgeInsets.all(20),
              itemExtent: 550,
              shrinkExtent: 200,
              controller: CarouselController(
                initialItem: widget.allScenes.indexOf(widget.currentScene),
              ),
              children: widget.allScenes.map((scene) {
                return InkWell(
                  onTap: () {
                    // Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScenePage(
                          currentScene: scene,
                          allScenes: widget.allScenes,
                          estateID: widget.estateID,
                          estateName: widget.estateName,
                          nextScene: widget.allScenes[
                              (widget.allScenes.indexOf(scene) + 1) %
                                  widget.allScenes.length],
                        ),
                      ),
                    );
                  },
                  child: Container(
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
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
