class Usuario{

var _nome;
var _email;
var _senha;
var _tipoUsuario;

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

String get getTipoUsuario => this._tipoUsuario;

set setTipoUsuario(String tipoUsuario){
  this._tipoUsuario = tipoUsuario;
}

Map<String, dynamic> toMap(){

  Map<String, dynamic> map = {
    "nome"  : this._nome,
    "email" : this._email,
    "tipo"  : this._tipoUsuario
  };

  return map;

}



}