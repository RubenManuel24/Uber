class Usuario{

var _nome;
var _email;
var _senha;
var _idUsuario;
var _tipoUsuario;

var _latitude;
var _longitude;

Usuario();

String verificaTipoUsuario(bool condicao){
   return this._tipoUsuario = condicao ? "Motorista": "Passageiro";
}

String get getNome => this._nome;

set setNome(String nome){
  this._nome = nome;
}

String get getEmail => this._email;

set setEmail(String email){
  this._email = email;
}

String get getSenha => this._senha;

set setSenha(String senha){
  this._senha = senha;
}

String get getIdUsuario => this._idUsuario;

set setIdUsuario(String idUsuario){
  this._idUsuario = idUsuario;
}

String get getTipoUsuario => this._tipoUsuario;

set setTipoUsuario(String tipoUsuario){
  this._tipoUsuario = tipoUsuario;
}

double get getLatitude => this._latitude;

set setLatitude(double latitude){
  this._latitude = latitude;
}

double get getLongitude => this._longitude;

set setLongitude(double longitude){
  this._longitude = longitude;
}

Map<String, dynamic> toMap(){

  Map<String, dynamic> map = {
    "nome"  : this._nome,
    "email" : this._email,
    "tipo"  : this._tipoUsuario, 
    "latitude"  : this._latitude, 
    "longitude"  : this._longitude, 
  };

  return map;

}



}