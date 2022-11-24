class Destino {

  var _rua;
  var _numero;
  var _cidade;
  var _bairro;
  var _cep;

  var _latitude;
  var _longitude;

  Destino();

  String get getRua => this._rua;

  set setRua(String? rua){
    this._rua = rua;
  }

  String get getNumero => this._numero;

  set setNumero(String? numero){
    this._numero = numero;
  }

 String get getCidade => this._cidade;

  set setCidade(String? cidade){
    this._cidade = cidade;
  }

 String get getBairro => this._bairro;

  set setBairro(String? bairro){
    this._bairro = bairro;
  }

  String get getCep => this._cep;

  set setCep(String? cep){
    this._cep = cep;
  }

 double get getLatitude => this._latitude;

  set setLatitude(double? latitude){
    this._latitude = latitude;
  }

 double get getLongitude => this._longitude;

  set setLongitude(double? longitude){
    this._longitude = longitude;
  }
}
