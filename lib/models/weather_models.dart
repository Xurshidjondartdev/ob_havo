import 'dart:convert';
WeatherModel weatherModelFromJson(String str) => WeatherModel.fromJson(json.decode(str));
String weatherModelToJson(WeatherModel data) => json.encode(data.toJson());

class WeatherModel {
  WeatherModel({
      this.cloudPct, 
      this.temp, 
      this.feelsLike, 
      this.humidity, 
      this.minTemp, 
      this.maxTemp, 
      this.windSpeed, 
      this.windDegrees, 
      this.sunrise, 
      this.sunset,});

  WeatherModel.fromJson(dynamic json) {
    cloudPct = json['cloud_pct'];
    temp = json['temp'];
    feelsLike = json['feels_like'];
    humidity = json['humidity'];
    minTemp = json['min_temp'];
    maxTemp = json['max_temp'];
    windSpeed = json['wind_speed'];
    windDegrees = json['wind_degrees'];
    sunrise = json['sunrise'];
    sunset = json['sunset'];
  }
  int? cloudPct;
  int? temp;
  int? feelsLike;
  int? humidity;
  int? minTemp;
  int? maxTemp;
  double? windSpeed;
  int? windDegrees;
  int? sunrise;
  int? sunset;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['cloud_pct'] = cloudPct;
    map['temp'] = temp;
    map['feels_like'] = feelsLike;
    map['humidity'] = humidity;
    map['min_temp'] = minTemp;
    map['max_temp'] = maxTemp;
    map['wind_speed'] = windSpeed;
    map['wind_degrees'] = windDegrees;
    map['sunrise'] = sunrise;
    map['sunset'] = sunset;
    return map;
  }

}