

import 'package:flutter/material.dart';
import 'package:uber/rotas.dart';
import 'package:uber/usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  FirebaseAuth auth = FirebaseAuth.instance;
  
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerSenha = TextEditingController();
  String _capturaErro = "";
  bool _carregando = false;

    void _validarCampo(){

    if(_controllerEmail.text.isNotEmpty){
      if(_controllerEmail.text.contains("@")){
        if(_controllerEmail.text.isNotEmpty){
          if(_controllerSenha.text.length > 6){

            Usuario usuario = Usuario();
            usuario.setEmail       = _controllerEmail.text;
            usuario.setSenha       = _controllerSenha.text;

            _logarUsuario(usuario);

          }
          else{
            setState(() {
               _capturaErro = "A senha tem que ter mais de 6 caracteres!";
             });
          }

        }
        else{
          setState(() {
               _capturaErro = "Preencha a senha!";
             });
        }
      }
      else{
        setState(() {
               _capturaErro = "O e-mail tem que ter @!";
             });
      }
    }
    else{
     setState(() {
               _capturaErro = "Preencha o e-mail!";
             });
    }

   }

   _logarUsuario(Usuario usuario){

   auth.signInWithEmailAndPassword(
    email: usuario.getEmail, 
    password: usuario.getSenha)
    .then((firebaseUser){
      
      setState(() {
         _carregando = true;
      });

      _capturarTipoUsuarioParaLogar(firebaseUser.user?.uid);
        //return Navigator.pushNamedAndRemoveUntil(context, Rotas.ROUTE_PASSAGEIRO, (route) => false);
    })
    .catchError((error){
       _capturaErro = "Erro ao tentar logar, tenta verificar melhor os campos email e senha!";
    });

   }

  _capturarTipoUsuarioParaLogar(var id) async {
   
   FirebaseFirestore db = FirebaseFirestore.instance;
     var snapshot = await db.collection("usuario")
                                     .doc(id)
                                     .get();
      
     Map<String, dynamic>? map = snapshot.data();
     String tipo = map!["tipo"];

     setState(() {
         _carregando = false;
      });

     switch(tipo){
       case "Passageiro":
          return Navigator.pushNamedAndRemoveUntil(context, Rotas.ROUTE_PASSAGEIRO, (route) => false);
       case "Motorista":
          return Navigator.pushNamedAndRemoveUntil(context, Rotas.ROUTE_MOTORISTA, (route) => false);
     }

   }
   
   _verificarUserLogado(){
    FirebaseAuth auth = FirebaseAuth.instance;
    var usuarioLogado = auth.currentUser;

    if(usuarioLogado != null){
      _capturarTipoUsuarioParaLogar(usuarioLogado.uid);
    }

   }

   @override
  void initState() {
    super.initState();
    _verificarUserLogado();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("imagens/fundo.png"),
            fit: BoxFit.cover,
            ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
               children: [
                Padding(padding: EdgeInsets.only(top: 60),
                child: Image.asset("imagens/logo.png",
                 width: 200 ,
                 height: 150,
                )
              ),
              Padding(padding: EdgeInsets.only(top: 30),
               child: TextField(
                controller: _controllerEmail,
                keyboardType: TextInputType.emailAddress,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "E-mail",
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)
                  )
                ),
               )
              ),
              Padding(padding: EdgeInsets.only(top: 5),
               child: TextField(
                autocorrect: true,
                controller: _controllerSenha,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: "Senha",
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)
                  )
                ),
               )
              ),
              Padding(padding: EdgeInsets.only(top: 10),
               child: TextButton(
                onPressed: _validarCampo, 
                child: Text("Entrar", 
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
              Padding(padding: EdgeInsets.only(top: 15, bottom: 5),
               child: Center(
                child:  GestureDetector(
                  onTap: (){
                    Navigator.pushNamed(context, Rotas.ROUTE_CADASTRO);
                  },
                  child: Text("Não tem conta? cadastra-se!",
                              style: TextStyle(
                                color: Colors.white
                              )),
                ),
               )
              ),
              _carregando ? Center(child: CircularProgressIndicator( 
                                     color: Colors.white,
                                     backgroundColor: Color(0xff1ebbd8),
                                     ))
                        : Container(),
              Padding(padding: EdgeInsets.only(top: 15, bottom: 15),
                  child: Center(
                    child: Text(
                      _capturaErro,
                     style: TextStyle(
                      color: Colors.red
                     )
                   )
                  )
                )
             ],
            ),
          )
        )
     )
   );
  }
}
