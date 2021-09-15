import 'package:flutter/material.dart';

class Reconnect extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          double? relativeWidthConstraints =
              constraints.maxWidth / 3; //For body divided by 3
          double? relativeHeightConstraints = constraints.maxHeight;
          return Center(
            child: Container(
                width: relativeWidthConstraints * 0.83,
                height: relativeHeightConstraints * 0.533,
                child: TextButton(
                  onPressed: () {},
                  style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(Colors.blue[200]),
                      elevation: MaterialStateProperty.all<double?>(10),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(70.0),
                      )),
                      backgroundColor: MaterialStateProperty.all(Colors.blue)),
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
                            'RECONNECT',
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
                )),
          );
        }));
  }
}
