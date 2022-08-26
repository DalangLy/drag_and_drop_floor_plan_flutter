import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin{


  List<MyTable> myTableTypes = [
    MyTable(id: '1', icon: 'assets/dining-table.png', name: 'Dining Table', ),
    MyTable(id: '2', icon: 'assets/round-table.png', name: 'Round Table'),
    MyTable(id: '៣', icon: 'assets/plant.png', name: 'Plant'),
  ];

  List<String> savedTables = [];


  List<MyTable> onStageTables = [];

  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this, value: 100);
    controller.forward();
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
                        itemCount: myTableTypes.length,
                        itemBuilder: (context, index) {
                          return Draggable<MyTable>(
                            data: myTableTypes[index],
                            feedback: Container(
                              color: Colors.transparent,
                              height: 100,
                              width: 100,
                              child: Image(image: AssetImage(myTableTypes[index].icon)),
                            ),
                            childWhenDragging: Container(
                              height: 100.0,
                              width: 100.0,
                              color: Colors.transparent,
                              child: Center(
                                child: Image(image: AssetImage(myTableTypes[index].icon)),
                                //child: Text('${myTableTypes[index].name} Dragging'),
                              ),
                            ),
                            child: Container(
                              height: 100.0,
                              width: 100.0,
                              color: Colors.transparent,
                              child: Center(
                                child: Image(image: AssetImage(myTableTypes[index].icon)),
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
                              controller: controller
                            ),
                          );
                        },
                        onWillAccept: (data) {
                          controller.repeat();
                          return true;
                        },
                        onLeave: (data) {
                          controller.animateTo(100);
                        },
                        onAccept: (data) {
                          setState(() {
                            onStageTables.removeWhere((element) => element.id == data.id);
                            controller.animateTo(100);
                            //controller.stop();
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: DragTarget<MyTable>(
                  builder: (BuildContext context, List<dynamic> accepted, List<dynamic> rejected,) {
                    return Container(
                      color: const Color(0xFFe8e8e8),
                      child: Stack(
                        children: onStageTables.map((e) {
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
                  onAcceptWithDetails: (DragTargetDetails<MyTable> details) {
                    setState(() {
                      if(details.data.isOnStage){
                        onStageTables.removeWhere((element) => element.id == details.data.id);
                      }
                      onStageTables.add(
                          MyTable(id: DateTime.now().millisecondsSinceEpoch.toString(), icon: details.data.icon, name: details.data.name, posX: details.offset.dx, posY: details.offset.dy - 124, isOnStage: true,)
                      );
                    },
                    );
                  },
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
                                  onStageTables = tt;
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
                              List<Map<String, dynamic>> ff = onStageTables.map<Map<String, dynamic>>((e) {
                                return e.toJson();
                              }).toList();
                              savedTables.add(jsonEncode(ff));
                              onStageTables.clear();
                            });
                          },
                            child: const Text('Save New'),),
                        ],
                      )
                    )
                  ],
                ),
              )
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