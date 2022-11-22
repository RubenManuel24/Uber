import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uber/destino.dart';
import 'package:uber/usuario.dart';

class Requisicao {
 
  var  _id;
  var  _status;
  Usuario? _passageiro;
  Usuario? _motorista;
  Destino? _destino;
  
  Requisicao( ){

     FirebaseFirestore db = FirebaseFirestore.instance;
     DocumentReference ref = db.collection("requisicoes").doc();
     this._id = ref.id;

  }

  Map<String, dynamic> toMap(){
  
  Map<String, dynamic> dadosPassageiro = {

    "nome"         : this._passageiro?.getNome,
    "email"        : this._passageiro?.getEmail,
    "tipoUsuario"  : this._passageiro?.getTipoUsuario,
    "idUsuario"    : this._passageiro?.getIdUsuario
  };

  Map<String, dynamic> dadosDestino = {
    "cidade"    : this._destino?.getCidade,
    "rua"       : this._destino?.getRua,
    "numero"    : this._destino?.getNumero,
    "bairro"    : this._destino?.getBairro,
    "cep"       : this._destino?.getCep,
    "latitude"  : this._destino?.getLatitude,
    "longitude" : this._destino?.getLongitude
  };


  Map<String, dynamic> dadosRequisicao = {
    "passageiro" : dadosPassageiro,
    "id"         : this._id,
    "status"     : this._status,
    "motorista"  : null,
    "destino"    : dadosDestino
  };

  return dadosRequisicao;

}


  String get getId => this._id;
  
  set setId(String id){
    this._id = id;
  }

  String get getStatus => this._status;

  set setStatus(String status){
    this._status = status;
  }

  Usuario? get getPassageiro => this._passageiro;

  set setpassageiro(Usuario passageiro){
    this._passageiro = passageiro;
  }

  Usuario? get getMotorista => this._motorista;

  set setMotorista(Usuario motorista){
    this._motorista = motorista;
  }

  Destino? get getDestino => this._destino;

  set setDestino(Destino destino){
    this._destino = destino;
  }
}
