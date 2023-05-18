import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ui_clima/model/clima_model.dart';

class ClimaApiClient {
  Future<ClimaJSON>? getCurrentClimaJSON(
      double? latitud, double? longuitud) async {
    var endpoint = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q&lat=$latitud&lon=$longuitud&lang=es&units=metric&appid=7364a5a76bd28c9ee03b102e4cae6a0d');

    var response = await http.get(endpoint);
    var body = jsonDecode(response.body);
    //var exe = ClimaJSON.fromJson(body.cityName);
    //print(ClimaJSON.fromJson(body).cityName);
    return ClimaJSON.fromJson(body);
  }
}
