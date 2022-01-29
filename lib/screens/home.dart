import 'package:flutter/material.dart';
import 'package:basketball_clock/screens/buttons_control.dart';
import 'package:flutter/services.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: Container(
          child: Row(
            children: [
              Expanded(
                child: Container(
                    // color: Colors.red,
                    ),
              ),
              Column(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.blue,
                    ),
                  ),
                  TextButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.grey[300]),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          )),
                          elevation: MaterialStateProperty.all<double?>(10)),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ButtonsControl()));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Start',
                            style: TextStyle(fontSize: 30),
                          ),
                          Icon(
                            Icons.play_arrow_sharp,
                            size: 40,
                          )
                        ],
                      )),
                  SizedBox(
                    height: 50,
                  ),
                  TextButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.grey[300]),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          )),
                          elevation: MaterialStateProperty.all<double?>(10)),
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Settings',
                            style: TextStyle(fontSize: 30),
                          ),
                          Icon(
                            Icons.settings,
                            size: 40,
                          )
                        ],
                      )),
                  Expanded(
                    child: Container(
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Container(
                    // color: Colors.red,
                    ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
