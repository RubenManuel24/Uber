import 'package:flutter/material.dart';
import 'package:uber/rotas.dart';
import 'package:uber/tela/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uber/tela/passageiro.dart';


final ThemeData temaPadrao = ThemeData(
  primaryColor: Color(0xff37474f)
  );

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(MaterialApp(
    title: "Uber",
    home: Home(),
    debugShowCheckedModeBanner: false,
    initialRoute: Rotas.ROUTE_INICIAL,
    onGenerateRoute: Rotas.routasDefinida,
  ));
}

