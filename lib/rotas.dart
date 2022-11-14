import 'package:flutter/material.dart';
import 'package:uber/tela/cadastro.dart';
import 'package:uber/tela/home.dart';
class Rotas{

  static const ROUTE_INICIAL = "/";
  static const ROUTE_CADASTRO = "/cadastro";


  static Route<dynamic>? routasDefinida(RouteSettings routeSettings){
    
    switch(routeSettings.name){
      case ROUTE_INICIAL:
        return MaterialPageRoute(
                 builder: (_) => Home()
               );

      case ROUTE_CADASTRO:
        return MaterialPageRoute(
                builder:  (_) => Cadastro()
              );

      default: {
        return MaterialPageRoute(builder: (_){
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Color(0xff37474f),
              title: Text("Tela desconhecida!"),
            ),
            body: Center(
              child: Text("Tela desconhecida!"),
            ),
          );
        });
      }
 
    }
  }
}