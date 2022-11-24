import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uber/rotas.dart';
import 'package:uber/model/usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;

  var _tipoUsuario = false;
  String _messagemError = "";

 final TextEditingController _controllerNome = TextEditingController();
 final TextEditingController _controllerEmail = TextEditingController();
 final TextEditingController _controllerSenha = TextEditingController();
  

   void _validarCampo(){

     String nome  =  _controllerNome.text;
     String email =  _controllerEmail.text;
     String senha =  _controllerSenha.text;

     if(nome.isNotEmpty){
        if(email.isNotEmpty && email.contains("@")){
           if(senha.isNotEmpty && senha.length > 6){

            Usuario usuario = Usuario();
            usuario.setNome        = nome;
            usuario.setEmail       = email;
            usuario.setSenha       = senha;
            usuario.setTipoUsuario = usuario.verificaTipoUsuario(_tipoUsuario);

            _cadastrarUsuario(usuario);

           }
           else{
            setState(() {
               _messagemError = "Preencha a senha, tem que ter mais de 6 caracters!";
             });
             
           }
        }
        else{
           setState(() {
             _messagemError = "Preencha o e-mail, tem que ter @.";
          });
        }
    }
    else{
        setState(() {
           _messagemError = "Preencha o nome, tem que ter mais de 5 caracters!";
        });
      }
   }
  

   _cadastrarUsuario(Usuario usuario){
    
    auth.createUserWithEmailAndPassword(
      email: usuario.getEmail, 
      password: usuario.getSenha
      ).then((firebaseUsuario) {

        db.collection("usuario")
         .doc(firebaseUsuario.user?.uid)
         .set(usuario.toMap());

         switch(usuario.getTipoUsuario){
            case "Passageiro":
              return Navigator.pushNamedAndRemoveUntil(context, Rotas.ROUTE_PASSAGEIRO, (route) => false);

            case "Motorista":
              return Navigator.pushNamedAndRemoveUntil(context, Rotas.ROUTE_MOTORISTA, (route) => false);
         }

      })
      .catchError((error){
        _messagemError = "Erro ao tentar se cadastrar, tenta verificar melhor os campos!";
    });
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff37474f),
        title: Text("Cadastro"),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
               children: [
              Padding(padding: EdgeInsets.only(top: 5),
               child: TextField(
                controller: _controllerNome,
                keyboardType: TextInputType.text,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Nome",
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)
                  )
                ),
               )
              ),
              Padding(padding: EdgeInsets.only(top:3),
               child: TextField(
                controller: _controllerEmail,
                keyboardType: TextInputType.emailAddress,
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
              Padding(padding: EdgeInsets.only(top: 3),
               child: TextField(
                controller: _controllerSenha,
                obscureText: true,
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
              Padding(padding: EdgeInsets.only(top: 10, bottom: 5),
               child: Row(
                children: [
                  Text("Passageiro"),
                  Padding(padding: EdgeInsets.only(left: 3, right:3),
                   child: Switch(
                    activeColor: Color(0xff37474f),
                    value: _tipoUsuario,
                    onChanged: (valor){
                      setState(() {
                         _tipoUsuario = valor;
                      });

                    },
                   )
                  ),
                  Text("Motorista")
                ],
               )
              ),
              Padding(padding: EdgeInsets.only(top: 10),
               child: TextButton(
                onPressed: _validarCampo, 
                child: Text("Cadastrar", 
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
              Padding(padding: EdgeInsets.only(top: 15, bottom: 15),
                  child: Center(
                    child: Text(
                        _messagemError,
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