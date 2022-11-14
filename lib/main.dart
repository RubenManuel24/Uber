import 'package:flutter/material.dart';
import 'package:uber/tela/home.dart';
 
final ThemeData temaPadrao = ThemeData(
  primaryColor: Color(0xff37474f)
  );

void main() {
  
  runApp(MaterialApp(
    title: "Uber",
    home: Home(),
    debugShowCheckedModeBanner: false,
  ));
}

