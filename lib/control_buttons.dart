import 'package:flutter/material.dart';

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
                                  color: Colors.blueGrey,
                                  child: Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: TextButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.red)),
                                        onPressed: () {},
                                        child: Text('START'),
                                      ))))
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
                                      iconSize: 50,
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.add_circle_outline_outlined,
                                      ),
                                    ),
                                    IconButton(
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
                                    Text(
                                      '00:00',
                                      style: TextStyle(fontSize: 50),
                                    )
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      iconSize: 50,
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.add_circle_outline_outlined,
                                      ),
                                    ),
                                    IconButton(
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
                                  iconSize: 80,
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.add_circle_outline_outlined,
                                  ),
                                ),
                                Text(
                                  '24',
                                  style: TextStyle(fontSize: 150),
                                ),
                                IconButton(
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
                                      height: 80,
                                      color: Colors.yellow[600],
                                      child: Icon(
                                        Icons.volume_up_outlined,
                                        size: 80,
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
                                        height: 80,
                                        color: Colors.yellow[600],
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text('14',
                                                style: TextStyle(fontSize: 65)),
                                          ],
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
                              child: Container(
                                  width: widthConstraints! * 0.83,
                                  height: heightConstraints! * 0.533,
                                  color: Colors.blueGrey,
                                  child: Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: TextButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.red)),
                                        onPressed: () {},
                                        child: Text('START'),
                                      ))))
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
