import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:get/get.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AR Object Placement',
      home: RemoteObject(),
    );
  }
}

class RemoteObject extends StatefulWidget {
  @override
  _RemoteObjectState createState() => _RemoteObjectState();
}

class _RemoteObjectState extends State<RemoteObject> {
  ArCoreController? arCoreController;
  ArCoreNode? objectSelected;
  List<ArCoreRotatingNode> objectNodes = [];
  String shape = '';

  Offset objectPosition = Offset(0.0, 0.0);
  double objectScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(
              title: const Text('AR App'),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .8,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: GestureDetector(
                            // onPanUpdate: (details) {
                            //   _moveObject(details.delta);
                            // },
                            onScaleUpdate: (details) {
                              _scaleObject(details.scale);
                            },
                            child: ArCoreView(
                              onArCoreViewCreated: _onArCoreViewCreated,
                              enableTapRecognizer: true,
                              enableUpdateListener: true,
                            ))),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                shape = 'sphere';
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: shape == 'sphere'
                                    ? Colors.green
                                    : Colors.blue[400]),
                            child: const Text(
                              "Add Sphere",
                              style: TextStyle(color: Colors.white),
                            )),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                shape = 'cube';
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: shape == 'cube'
                                    ? Colors.green
                                    : Colors.blue[400]),
                            child: const Text(
                              "Add Cube",
                              style: TextStyle(color: Colors.white),
                            )),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                shape = 'cylindre';
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: shape == 'cylindre'
                                    ? Colors.green
                                    : Colors.blue[400]),
                            child: const Text(
                              "Add Cylindre",
                              style: TextStyle(color: Colors.white),
                            )),
                      )
                    ],
                  ),
                ],
              ),
            )));
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    // arCoreController?.onNodeTap = (name) => onTapHandler(name);
    arCoreController?.onNodeTap = (name) => onTapHandler(name);
    arCoreController?.onPlaneTap = _handleOnPlaneTap;
  }

  Future _addObject(ArCoreHitTestResult plane, String shape) async {
    final sphere = ArCoreSphere(
      materials: [ArCoreMaterial(color: Colors.blue)],
      radius: 0.1,
    );

    final cube = ArCoreCube(
      materials: [ArCoreMaterial(color: Colors.blue)],
      size: vector.Vector3(0.5, 0.5, 0.5),
    );

    final cylindre = ArCoreCylinder(
      materials: [
        ArCoreMaterial(
          color: Colors.red,
          reflectance: 1.0,
        )
      ],
      radius: 0.5,
      height: 0.3,
    );

    final objectNode = ArCoreRotatingNode(
        name: "Object " + (objectNodes.length + 1).toString(),
        shape: shape == 'sphere'
            ? sphere
            : (shape == 'cube'
                ? cube
                : (shape == 'cylindre' ? cylindre : null)),
        position: plane.pose.translation,
        rotation: plane.pose.rotation);

    arCoreController?.addArCoreNodeWithAnchor(objectNode);

    objectNodes.add(objectNode);

    // Enable dragging for the added object
    _enableObjectDrag(objectNode);
  }

  _enableObjectDrag(ArCoreNode node) {}

  _scaleObject(double scale) {
    setState(() {
      objectScale *= scale;
      for (int i = 0; i < objectNodes.length; i++) {
        final node = objectNodes[i];
        if (node != null && node.position != null) {
          objectNodes[i].scale?.value = vector.Vector3.all(objectScale);
        }
      }
    });
  }

  _rotateObject(String name, double value) {
    setState(() {
      for (int i = 0; i < objectNodes.length; i++) {
        final node = objectNodes[i];
        if (node != null && node.position != null) {
          if (node.name == name) {
            debugPrint("onDegreesPerSecondChange");
            if (node?.degreesPerSecond.value != value) {
              final currentPosition = node.rotation?.value;
              final x = currentPosition?.x ?? 0;
              final y = currentPosition?.y ?? 0;
              final z = currentPosition?.z ?? 0;
              final updatedNode = ArCoreRotatingNode(
                name: name,
                shape: node.shape,
                position: node.position?.value,
                rotation: vector.Vector4(x, y, z, value),
              );
              debugPrint("onDegreesPerSecondChange: $value");
              node?.degreesPerSecond.value = value;
              objectNodes[i] = updatedNode;
            }
          }
        }
      }
    });
  }

  _moveObject(String name, String direction) {
    setState(() {
      for (int i = 0; i < objectNodes.length; i++) {
        final node = objectNodes[i];
        if (node.name == name) {
          print('NODE');
          print(name);
          print(node.name);
          if (node != null && node.position != null) {
            final currentPosition = node.position?.value;
            final x = currentPosition?.x ?? 0;
            final y = currentPosition?.y ?? 0;
            final z = currentPosition?.z ?? 0;
            var new_x = direction == 'left'
                ? x - 10
                : (direction == 'right' ? x + 10 : x);
            var new_y =
                direction == 'down' ? y - 10 : (direction == 'up' ? y + 10 : y);
            final newPosition = vector.Vector3(
              new_x,
              new_y,
              z,
            );
            final updatedNode = ArCoreRotatingNode(
                name: name,
                shape: node.shape,
                position: newPosition,
                rotation: node.rotation?.value);
            print('UPDATED NODE');
            print(node.position?.value.y);
            print(updatedNode.position?.value.y);
            objectNodes[i] = updatedNode;
          }
        }
      }
    });
  }

  void _handleOnPlaneTap(List<ArCoreHitTestResult> hits) {
    final hit = hits.first;
    _addObject(hit, shape);
  }

  void onTapHandler(String name) {
    print("Flutter: onNodeTap");
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(16),
                topLeft: Radius.circular(16),
              ),
              color: Color.fromARGB(255, 216, 223, 246),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${name}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Column(
                    children: [
                      Text(
                        "Move Object",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                              width: (MediaQuery.of(context).size.width < 768)
                                  ? MediaQuery.of(context).size.width * 0.40
                                  : MediaQuery.of(context).size.width * 0.37,
                              child: ElevatedButton(
                                  child: Text(
                                    "Left",
                                    // style: TextStyle(color: Colors.black, fontSize: 16),
                                  ),
                                  style: ElevatedButton.styleFrom(),
                                  onPressed: () {
                                    print('Left');
                                    _moveObject(name, 'left');
                                  })),
                          const SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                              width: (MediaQuery.of(context).size.width < 768)
                                  ? MediaQuery.of(context).size.width * 0.40
                                  : MediaQuery.of(context).size.width * 0.37,
                              child: ElevatedButton(
                                  child: Text(
                                    "Right",
                                    // style: TextStyle(color: Colors.black, fontSize: 16),
                                  ),
                                  style: ElevatedButton.styleFrom(),
                                  onPressed: () {
                                    print('Right');
                                    _moveObject(name, 'right');
                                  })),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                              width: (MediaQuery.of(context).size.width < 768)
                                  ? MediaQuery.of(context).size.width * 0.40
                                  : MediaQuery.of(context).size.width * 0.37,
                              child: ElevatedButton(
                                  child: Text(
                                    "Up",
                                    // style: TextStyle(color: Colors.black, fontSize: 16),
                                  ),
                                  style: ElevatedButton.styleFrom(),
                                  onPressed: () {
                                    _moveObject(name, 'up');
                                  })),
                          const SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                              width: (MediaQuery.of(context).size.width < 768)
                                  ? MediaQuery.of(context).size.width * 0.40
                                  : MediaQuery.of(context).size.width * 0.37,
                              child: ElevatedButton(
                                  child: Text(
                                    "Down",
                                    // style: TextStyle(color: Colors.black, fontSize: 16),
                                  ),
                                  style: ElevatedButton.styleFrom(),
                                  onPressed: () {
                                    print('Down');
                                    _moveObject(name, 'down');
                                  })),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  // Column(
                  //   children: [
                  //     Text("Rotation"),
                  //     RotationSlider(
                  //       degreesPerSecondInitialValue: 90.0,
                  //       onDegreesPerSecondChange: (value) =>
                  //           _rotateObject(name, value),
                  //     ),
                  //   ],
                  // ),
                  SizedBox(
                    height: 8,
                  ),
                  ConstrainedBox(
                      constraints: BoxConstraints.tightFor(height: 45),
                      child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            child: Text(
                              "Delete Object",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              objectNodes.retainWhere(
                                  (element) => element.name == name);
                              arCoreController?.removeNode(nodeName: name);
                              Navigator.pop(context);
                            },
                          ))),
                ],
              ),
            ),
          );
        });
  }

  @override
  void dispose() {
    arCoreController?.dispose();
    super.dispose();
  }
}
