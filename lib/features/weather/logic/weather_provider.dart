import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/helper/local_storage.dart';
import 'package:flutter_application_1/core/networking/api_constant.dart';
import 'package:flutter_application_1/core/networking/dio_factory.dart';
import 'package:flutter_application_1/features/weather/models/weather_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class WeatherProvider extends ChangeNotifier {
  LocationModel? locations;

  void getLocations() async {
    try {
      final response = await DioFactory.getData(ApiConstant.forecastPath, {
        'key': ApiConstant.apiKey,
        'q': currentLocation,
      });
      final data = WeatherResponseModel.fromJson(response.data);
      locations = data.locations;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching locations: $e');
    }
  }

  Future<void> checkLocationPer() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      debugPrint('There is no permission');
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      openAppSettings();
      notifyListeners();
    }
    getCurrentLoc();
    notifyListeners();
    debugPrint(permission.toString());
  }

  String currentLocation = '';
  Future<void> getCurrentLoc() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    currentLocation = '${position.latitude}, ${position.longitude}';
    searchForCity(currentLocation);
    notifyListeners();
    debugPrint('Current Location: $currentLocation');
  }

  Future<void> openLocation(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      await launchUrl(uri);
    } catch (e) {
      debugPrint('Error with Position $e');
    }
  }

  CurrentModel? currentModel;

  void getCurrent() async {
    try {
      final response = await DioFactory.getData(ApiConstant.forecastPath, {
        'key': ApiConstant.apiKey,
        'q': currentLocation,
      });
      final data = WeatherResponseModel.fromJson(response.data);
      currentModel = data.current;
      notifyListeners();
    } catch (e) {
      debugPrint('Error with current:$e');
    }
  }

  ConditionModel? condition;
  void getCondition() async {
    try {
      final response = await DioFactory.getData(ApiConstant.forecastPath, {
        'key': ApiConstant.apiKey,
        'q': currentLocation,
      });
      final data = WeatherResponseModel.fromJson(response.data);
      condition = data.current.condition;
      notifyListeners();
    } catch (e) {
      debugPrint('Error with condition: $e');
    }
  }

  List<ForecastDayModel> forecastDays = [];
  void getForecast() async {
    try {
      final response = await DioFactory.getData(ApiConstant.forecastPath, {
        'key': ApiConstant.apiKey,
        'q': currentLocation,
        'days': 1,
      });
      final data = WeatherResponseModel.fromJson(response.data);
      forecastDays = data.forecast.forecastDay;
      notifyListeners();
    } catch (e) {
      debugPrint('Error with forecast: $e');
    }
  }

  final searchController = TextEditingController();

  void searchForCity(String cityName) async {
    try {
      final query =
          cityName.trim().isNotEmpty
              ? cityName.trim()
              : searchController.text.trim().isNotEmpty
              ? searchController.text.trim()
              : currentLocation;
      final response = await DioFactory.getData(ApiConstant.forecastPath, {
        'key': ApiConstant.apiKey,
        'q': query,
      });
      final data = WeatherResponseModel.fromJson(response.data);
      locations = data.locations;
      currentModel = data.current;
      condition = data.current.condition;
      forecastDays = data.forecast.forecastDay;
      notifyListeners();
    } catch (e) {
      debugPrint('Error with searchForCity: $e');
    }
  }

  final Map<String, String> weatherAnimation = {
    'Sunny': 'assets/lottie/sunny.json',
    'Partly cloudy': 'assets/lottie/partly_cloudy.json',
    'Partly cloudy ': 'assets/lottie/partly_cloudy.json',
    'Moderate rain': 'assets/lottie/moderate_rain.json',
    'Patchy rain nearby': 'assets/lottie/patchy_rain_nearby.json',
    'Clear': 'assets/lottie/clear.json',
    'Clear ': 'assets/lottie/clear.json',
    'Cloudy': 'assets/lottie/overcast.json',
    'Cloudy ': 'assets/lottie/overcast.json',
    'Overcast': 'assets/lottie/overcast.json',
    'Overcast ': 'assets/lottie/overcast.json',
  };

  bool getIsDark() => LocalStorage.getBool('isDark') ?? false;

  void toggleDarkMode() async {
    await LocalStorage.setBool(('isDark'), !getIsDark());
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
