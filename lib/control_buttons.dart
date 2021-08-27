import 'package:flutter/material.dart';
import 'package:segment_display/segment_display.dart';

class ControlButtons extends StatefulWidget {
  const ControlButtons({Key? key}) : super(key: key);

  @override
  _ControlButtonsState createState() => _ControlButtonsState();
}

class _ControlButtonsState extends State<ControlButtons> {
  double? widthConstraints;
  double? heightConstraints;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Control Buttons'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            // print(constraints.maxHeight);
            widthConstraints = constraints.maxWidth / 3;
            heightConstraints = constraints.maxHeight;
            print('$widthConstraints, $heightConstraints');
            print(widthConstraints! * 0.83);

            return Container(
              child: Row(
                children: [
                  Flexible(
                    child: Container(
                        width: widthConstraints!,
                        height: heightConstraints!,
                        child: Column(children: [
                          Spacer(),
                          Padding(
                            padding: EdgeInsets.only(
                                right: widthConstraints! * 0.237),
                            child: Container(
                                width: widthConstraints! * 0.83,
                                height: heightConstraints! * 0.533,
                                child: TextButton(
                                  onPressed: () {
                                    print('START');
                                  },
                                  style: ButtonStyle(
                                      elevation:
                                          MaterialStateProperty.all<double?>(
                                              10),
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                      )),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.green[600])),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Icon(
                                        Icons.play_arrow_outlined,
                                        size: 150,
                                        color: Colors.white,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'START',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 50.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )), //Card(
                            //   elevation: 30,
                            //   color: Colors.green,
                            //   shape: RoundedRectangleBorder(
                            //     borderRadius:
                            //         BorderRadius.all(Radius.circular(10)),
                            //     side: BorderSide(color: Colors.grey),
                            //   ),
                            //   child: InkWell(
                            //     onTap: () {},
                            //     child: Container(
                            //       width: widthConstraints! * 0.83,
                            //       height: heightConstraints! * 0.533,
                            //       child: Center(
                            // child: Column(
                            //   mainAxisSize: MainAxisSize.min,
                            //   children: <Widget>[
                            //     Icon(
                            //       Icons.play_arrow_outlined,
                            //       size: 150,
                            //       color: Colors.white,
                            //     ),
                            //     Padding(
                            //       padding: const EdgeInsets.all(8.0),
                            //       child: Text(
                            //         'START',
                            //         style: TextStyle(
                            //           color: Colors.white,
                            //           fontSize: 50.0,
                            //           fontWeight: FontWeight.bold,
                            //         ),
                            //       ),
                            //     )
                            //   ],
                            // ),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          )
                        ])),
                  ),
                  Flexible(
                    child: Container(
                      width: widthConstraints,
                      child: Column(
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      splashColor: Colors.blue,
                                      splashRadius: 20,
                                      iconSize: 50,
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.add_circle_outline_outlined,
                                      ),
                                    ),
                                    IconButton(
                                      splashColor: Colors.blue,
                                      splashRadius: 20,
                                      iconSize: 50,
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.remove_circle_outline_outlined,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    SevenSegmentDisplay(
                                      value: "00:00",
                                      size: 8.0,
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      splashColor: Colors.blue,
                                      splashRadius: 20,
                                      iconSize: 50,
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.add_circle_outline_outlined,
                                      ),
                                    ),
                                    IconButton(
                                      splashColor: Colors.blue,
                                      splashRadius: 20,
                                      iconSize: 50,
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.remove_circle_outline_outlined,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  splashColor: Colors.blue,
                                  splashRadius: 30,
                                  iconSize: 80,
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.remove_circle_outline_outlined,
                                  ),
                                ),
                                SevenSegmentDisplay(
                                  value: "24",
                                  size: 15.0,
                                ),
                                IconButton(
                                  splashColor: Colors.blue,
                                  splashRadius: 30,
                                  iconSize: 80,
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.add_circle_outline_outlined,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 180,
                                      height: (heightConstraints! * 0.533) / 2,
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                            elevation: MaterialStateProperty
                                                .all<double?>(10),
                                            shape: MaterialStateProperty.all<
                                                    RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18.0),
                                            )),
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.yellow[600])),
                                        onPressed: () {},
                                        child: Icon(
                                          Icons.volume_up_outlined,
                                          color: Colors.black,
                                          size: 80,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                        width: 180,
                                        height:
                                            (heightConstraints! * 0.533) / 2,
                                        child: TextButton(
                                          onPressed: () {},
                                          style: ButtonStyle(
                                              elevation: MaterialStateProperty
                                                  .all<double?>(10),
                                              shape: MaterialStateProperty.all<
                                                      RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(18.0),
                                              )),
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors.yellow[600])),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('14',
                                                  style: TextStyle(
                                                      fontSize: 50,
                                                      color: Colors.black)),
                                            ],
                                          ),
                                        )),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(
                        width: widthConstraints!,
                        height: heightConstraints!,
                        child: Column(children: [
                          Spacer(),
                          Padding(
                            padding: EdgeInsets.only(
                                left: widthConstraints! * 0.237),
                            child: Card(
                              elevation: 30,
                              color: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(70)),
                                side: BorderSide(color: Colors.grey),
                              ),
                              child: Container(
                                width: widthConstraints! * 0.83,
                                height: heightConstraints! * 0.533,
                                child: InkWell(
                                  onTap: () {
                                    //Scaffold.of(context).showSnackBar(
                                    //SnackBar(content: Text("Selected Item $position")));
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (_) => position == 0 ? RemotePage() : HomePage(),
                                    //     fullscreenDialog: true,
                                    //   ),
                                    // );
                                  },
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Icon(
                                          Icons.restart_alt_outlined,
                                          size: 150,
                                          color: Colors.white,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'RESTART',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 50.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ])),
                  ),
                ],
              ),
            );
          })),
    );
  }

  fetchContainerSize(myselfContext) {
    MediaQueryData queryData;
    queryData = MediaQuery.of(myselfContext);
    print('width:${queryData.size.width}, height:${queryData.size.height}');
  }
}

enum ButtonState { START, PAUSE, RESET }
