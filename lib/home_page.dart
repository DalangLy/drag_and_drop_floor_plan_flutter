import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin{

  late TransformationController _interactionViewerController;

  List<MyTable> availableObjects = [
    MyTable(id: '1', icon: 'assets/dining-table.png', name: 'Dining Table', ),
    MyTable(id: '2', icon: 'assets/round-table.png', name: 'Round Table'),
    MyTable(id: '៣', icon: 'assets/plant.png', name: 'Plant'),
  ];

  List<String> savedTables = [];


  List<MyTable> objectsOnCanvas = [];

  late AnimationController _trashBinAnimationController;

  double interactionCanvasOffsetX = 0;
  double interactionCanvasOffsetY = 0;
  double interactionCanvasScale = 1;

  @override
  void initState() {
    //setup trash bin animation controller
    _trashBinAnimationController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this, value: 100);
    _trashBinAnimationController.forward();

    //set up interaction viewer controller
    _interactionViewerController = TransformationController();
    _interactionViewerController.addListener(() {
      setState(() {
        interactionCanvasScale = _interactionViewerController.value.row2.b.abs();
        interactionCanvasOffsetX = _interactionViewerController.value.row0.a.abs();
        interactionCanvasOffsetY = _interactionViewerController.value.row1.a.abs();
        //print('hello');
        // print('no zoom $interactionCanvasOffsetX');
        // print('with zoom ${interactionCanvasOffsetX * interactionCanvasScale}');
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Container(
                color: Colors.blue,
                height: 100,
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: ListView.builder(
                        itemCount: availableObjects.length,
                        itemBuilder: (context, index) {
                          return Draggable<MyTable>(
                            data: availableObjects[index],
                            feedback: Container(
                              color: Colors.transparent,
                              height: 100,
                              width: 100,
                              child: Image(image: AssetImage(availableObjects[index].icon)),
                            ),
                            childWhenDragging: Container(
                              height: 100.0,
                              width: 100.0,
                              color: Colors.transparent,
                              child: Center(
                                child: Image(image: AssetImage(availableObjects[index].icon)),
                                //child: Text('${myTableTypes[index].name} Dragging'),
                              ),
                            ),
                            child: Container(
                              height: 100.0,
                              width: 100.0,
                              color: Colors.transparent,
                              child: Center(
                                child: Image(image: AssetImage(availableObjects[index].icon)),
                                // child: Column(
                                //   children: [
                                //     Image(image: AssetImage(myTableTypes[index].icon)),
                                //     //Text(myTableTypes[index].name),
                                //   ],
                                // ),
                              ),
                            ),
                          );
                        },
                        scrollDirection: Axis.horizontal,
                      ),
                    ),
                    Expanded(
                      child: DragTarget<MyTable>(
                        builder: (context, candidateData, rejectedData) {
                          return Container(
                            color: Colors.red,
                            height: double.infinity,
                            child: Lottie.asset(
                                'assets/ic_delete.json',
                              controller: _trashBinAnimationController
                            ),
                          );
                        },
                        onWillAccept: (data) {
                          _trashBinAnimationController.repeat();
                          return true;
                        },
                        onLeave: (data) {
                          _trashBinAnimationController.animateTo(100);
                        },
                        onAccept: (data) {
                          setState(() {
                            objectsOnCanvas.removeWhere((element) => element.id == data.id);
                            _trashBinAnimationController.animateTo(100);
                            //controller.stop();
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: InteractiveViewer(
                  constrained: false,
                  // onInteractionEnd: (details) {
                  //   print('on interaction end');
                  // },
                  // onInteractionStart: (details) {
                  //   print('on interaction start');
                  // },
                  scaleEnabled: false,
                  onInteractionUpdate: (details) {
                    print('on interaction update ${details.scale}');
                  },
                  transformationController: _interactionViewerController,
                  child: DragTarget<MyTable>(
                    builder: (BuildContext context, List<dynamic> accepted, List<dynamic> rejected,) {
                      return Container(
                        width: 5000,
                        height: 3200,
                        decoration: const BoxDecoration(
                          //image: DecorationImage(image: AssetImage('assets/number.jpg'), fit: BoxFit.fitWidth,),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment(0.8, 1),
                            colors: <Color>[
                              Color(0xff1f005c),
                              Color(0xff5b0060),
                              Color(0xff870160),
                              Color(0xffac255e),
                              Color(0xffca485c),
                              Color(0xffe16b5c),
                              Color(0xfff39060),
                              Color(0xffffb56b),
                            ],
                          tileMode: TileMode.mirror,
                          ),
                        ),
                        child: Stack(
                          alignment: AlignmentDirectional.center,
                          children: objectsOnCanvas.map((e) {
                            return Positioned(
                              top: e.posY,
                              left: e.posX,
                              child: Draggable<MyTable>(
                                data: e,
                                feedback: Container(
                                  color: Colors.transparent,
                                  height: 100,
                                  width: 100,
                                  child: Image(image: AssetImage(e.icon)),
                                ),
                                childWhenDragging: Container(
                                  height: 100.0,
                                  width: 100.0,
                                  color: Colors.transparent,
                                  child: const Center(
                                    //child: Text('${e.name} Dragging'),
                                  ),
                                ),
                                child: Container(
                                  height: 100.0,
                                  width: 100.0,
                                  color: Colors.transparent,
                                  child: Center(
                                    child: Image(image: AssetImage(e.icon)),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                    onMove: (details) {
                     // print('offset on move ${interactionCanvasOffsetX}');
                      //print('offset remaining ${(0.2*interactionCanvasOffsetX)}');
                     // print('detail ${details.offset.dx}');
                      print((0.2*details.offset.dx));
                    },
                    onAcceptWithDetails: (DragTargetDetails<MyTable> details) {
                      setState(() {
                        if(details.data.isOnStage){
                          objectsOnCanvas.removeWhere((element) => element.id == details.data.id);
                        }
                        objectsOnCanvas.add(
                            MyTable(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              icon: details.data.icon,
                              name: details.data.name,
                              posX: details.offset.dx + interactionCanvasOffsetX,// 100, 200, 300
                              posY: (details.offset.dy - 124) + interactionCanvasOffsetY,
                              isOnStage: true,
                            )
                        );
                      },
                      );
                    },
                  ),
                ),
              ),
              //control
              Container(
                color: Colors.green,
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 4,
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: Container(
                          color: Colors.yellow,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: savedTables.length,
                            itemBuilder: (context, index) {
                              return ElevatedButton(onPressed: (){
                                //convert string to json
                                final ff = jsonDecode(savedTables[index]);
                                List<MyTable> tt = ff.map<MyTable>((e) {
                                  return MyTable.fromRawJson(e);
                                }).toList();

                                setState(() {
                                  objectsOnCanvas = tt;
                                });
                              }, child: Text('Saved ${index+1}'));
                            },
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          const ElevatedButton(
                            onPressed: null,
                            child: Text('Update'),
                          ),
                          ElevatedButton(onPressed: (){
                            setState(() {
                              List<Map<String, dynamic>> ff = objectsOnCanvas.map<Map<String, dynamic>>((e) {
                                return e.toJson();
                              }).toList();
                              savedTables.add(jsonEncode(ff));
                              objectsOnCanvas.clear();
                            });
                          },
                            child: const Text('Save New'),),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class MyTable{
    final String id;
    final String icon;
    final String name;
    final double posX;
    final double posY;
    final bool isOnStage;
    MyTable({required this.id, required this.icon, required this.name, this.posX = 0, this.posY = 0, this.isOnStage = false,});

    factory MyTable.fromJson(String str){
      return MyTable.fromRawJson(jsonDecode(str));
    }

    factory MyTable.fromRawJson(Map<String, dynamic> json){
      return MyTable(
        id: json['id'],
        icon: json['icon'],
        name: json['name'],
        posY: json['posY'],
        posX: json['posX'],
        isOnStage: true,
      );
    }


    Map<String, dynamic> toJson(){
      return {
        'id': id,
        'icon': icon,
        'name': name,
        'posX': posX,
        'posY': posY,
      };
    }
}