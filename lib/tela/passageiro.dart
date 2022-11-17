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
                   zoom: 19, 
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
           zoom: 20,
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
      body: Container(
        child: GoogleMap(
           mapType: MapType.hybrid,
           onMapCreated: _onMapCreated,
           initialCameraPosition: _cameraPosition,
           myLocationEnabled: true,
        )
      )
    );
  }
}