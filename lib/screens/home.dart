import 'package:flutter/material.dart';
import 'package:basketball_clock/screens/buttons_control.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, //Set transparent status bar 
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: Color(0xffDC330D),
          child: Row(
            children: [
              Expanded(
                child: Container(),
              ),
              Column(
                children: [
                  Expanded(
                    child: Container(),
                  ),
                  TextButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.yellow),
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
                            style: TextStyle(
                                fontSize: 30, color: Color(0xffDC330D)),
                          ),
                          SvgPicture.asset(
                            'assets/basketball_no_fire_large.svg',
                            semanticsLabel: 'Basketball Logo',
                            height: 50,
                            width: 50,
                          )
                        ],
                      )),
                  // SizedBox(
                  //   height: 50,
                  // ),
                  // TextButton(
                  //     style: ButtonStyle(
                  //         backgroundColor:
                  //             MaterialStateProperty.all(Colors.grey[300]),
                  //         shape:
                  //             MaterialStateProperty.all<RoundedRectangleBorder>(
                  //                 RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(5),
                  //         )),
                  //         elevation: MaterialStateProperty.all<double?>(10)),
                  //     onPressed: () {},
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         Text(
                  //           'Settings',
                  //           style: TextStyle(fontSize: 30),
                  //         ),
                  //         Icon(
                  //           Icons.settings,
                  //           size: 40,
                  //         )
                  //       ],
                  //     )),
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
      ),
    );
  }
}
