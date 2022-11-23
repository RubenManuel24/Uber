import 'package:flutter/material.dart';
import 'package:uber/tela/cadastro.dart';
import 'package:uber/tela/corrida.dart';
import 'package:uber/tela/home.dart';
import 'package:uber/tela/motorista.dart';
import 'package:uber/tela/passageiro.dart';
class Rotas{

  static const ROUTE_INICIAL = "/";
  static const ROUTE_CADASTRO = "/cadastro";
  static const ROUTE_PASSAGEIRO = "/passageiro";
  static const ROUTE_MOTORISTA = "/motorista";
  static const ROUTE_CORRIDA = "/corrida";


  static Route<dynamic>? routasDefinida(RouteSettings routeSettings){

    var arg = routeSettings.arguments;

    switch(routeSettings.name){
      case ROUTE_INICIAL:
        return MaterialPageRoute(
                 builder: (_) => Home()
               );

      case ROUTE_CADASTRO:
        return MaterialPageRoute(
                builder:  (_) => Cadastro()
              );

      case ROUTE_PASSAGEIRO:
        return MaterialPageRoute(
                builder:  (_) => Passageiro()
              );

     case ROUTE_MOTORISTA:
        return MaterialPageRoute(
                builder:  (_) => Motorista()
              );

    case ROUTE_CORRIDA:
        return MaterialPageRoute(
                builder:  (_) => Corrida( arg )
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