class WeatherApiModel {
  double? temperature;
  int? humidity;
  double? uvIndex;
  double? carbonMonoxide;

  WeatherApiModel({this.temperature, this.humidity, this.uvIndex, this.carbonMonoxide});

  WeatherApiModel fromJson(Map<String, dynamic> json) {
    return WeatherApiModel(temperature: json['current']['temp_c'], humidity: json['current']['humidity'], uvIndex: json['current']['uv'], carbonMonoxide: json['current']['air_quality']['co']);
  }
}
