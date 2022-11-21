import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uber/usuario.dart';

class UsuarioFireBase {

  static Future<User?> getUsuarioAtual() async {
   FirebaseAuth auth = FirebaseAuth.instance;
   return await auth.currentUser;

  }

  static Future<Usuario> getDadosUsuarioLogadoAtual() async {
    var firebaseUser = await getUsuarioAtual();
    String idUsuario = firebaseUser!.uid;

    
   FirebaseFirestore db = FirebaseFirestore.instance;
   
   var snapshot =  await db.collection("usuario")
    .doc(idUsuario)
    .get();

    Map<String, dynamic>? dados = snapshot.data();
    String tipoUsuario = dados!["tipo"];
    String email = dados["email"];
    String nome = dados["nome"];

    Usuario usuario = Usuario();
    usuario.setIdUsuario   = idUsuario;
    usuario.setTipoUsuario = tipoUsuario;
    usuario.setEmail       = email;
    usuario.setNome        = nome;

    return usuario;

  }

}
