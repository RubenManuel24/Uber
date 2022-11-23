import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uber/Util/status_requisicao.dart';
import 'package:uber/rotas.dart';

class Motorista extends StatefulWidget {
  const Motorista({super.key});

  @override
  State<Motorista> createState() => _MotoristaState();
}

class _MotoristaState extends State<Motorista> {

final _controllerStream = StreamController<QuerySnapshot>.broadcast();
FirebaseFirestore db = FirebaseFirestore.instance;
var pressCirular = Center(
  child: CircularProgressIndicator(
    color:Color(0xff1ebbd8),
    backgroundColor: Colors.white,
  ),
);

List<String> listaItem = [
    "Configurações",
    "Deslogar"
  ];

  _deslogarUsuario() async {
   FirebaseAuth auth = FirebaseAuth.instance;

    await auth.signOut();
    return Navigator.pushNamedAndRemoveUntil(context, Rotas.ROUTE_INICIAL, (route) => false);

  }

  _itemSelecionado(String itemSelecionado){
    switch(itemSelecionado){
       case "Deslogar":
        _deslogarUsuario();
       break;
       case "Configurações":
       
       break;
    }
  }

  Stream<QuerySnapshot>? _adicionarListernerRequisicoesMotorista() {
        
     final stream = db.collection("requisicoes")
          .where("status", isEqualTo: StatusRequisicao.AGUARDANDO)
          .snapshots();
     
     stream.listen((dados) {
         _controllerStream.add(dados);
      });
  }

  @override
  void initState() {
    super.initState();
    _adicionarListernerRequisicoesMotorista();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff37474f),
        title: Text("Motorista"),
        actions: [
          PopupMenuButton<String>(
            onSelected: _itemSelecionado,
            itemBuilder: (context){
              return listaItem.map((item){
                 return PopupMenuItem(
                  value: item,
                  child: Text(item));
              }).toList();
            })
        ],
      ),
      body:StreamBuilder<QuerySnapshot>(
        stream: _controllerStream.stream,
        builder: (context, snapshot){
          switch(snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return pressCirular;
            case ConnectionState.active:
            case ConnectionState.done:
             if(snapshot.hasError){
              return Center(
                child: Text("Erro ao carregar requisições!"),
              );
             }
             else{
                QuerySnapshot querySnapshot = snapshot.requireData;
               if(querySnapshot.docs.length == 0){
                 return Center(
                   child: Text(
                     "Você não tem nenhuma requisição!",
                     style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                );
               }
               else{
                 return ListView.separated(
                   itemCount: querySnapshot.docs.length,
                   separatorBuilder: (context, int){
                    return Divider(
                        color: Colors.grey,
                        height: 10,
                    );
                  }, 
                  itemBuilder: (context, index){
                    
                    List<DocumentSnapshot> querisicoes = querySnapshot.docs.toList();
                    DocumentSnapshot dados = querisicoes[index];

                      String nomePassageiro = dados["passageiro"]["nome"];
                      String cidade = dados["destino"]["cidade"];
                      String bairro = dados["destino"]["bairro"];
                      //String rua = dados["destino"]["rua"];
                      //String numero = dados["destino"]["numero"];

                    return ListTile(
                      title: Text("Passagerio: $nomePassageiro"),
                      subtitle: Text("Cidade: $cidade, Bairro: $bairro"),
                    );

                  }, 
                  );
               }
             }

          }

        },
        )
    );
  }
}
