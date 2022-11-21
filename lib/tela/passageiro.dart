import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uber/Util/status_requisicao.dart';
import 'package:uber/Util/usuario_fire_base.dart';
import 'package:uber/destino.dart';
import 'package:uber/model/requisicao.dart';
import 'package:uber/rotas.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:uber/usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Passageiro extends StatefulWidget {
  const Passageiro({super.key});

  @override
  State<Passageiro> createState() => _PassageiroState();
}

class _PassageiroState extends State<Passageiro> {
TextEditingController _controllerDestino = TextEditingController();
FirebaseAuth auth = FirebaseAuth.instance;
final Completer <GoogleMapController> _controller = Completer();
CameraPosition _cameraPosition = CameraPosition(
           target: LatLng(-8.85080, 13.21359),
           zoom: 20,);
Set<Marker> _marcador = {};

_onMapCreated(GoogleMapController googleMapController){
  _controller.complete(googleMapController);
}

_movimentarCamera(CameraPosition position) async {

  GoogleMapController googleMapController = await _controller.future;
  googleMapController.animateCamera(
    CameraUpdate.newCameraPosition(
       position
    )
  );

}

  List<String> listaItem = [
    "Configurações",
    "Deslogar"
  ];

  _deslogarUsuario() async {

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
 
 _localizarUsuarioAtual() async {

  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately. 
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.');
  } 
  else{

     //buscar a ultima posicao do despositio(usuario)
     Position? position = await Geolocator.getLastKnownPosition(forceAndroidLocationManager:true);

       setState((){
            if(position != null){
              
              _exibirMarcadorUsuario(position);

              _cameraPosition = CameraPosition(
                   target: LatLng(position.latitude, position.longitude),
                   zoom: 15, 
              );
           }
           _movimentarCamera(_cameraPosition);
     });

     //criar um ouvinte para a nossa localizacao
    LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 10,
    );
     StreamSubscription<Position> positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
       .listen((Position position) { 

       _exibirMarcadorUsuario(position);
        
        _cameraPosition = CameraPosition(
           target: LatLng(position.latitude, position.longitude),
           zoom: 16,
           tilt: 0
        );
          _movimentarCamera(_cameraPosition);
       });
 
  }
}

_exibirMarcadorUsuario(Position position) async {

  double pixel = MediaQuery.of(context).devicePixelRatio;
  BitmapDescriptor.fromAssetImage(
    ImageConfiguration(devicePixelRatio: pixel),
    "imagens/passageiro.png" )
    .then((BitmapDescriptor bitmapDescriptor){

     Marker marker = Marker(
    markerId: MarkerId("Lugar-Usuario"),
    position: LatLng(position.latitude, position.longitude),
    infoWindow: InfoWindow(title: "Meu local"),
    icon: bitmapDescriptor,
    );
     
     setState(() {
       _marcador.add(marker);
     });

    });
}

_chamarUber() async {

  String? enderecoDestinado = _controllerDestino.text;

  if(enderecoDestinado.isNotEmpty){

    List<Location> listaEndereco = await locationFromAddress(enderecoDestinado);

       if( listaEndereco != null && listaEndereco.isNotEmpty){
          
          Location firstLocation = listaEndereco.first;

          List<Placemark> places = await placemarkFromCoordinates(
            firstLocation.latitude, 
            firstLocation.longitude
          );

           if(places != null && places.isNotEmpty){
               
               Placemark endereco = places[0];
               
               Destino destino = Destino();
               destino.setCidade    = endereco.administrativeArea;
               destino.setCep       = endereco.postalCode;
               destino.setBairro    = endereco.subLocality;
               destino.setRua       = endereco.thoroughfare;
               destino.setNumero    = endereco.subThoroughfare;

               destino.setLatitude  = firstLocation.latitude;
               destino.setLongitude = firstLocation.longitude;
                
                String dados = "\n Cidade: "+destino.getCidade;
                       dados += "\n Rua: "+destino.getRua + ", "+ destino.getNumero;
                       dados += "\n Bairro: "+destino.getBairro;
                       dados += "\n Cep: "+destino.getCep;
          

               showDialog(
                context: context, 
                builder: (context){
                   return AlertDialog(
                    title: Text("Configuração de endereço"),
                    contentPadding: EdgeInsets.all(16),
                    content: Text(dados),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context), 
                        child: Text("Cancelar", style: TextStyle(color: Colors.red),)
                        ),
                      TextButton(
                        onPressed: (){
                          _salvarRequisicao(destino);
                          Navigator.pop(context);
                        }, 
                        child: Text("Confirmar", style: TextStyle(color: Colors.green),)
                        )
                    ],

                   );
                 }
              );
           }
       }
       else{

        showDialog(
          context: context, 
          builder: (context){
            return AlertDialog(
                title: Text("Endereço não encontrado!"),
                contentPadding: EdgeInsets.all(16),
                   );
            });
       }
  }
  else{
        showDialog(
          context: context, 
          builder: (context){
            return AlertDialog(
                title: Text("Digite um destino!"),
                contentPadding: EdgeInsets.all(16),
                   );
                });
           }
}

 //salvar requisicao
 _salvarRequisicao(Destino destino) async {

  /*

  + REQUISICAO
    + ID_REQUISICAO
      + destino (rua, endereco, latitude...)
      + passageiro (nome, email...)
      + motorista (nome, email...)
      + status (aguardando, a_caminho...finalizada)
      +
  
   */


  Usuario passageiro = await UsuarioFireBase.getDadosUsuarioLogadoAtual();

 Requisicao requisicao = Requisicao();
 requisicao.setDestino    = destino;
 requisicao.setpassageiro = passageiro;
 requisicao.setStatus     = StatusRequisicao.AGUARDANDO;

 
FirebaseFirestore db = FirebaseFirestore.instance;
  db.collection("requisicoes")
  .add(requisicao.toMap());


}

@override
  void initState() {
    super.initState();
    _localizarUsuarioAtual();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff37474f),
        title: Text("Passageiro"),
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
      body: Stack(
       children: [
           GoogleMap(
              mapType: MapType.hybrid,
              onMapCreated: _onMapCreated,
              initialCameraPosition: _cameraPosition,
              //myLocationEnabled: true,
              rotateGesturesEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              buildingsEnabled: false,
              markers: _marcador,
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.all(10),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(3),
                    color: Colors.white
                  ),
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      icon: Container(
                        margin: EdgeInsets.only(left: 10, bottom: 10),
                        width: 10,
                        height: 10,
                        child: Icon(Icons.location_on, color: Color.fromARGB(255, 252, 8, 8),),
                      ),
                      hintText: "Meu local",
                      contentPadding: EdgeInsets.only(left: 10),
                      border: InputBorder.none
                    ),
                  ),
                 ),
              )
           ),
           Positioned(
            top: 55,
            left:0,
            right: 0,
            child: Padding(padding: EdgeInsets.all(10),
              child: Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(3)
                ),
                child: TextField(
                    controller: _controllerDestino,
                    decoration: InputDecoration(
                    icon: Container(
                      margin: EdgeInsets.only(left: 10, bottom: 10),
                      width: 10,
                      height: 10,
                      child: Icon(Icons.local_taxi, color: Colors.black),
                    ),
                    hintText: "Digite o destino",
                    contentPadding: EdgeInsets.only(left: 10),
                    border: InputBorder.none
                   ),
                ),
              )
            )),
            Positioned(
              bottom:0,
              left: 0,
              right: 0,
              child: Padding(padding: EdgeInsets.all(10),
               child: Padding(padding: EdgeInsets.only(top: 10),
               child: TextButton(
                onPressed:() => _chamarUber(), 
                child: Text("Chamar Uber", 
                  style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  ),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Color(0xff1ebbd8)
                  ),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                      EdgeInsets.fromLTRB(32, 16, 32, 16)
                 )
               ),
             ),
            ),
              ) 
          )
       ],
      )
    );
  }
}