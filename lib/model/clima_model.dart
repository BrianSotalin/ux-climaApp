class ClimaJSON {
  String? cityName;
  double? temp;
  double? wind;
  int? humidity;
  int? pressure;
  String? main;

  ClimaJSON(
      {this.cityName,
      this.temp,
      this.wind,
      this.humidity,
      this.pressure,
      this.main});

  //creamos un JSON dentro del model
  ClimaJSON.fromJson(Map<String, dynamic> json) {
    cityName = json["name"];
    temp = json["main"]["temp"];
    humidity = json["main"]["humidity"];
    pressure = json["main"]["pressure"];
    main = json["weather"][0]["main"];
    wind = json["wind"]["speed"];
  }
}
