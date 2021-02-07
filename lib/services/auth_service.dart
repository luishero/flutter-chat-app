import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:chat/global/enviromment.dart';
import 'package:chat/models/login_response.dart';
import 'package:chat/models/usuario.dart';

class AuthService with ChangeNotifier {
  Usuario usuario;
  bool _autenticando = false;

// Create storage
  final _storage = new FlutterSecureStorage();

  // Utilizacion de Provider
  bool get autenticando => this._autenticando;
  //y para establecerlo
  set autenticando(bool valor) {
    this._autenticando = valor;
    notifyListeners();
    //notifica a todos los escuchas para que se dibuje
  }

  //Getters del token de forma estática (utilizar el toke fuera de Provider)
  static Future<String> getToken() async {
    //instancia de _storage para poder leer el token
    final _storage = new FlutterSecureStorage();
    final token = await _storage.read(key: 'token');
    return token;
  }

  //Getters del token de forma estática (utilizar el toke fuera de Provider)
  static Future<void> deleteToken() async {
    //instancia de _storage para poder leer el token
    final _storage = new FlutterSecureStorage();
    await _storage.delete(key: 'token');
  }

  Future<bool> login(String email, String password) async {
    this.autenticando = true;

    final data = {'email': email, 'password': password};

    final resp = await http.post('${Enviromment.apiUrl}/login',
        body: jsonEncode(data), headers: {'Content-Type': 'application/json'});

    //print(resp.body);
    this.autenticando = false;
    if (resp.statusCode == 200) {
      final loginResponse = loginResponseFromJson(resp.body);
      //cuando tenga una autentificacion valida almaceno en :
      this.usuario = loginResponse.usuario;
      //TODO: Guardar token en lugar seguro
      await this._guardarToken(loginResponse.token);

      return true;
    } else {
      return false;
    }
  }

  Future register(String nombre, String email, String password) async {
    this.autenticando = true;
    final data = {'nombre': nombre, 'email': email, 'password': password};

    final resp = await http.post('${Enviromment.apiUrl}/login/new',
        body: jsonEncode(data), headers: {'Content-Type': 'application/json'});

    //print(resp.body);
    this.autenticando = false;
    if (resp.statusCode == 200) {
      final loginResponse = loginResponseFromJson(resp.body);
      //cuando tenga una autentificacion valida almaceno en :
      this.usuario = loginResponse.usuario;
      //TODO: Guardar token en lugar seguro
      await this._guardarToken(loginResponse.token);

      return true;
    } else {
      final respBody = jsonDecode(resp.body);
      return respBody['msg'];
    }
  }

  // checar el token valido
  Future<bool> isLoggedIn() async {
    //leer el token como en linea 110
    final token = await this._storage.read(key: 'token');

    final resp = await http.get('${Enviromment.apiUrl}/login/renew', headers: {
      'Content-Type': 'application/json',
      //Header personalizado
      'x-token': token
    });

    //print(resp.body);

    if (resp.statusCode == 200) {
      final loginResponse = loginResponseFromJson(resp.body); //lo parciamos
      //cuando tenga una autentificacion valida almaceno en :
      this.usuario =
          loginResponse.usuario; //establecemos el usuario en esta instancia
      //TODO: Guardar token en lugar seguro
      await this._guardarToken(loginResponse
          .token); //nueva vida al token,almacenado en el storage nativo

      return true;
    } else {
      //caso contrario, que el token no sea valido
      this.logout();
      return false;
    }
  }

  Future _guardarToken(String token) async {
    // Write value
    return await _storage.write(key: 'token', value: token);
  }

  Future logout() async {
    // Delete value
    await _storage.delete(key: 'token');
  }
}
