import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Widget Loader(BuildContext context) {
  return Center(
// Center the CircularProgressIndicator properly
    child: SizedBox(
      height: MediaQuery.of(context).size.height, // Ensures proper centering
      child: Center(
        child: SpinKitChasingDots(
          color: Colors.green.shade900,
          size: 50,
        ),
      ),
    ),
  );
}
