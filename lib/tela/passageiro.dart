import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uber/rotas.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class Passageiro extends StatefulWidget {
  const Passageiro({super.key});

  @override
  State<Passageiro> createState() => _PassageiroState();
}

class _PassageiroState extends State<Passageiro> {
FirebaseAuth auth = FirebaseAuth.instance;
final Completer <GoogleMapController> _controller = Completer();
CameraPosition _cameraPosition = CameraPosition(
           target: LatLng(-8.85080, 13.21359),
           zoom: 20,);

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
        
        _cameraPosition = CameraPosition(
           target: LatLng(position.latitude, position.longitude),
           zoom: 16,
           tilt: 0
        );
          _movimentarCamera(_cameraPosition);
       });
 
  }
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
              myLocationEnabled: true,
              rotateGesturesEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              buildingsEnabled: false
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
                onPressed: (){}, 
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