//metodos estaticos ,se accede sin instaciar
import 'dart:io';

class Enviromment {
  static String apiUrl = Platform.isAndroid
      ? 'http://10.0.2.2:3000/api'
      : 'http://localhost:3000/api';

  static String socketUrl =
      Platform.isAndroid ? 'http://10.0.2.2:3000' : 'http://localhost:3000';
}
