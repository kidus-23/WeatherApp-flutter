import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  _WeatherHomePageState createState() => _WeatherHomePageState();
}

// Add this class to store weather data
class WeatherDetails {
  final Map<String, dynamic> data;
  WeatherDetails(this.data);

  double get tempC => (data['main']['temp'] - 32) * 5 / 9;
  double get feelsLikeC => (data['main']['feels_like'] - 32) * 5 / 9;
  double get tempMinC => (data['main']['temp_min'] - 32) * 5 / 9;
  double get tempMaxC => (data['main']['temp_max'] - 32) * 5 / 9;
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final location = _locationController.text;
    final apiKey = _apiKeyController.text;

    if (location.isEmpty || apiKey.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both location and API key';
        _isLoading = false;
      });
      return;
    }

    try {
      // Get current weather
      final currentUrl =
          'https://api.openweathermap.org/data/2.5/weather?q=$location&appid=$apiKey&units=metric';
      // Get forecast data
      final forecastUrl =
          'https://api.openweathermap.org/data/2.5/forecast?q=$location&appid=$apiKey&units=metric';

      final currentResponse = await http.get(Uri.parse(currentUrl));
      final forecastResponse = await http.get(Uri.parse(forecastUrl));

      if (currentResponse.statusCode == 200 &&
          forecastResponse.statusCode == 200) {
        final currentData = json.decode(currentResponse.body);
        final forecastData = json.decode(forecastResponse.body);

        setState(() {
          _isLoading = false;
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WeatherDetailsPage(
              currentWeather: currentData,
              forecast: forecastData,
              cityName: location,
            ),
          ),
        );
      } else {
        setState(() {
          _errorMessage =
              'Failed to fetch weather data. Please check your inputs.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Weather App',
          style: TextStyle(color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Enter City Name',
                    prefixIcon: Icon(Icons.location_city),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _apiKeyController,
                  decoration: const InputDecoration(
                    labelText: 'Enter OpenWeatherMap API Key',
                    prefixIcon: Icon(Icons.key),
                    border: OutlineInputBorder(),
                    helperText: 'Get your API key from openweathermap.org',
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _fetchWeather,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Get Weather'),
                ),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// New page to display weather details
class WeatherDetailsPage extends StatelessWidget {
  final Map<String, dynamic> currentWeather;
  final Map<String, dynamic> forecast;
  final String cityName;

  const WeatherDetailsPage({
    Key? key,
    required this.currentWeather,
    required this.forecast,
    required this.cityName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          // Custom App Bar
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF1565C0),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildMainWeatherCard(),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(cityName),
          ),

          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTodayDetails(),
                  const SizedBox(height: 24),
                  _buildHourlyForecast(),
                  const SizedBox(height: 24),
                  _buildWeeklyForecast(),
                  const SizedBox(height: 24),
                  _buildWeatherSummary(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainWeatherCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1565C0),
            Colors.blue[400]!,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${currentWeather['main']['temp'].round()}°',
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                currentWeather['weather'][0]['description']
                    .toString()
                    .toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Feels like ${currentWeather['main']['feels_like'].round()}°',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayDetails() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              'Humidity',
              '${currentWeather['main']['humidity']}%',
              Icons.water_drop,
            ),
            _buildDetailRow(
              'Wind',
              '${(currentWeather['wind']['speed'] * 3.6).round()} km/h',
              Icons.air,
            ),
            _buildDetailRow(
              'Pressure',
              '${currentWeather['main']['pressure']} hPa',
              Icons.speed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyForecast() {
    final hourlyList = forecast['list'].take(8).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hourly Forecast',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: hourlyList.length,
            itemBuilder: (context, index) {
              final hourData = hourlyList[index];
              final time =
                  DateTime.fromMillisecondsSinceEpoch(hourData['dt'] * 1000);

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(right: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  width: 80,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${time.hour}:00',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Image.network(
                        'https://openweathermap.org/img/wn/${hourData['weather'][0]['icon']}.png',
                        width: 40,
                        height: 40,
                      ),
                      Text(
                        '${hourData['main']['temp'].round()}°',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyForecast() {
    final dailyList = _getDailyForecast();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '8-Day Forecast',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children:
                dailyList.map((day) => _buildDailyForecastItem(day)).toList(),
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getDailyForecast() {
    final List<Map<String, dynamic>> dailyForecasts = [];
    final List items = forecast['list'];

    DateTime currentDate = DateTime.now();
    Map<String, dynamic>? currentDayData;

    for (var item in items) {
      final DateTime date =
          DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);

      if (date.day != currentDate.day) {
        if (currentDayData != null) {
          dailyForecasts.add(currentDayData);
        }
        currentDayData = item;
        currentDate = date;
      }
    }

    return dailyForecasts.take(8).toList();
  }

  Widget _buildDailyForecastItem(Map<String, dynamic> day) {
    final date = DateTime.fromMillisecondsSinceEpoch(day['dt'] * 1000);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              _getDayName(date.weekday),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Image.network(
            'https://openweathermap.org/img/wn/${day['weather'][0]['icon']}.png',
            width: 40,
            height: 40,
          ),
          Row(
            children: [
              Text(
                '${day['main']['temp_max'].round()}°',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ' / ${day['main']['temp_min'].round()}°',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _generateWeatherSummary(Map<String, dynamic> data) {
    final condition = data['weather'][0]['description'];
    final temp = currentWeather['main']['temp'].round();
    final feelsLike = currentWeather['main']['feels_like'].round();
    final humidity = currentWeather['main']['humidity'];
    final windSpeed = (currentWeather['wind']['speed'] * 3.6).round();

    return 'Currently in $cityName, the weather is $condition with a temperature of '
        '$temp°C, though it feels like $feelsLike°C. The humidity is at $humidity% '
        'with wind speeds reaching $windSpeed km/h. '
        '${_getWeatherAdvice(data)}';
  }

  String _getWeatherAdvice(Map<String, dynamic> data) {
    final condition = data['weather'][0]['main'].toString().toLowerCase();
    final temp = currentWeather['main']['temp'];

    if (condition.contains('rain')) {
      return 'Don\'t forget your umbrella!';
    } else if (temp > 30) {
      return 'It\'s quite hot - stay hydrated!';
    } else if (temp < 10) {
      return 'It\'s cold - remember to dress warmly!';
    } else {
      return 'It\'s a nice day to be outside!';
    }
  }

  String _getDayName(int day) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[day - 1];
  }

  Widget _buildWeatherSummary() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weather Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _generateWeatherSummary(currentWeather),
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DailyForecast extends StatelessWidget {
  final String day;
  final String date;
  final String conditionIcon;
  final String tempHigh;
  final String tempLow;
  final String precipitation;
  final String windSpeed;

  const DailyForecast({
    super.key,
    required this.day,
    required this.date,
    required this.conditionIcon,
    required this.tempHigh,
    required this.tempLow,
    required this.precipitation,
    required this.windSpeed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (precipitation.isNotEmpty)
            Text(
              precipitation,
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 14,
              ),
            ),
          Row(
            children: [
              Text(
                tempHigh,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              Text(
                ' / $tempLow',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          Text(
            windSpeed,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
