import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  static String get baseUrl => dotenv.get('BASE_URL');
  static String get baseUrlDev => dotenv.get('BASE_URL_DEV');

  static const clientes = '/clientes';
  static const tiposCliente = '/tipos-cliente';
  static const pedidos = '/pedidos';
  static const materiales = '/materiales';
}
