class WeatherResponseModel {
  final LocationModel locations;
  final CurrentModel current;
  final ForecastModel forecast;

  WeatherResponseModel({
    required this.locations,
    required this.current,
    required this.forecast,
  });

  factory WeatherResponseModel.fromJson(Map<String, dynamic> json) {
    return WeatherResponseModel(
      locations: LocationModel.fromJson(json['location']),
      current: CurrentModel.fromJson(json['current']),
      forecast: ForecastModel.fromJson(json['forecast']),
    );
  }
}

class LocationModel {
  final String name;
  final String country;
  final String localTime;
  final double lat;
  final double lon;

  LocationModel({
    required this.name,
    required this.country,
    required this.localTime,
    required this.lat,
    required this.lon,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      name: json['name'],
      country: json['country'],
      localTime: json['localtime'],
      lat: json['lat'],
      lon: json['lon'],
    );
  }
}

class CurrentModel {
  final double windMPH;
  final double windKPh;
  final String windDIR;
  final String lastUpdated;
  final double uv;
  final double tempC;
  final int humidity;
  final int cloud;
  final ConditionModel condition;

  CurrentModel({
    required this.windMPH,
    required this.windKPh,
    required this.windDIR,
    required this.lastUpdated,
    required this.uv,
    required this.tempC,
    required this.humidity,
    required this.cloud,
    required this.condition,
  });

  factory CurrentModel.fromJson(Map<String, dynamic> json) {
    return CurrentModel(
      windMPH: json['wind_mph'],
      windKPh: json['wind_kph'],
      windDIR: json['wind_dir'],
      lastUpdated: json['last_updated'],
      uv: json['uv'],
      tempC: json['temp_c'],
      humidity: json['humidity'],
      cloud: json['cloud'],
      condition: ConditionModel.fromJson(json['condition']),
    );
  }
}

class ConditionModel {
  final String text;
  final String icon;

  ConditionModel({required this.text, required this.icon});

  factory ConditionModel.fromJson(Map<String, dynamic> json) {
    return ConditionModel(text: json['text'], icon: json['icon']);
  }
}

class ForecastModel {
  final List<ForecastDayModel> forecastDay;

  ForecastModel({required this.forecastDay});

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    return ForecastModel(
      forecastDay:
          (json['forecastday'] as List<dynamic>)
              .map((e) => ForecastDayModel.fromJson(e))
              .toList(),
    );
  }
}

class ForecastDayModel {
  final String date;
  final AstroModel astro;
  final DayModel day;
  final List<HourDay> hourDays;
  ForecastDayModel({
    required this.date,
    required this.astro,
    required this.day,
    required this.hourDays,
  });

  factory ForecastDayModel.fromJson(Map<String, dynamic> json) {
    return ForecastDayModel(
      date: json['date'],
      astro: AstroModel.fromJson(json['astro']),
      day: DayModel.fromJson(json['day']),
      hourDays: HourDayResponse.fromJson(json).hourDays,
    );
  }
}

class DayModel {
  final double maxTempC;
  final double minTempC;
  final double avgTempC;
  final double maxWindKPh;
  final ConditionModel conditionDay;
  final double uV;
  DayModel({
    required this.maxTempC,
    required this.minTempC,
    required this.avgTempC,
    required this.maxWindKPh,
    required this.conditionDay,
    required this.uV,
  });

  factory DayModel.fromJson(Map<String, dynamic> json) {
    return DayModel(
      maxTempC: json['maxtemp_c'],
      minTempC: json['mintemp_c'],
      avgTempC: json['avgtemp_c'],
      maxWindKPh: json['maxwind_kph'],
      conditionDay: ConditionModel.fromJson(json['condition']),
      uV: json['uv'],
    );
  }
}

class AstroModel {
  final String sunrise;
  final String sunset;
  final String moonrise;
  final String moonset;

  AstroModel({
    required this.sunrise,
    required this.sunset,
    required this.moonrise,
    required this.moonset,
  });

  factory AstroModel.fromJson(Map<String, dynamic> json) {
    return AstroModel(
      moonrise: json['moonrise'],
      moonset: json['moonset'],
      sunrise: json['sunrise'],
      sunset: json['sunset'],
    );
  }
}

class HourDayResponse {
  final List<HourDay> hourDays;
  HourDayResponse({required this.hourDays});

  factory HourDayResponse.fromJson(Map<String, dynamic> json) {
    return HourDayResponse(
      hourDays:
          (json['hour'] as List<dynamic>)
              .map((e) => HourDay.fromJson(e))
              .toList(),
    );
  }
}

class HourDay {
  final String time;
  final double tempC;
  final ConditionModel conditionHour;
  final double windkph;
  final String winddir;

  HourDay({
    required this.time,
    required this.tempC,
    required this.conditionHour,
    required this.windkph,
    required this.winddir,
  });

  factory HourDay.fromJson(Map<String, dynamic> json) {
    return HourDay(
      time: json['time'],
      tempC: json['temp_c'],
      conditionHour: ConditionModel.fromJson(json['condition']),
      windkph: json['wind_kph'],
      winddir: json['wind_dir'],
    );
  }
}
