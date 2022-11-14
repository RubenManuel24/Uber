import 'package:flutter/material.dart';
import 'package:uber/rotas.dart';
import 'package:uber/tela/cadastro.dart';
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _nameState();
}

class _nameState extends State<Home> {
  
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerNome = TextEditingController();

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
                controller: _controllerNome,
                keyboardType: TextInputType.text,
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
              Padding(padding: EdgeInsets.only(top: 10),
               child: TextButton(
                onPressed: (){}, 
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
              Padding(padding: EdgeInsets.only(top: 15),
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
              Padding(padding: EdgeInsets.only(top: 15, bottom: 15),
                  child: Center(
                    child: Text("ERRO!",
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
