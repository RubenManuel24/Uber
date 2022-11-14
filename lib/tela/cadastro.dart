import 'package:flutter/material.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {

  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
   
   bool _escolhaSwitch = false;

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
                keyboardType: TextInputType.emailAddress,
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
                controller: _controllerNome,
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
                    value: _escolhaSwitch,
                    onChanged: (valor){

                      setState(() {
                         _escolhaSwitch = valor;
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
                onPressed: (){}, 
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
             ],
            ),
          )
        )
     )
   );
  }
}