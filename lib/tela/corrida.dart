import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber/Util/status_requisicao.dart';
import 'package:uber/Util/usuario_fire_base.dart';
import 'package:uber/model/usuario.dart';
class Corrida extends StatefulWidget {

var argumentoIdRequisicao;

Corrida(this.argumentoIdRequisicao);

  @override
  State<Corrida> createState() => _CorridaState();
}

class _CorridaState extends State<Corrida> {
  String _nomeButton = "Aceitar corrida";
  Color _corButton   = Color(0xff1ebbd8);
  var _functionAceitarCorrida;
  final Completer <GoogleMapController> _controller = Completer();
  CameraPosition _cameraPosition = CameraPosition(
           target: LatLng(-8.85080, 13.21359),
           zoom: 20,);
 Set<Marker> _marcador = {};
 Map<String, dynamic>? _dadosRequisicao = {};
 Position? _localMotorista;

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

_exibirMarcadorUsuario(Position position) async {

  double pixel = MediaQuery.of(context).devicePixelRatio;
  BitmapDescriptor.fromAssetImage(
    ImageConfiguration(devicePixelRatio: pixel),
    "imagens/motorista.png" )
    .then((BitmapDescriptor bitmapDescriptor){

     Marker marker = Marker(
    markerId: MarkerId("Lugar-Motorista"),
    position: LatLng(position.latitude, position.longitude),
    infoWindow: InfoWindow(title: "Meu local"),
    icon: bitmapDescriptor,
    );
     
     setState(() {
       _marcador.add(marker);
     });

    });
}

_statusButaoChamarUber (String nomeButao, Color corButao, Function funcaoAceitarCorrida){
  setState((){
      _nomeButton = nomeButao;
      _corButton  = corButao;
      _functionAceitarCorrida= funcaoAceitarCorrida;
  });
 
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
          setState((){
            _localMotorista = position;
          });
          
       });
 
  }
}

//Metodo para recuperar as requisicoes do motoristas
_recuperarRequisicao() async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  String  idRequisicao = widget.argumentoIdRequisicao;
  var documentSnapshot = await db
    .collection("requisicoes")
    .doc(idRequisicao).get();

   _dadosRequisicao = documentSnapshot.data();
   _adicionarListenerRequisicao();


}

_adicionarListenerRequisicao() async {

  FirebaseFirestore db = FirebaseFirestore.instance;
  String idRequisicao = _dadosRequisicao!["id"];
  await db.collection("requisicoes")
   .doc(idRequisicao).snapshots().listen((snapshot) { 

     if( snapshot.data() != null){

      Map<String, dynamic>? dados = snapshot.data();
      String status = dados!["status"];

      switch(status){

        case StatusRequisicao.AGUARDANDO :

          _statusAguardando();

         break;

        case StatusRequisicao.A_CAMINHO :
          
          _statusACaminho();

         break;

        case StatusRequisicao.VIAGEM :
         
         break;

        case StatusRequisicao.FINALIZADA :
         
         break;git 
        
        case StatusRequisicao.CANCELADA :

         break;

      }

     }

   });
   
}

_statusAguardando(){
   _statusButaoChamarUber(
    "Aceitar corrida", 
    Color(0xff1ebbd8),  
    (){  _aceitarCorrida();}
    );
}

_statusACaminho(){
   _statusButaoChamarUber(
    "A caminho do passageiro", 
    Colors.blueGrey.shade200,  
    (){ null;}
    );
}

_aceitarCorrida() async {

  //Recuperando dados do motorista
   Usuario motorista = await UsuarioFireBase.getDadosUsuarioLogadoAtual();
   motorista.setLatitude = _localMotorista!.latitude;
   motorista.setLongitude = _localMotorista!.longitude;

  FirebaseFirestore db = FirebaseFirestore.instance;
  String idRequisicao = _dadosRequisicao!["id"];

  db.collection("requisicoes")
  .doc(idRequisicao).update(
    {
      "motorista" :motorista.toMap(),
      "status"    : StatusRequisicao.A_CAMINHO
    }
  ).then((_) {

    //atualizar requisicao ativa
    String idPassageiro = _dadosRequisicao!["passageiro"]["idUsuario"];
     db.collection("requisicao_ativa")
     .doc(idPassageiro)
     .update({
        "status": StatusRequisicao.A_CAMINHO
     });

    //Salvar requisicao ativa para motorista
    String idMotorista = motorista.getIdUsuario;
     db.collection("requisicao_ativa_motorista")
     .doc(idMotorista)
     .set({
            "id_requisicao":idRequisicao,
            "id_usuario": idMotorista,
            "status": StatusRequisicao.A_CAMINHO
     });

  });

  
}
  

@override
  void initState() {
    super.initState();
    _localizarUsuarioAtual();

    //Recuperar requisicao e
    // adicionar listener para mudanca de statu
    _recuperarRequisicao();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff37474f),
        title: Text("Corrida"),
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
              bottom:0,
              left: 0,
              right: 0,
              child: Padding(padding: EdgeInsets.all(10),
               child: Padding(padding: EdgeInsets.only(top: 10),
               child: TextButton(
                onPressed:  _functionAceitarCorrida,
                child: Text(_nomeButton, 
                  style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  ),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      _corButton
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
    ),
    );
    
  }
}