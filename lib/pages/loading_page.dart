import 'package:chat/pages/usuarios_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chat/services/auth_service.dart';

import 'login_page.dart';

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: checkLoginState(context), //mando el context de l21
          builder: (context, snapshot) {
            return Center(
              child: Text('Espere....'),
            );
          }),
    );
  }

  //Future que haga la verificacion
  Future checkLoginState(BuildContext context) async {
    //aqui utilizar la instancia del Provider
    final authService = Provider.of<AuthService>(context, listen: false);

    final autenticando = await authService.isLoggedIn();

    if (autenticando) {
      //TODO: conectar al socket server
      //Navigator.pushReplacementNamed(context, 'usuarios');
      Navigator.pushReplacement(
          context,
          PageRouteBuilder(
              pageBuilder: (_, __, ___) => UsuariosPage(),
              transitionDuration: Duration(milliseconds: 0)));
    } else {
      //Navigator.pushReplacementNamed(context, 'login');
      Navigator.pushReplacement(
          context,
          PageRouteBuilder(
              pageBuilder: (_, __, ___) => LoginPage(),
              transitionDuration: Duration(milliseconds: 0)));
    }
  }
}
