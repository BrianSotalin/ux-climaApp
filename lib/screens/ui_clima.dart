import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ui_clima/model/clima_model.dart';
import 'package:ui_clima/services/clima_api_client.dart';
import 'package:geolocator/geolocator.dart';

class ClimaUI extends StatelessWidget {
  ClimaApiClient client = ClimaApiClient();
  ClimaJSON? data;

  Future<void> getData() async {
    double latitud = 0.0;
    double longuitud = 0.0;
    Future<Position> determinePosition() async {
      LocationPermission permission;
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('error geolocator');
        }
      }
      return await Geolocator.getCurrentPosition();
    }

    Position position = await determinePosition();
    latitud = position.latitude;
    longuitud = position.longitude;
    data = await client.getCurrentClimaJSON(latitud, longuitud);
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            //redondeo de grados temperatura
            var temperatura = "${data!.temp}";
            int tempRound = 0;
            try {
              double tempx = double.parse(temperatura);
              tempRound = tempx.round();
            } catch (e) {
              tempRound = 0;
            }
            //estableciendo variables
            var hora = now.hour;
            var minuto = now.minute;
            var horario = '';
            var imgFondo = '';
            var svgClima = '';
            var weather = data!.main;
            var description = '';
            var valorViento = data!.wind;
            var valorPresion = data!.pressure;
            var valorHumedad = data!.humidity;
            double valorCargaHumedad = 0.0;
            double valorCargaPresion = 0;

            //validacion AM-PM
            if (hora < 12) {
              horario = 'AM';
            } else {
              horario = 'PM';
            }
            //validacion de ceros
            String zeroHourMin($num) {
              if ($num < 10) {
                return '0';
              } else {
                return '';
              }
            }

            //validando si horas y minutos necesitan un 0 antes
            var zeroHour = zeroHourMin(hora);
            var zeroMin = zeroHourMin(minuto);
            //definiendo fondo de pantalla
            String fondoPantalla($fondo) {
              if ($fondo == "Rain") {
                return 'rainy.jpg';
              } else if ($fondo == "Cloudy") {
                return 'cloudy.jpeg';
              }
              return 'sunny.jpg';
            }

            //inicio FUNCIONES
            //definiendo fondo de pantalla
            String iconoClima($tiempo) {
              if ($tiempo == "Rain") {
                return 'rain.svg';
              } else if ($tiempo == "Cloudy") {
                return 'cloudy.svg';
              }
              return 'sun.svg';
            }

            //definiendo descrcipcion de pantalla
            String despClima($tiempo) {
              if ($tiempo == "Rain") {
                return 'Lluvia';
              } else if ($tiempo == "Cloudy") {
                return 'Nublado';
              }
              return 'Despejado';
            }

            //valor carga de presion
            double cargaPresion($valor) {
              if ($valor <= 980) {
                return 10;
              } else if ($valor > 980 && $valor <= 1000) {
                return 20;
              } else if ($valor > 1000 && $valor <= 1013) {
                return 30;
              } else if ($valor > 1013 && $valor <= 1025) {
                return 40;
              } else {
                return 50;
              }
            }

            Color colorCargaPresion($valor) {
              if ($valor == 10) {
                return Colors.redAccent;
              } else if ($valor == 20) {
                return Colors.blueAccent;
              } else if ($valor == 50) {
                return Colors.orangeAccent;
              } else {
                return Colors.greenAccent;
              }
            }

            Color colorCargaHumedad($valor) {
              if ($valor <= 50) {
                return Colors.redAccent;
              } else if ($valor > 50 && $valor < 90) {
                return Colors.greenAccent;
              } else {
                return Colors.lightBlueAccent;
              }
            }

            Color colorCargaViento($valor) {
              if ($valor <= 10) {
                return Colors.greenAccent;
              } else if ($valor > 10 && $valor < 20) {
                return Colors.orangeAccent;
              } else {
                return Colors.redAccent;
              }
            }
            // fin FUNCIONES

            if (hora > 18 || hora < 6 && data!.main == 'Rain') {
              imgFondo = 'night.jpg';
              svgClima = 'rain.svg';
              description = 'Lluvia';
            } else if (hora > 18 || hora < 6 && data!.main != 'Rain') {
              imgFondo = 'night.jpg';
              svgClima = 'moon.svg';
              description = 'Noche';
            } else {
              imgFondo = fondoPantalla(weather);
              svgClima = iconoClima(weather);
              description = despClima(weather);
            }
            //valores de carga
            if (valorHumedad != null) {
              valorCargaHumedad = valorHumedad / 2;
            }
            valorCargaPresion = cargaPresion(valorPresion);

            return Container(
              child: Stack(
                children: [
                  Image.asset(
                    'assets/$imgFondo',
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                  ),
                  Container(
                    decoration:
                        const BoxDecoration(color: Colors.black38), //opacidad
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 120.0,
                                    ),
                                    Text(
                                      '${data!.cityName}',
                                      style: GoogleFonts.lato(
                                        fontSize: 35,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      '$zeroHour$hora:$zeroMin$minuto $horario - ${now.day}/0${now.month}/${now.year}',
                                      style: GoogleFonts.lato(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ]),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$tempRound\u2103',
                                      style: GoogleFonts.lato(
                                        fontSize: 85,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/$svgClima',
                                          width: 34,
                                          height: 34,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          description,
                                          style: GoogleFonts.lato(
                                            fontSize: 25,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ]),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 40),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white30)),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        'Viento',
                                        style: GoogleFonts.lato(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '$valorViento',
                                        style: GoogleFonts.lato(
                                          fontSize: 24,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'm/s',
                                        style: GoogleFonts.lato(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Stack(
                                        children: [
                                          Container(
                                            height: 5,
                                            width: 50,
                                            color: Colors.white38,
                                          ),
                                          Container(
                                            height: 5,
                                            width: valorViento,
                                            color:
                                                colorCargaViento(valorViento),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'Presion',
                                        style: GoogleFonts.lato(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '$valorPresion',
                                        style: GoogleFonts.lato(
                                          fontSize: 24,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'mb',
                                        style: GoogleFonts.lato(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Stack(
                                        children: [
                                          Container(
                                            height: 5,
                                            width: 50,
                                            color: Colors.white38,
                                          ),
                                          Container(
                                            height: 5,
                                            width: valorCargaPresion,
                                            color: colorCargaPresion(
                                                valorCargaPresion),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'Humedad',
                                        style: GoogleFonts.lato(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '$valorHumedad',
                                        style: GoogleFonts.lato(
                                          fontSize: 24,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '%',
                                        style: GoogleFonts.lato(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Stack(
                                        children: [
                                          Container(
                                            height: 5,
                                            width: 50,
                                            color: Colors.white38,
                                          ),
                                          Container(
                                            height: 5,
                                            width: valorCargaHumedad,
                                            color:
                                                colorCargaHumedad(valorHumedad),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return Container();
        },
      ),
    );
  }
}
