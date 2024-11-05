import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget noData(String title){
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset("assets/no_data.gif",height: 150,), // Adjust height as needed
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    ),
  );
}