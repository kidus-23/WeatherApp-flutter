import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
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
      home: const WeatherHomePage(),
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF2980B9),
        elevation: 0,
        title: const Text(
          'Weather App',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF2980B9),
                  const Color(0xFF2980B9).withOpacity(0.8),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _locationController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Enter City Name',
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.location_city,
                          color: Colors.white, weight: 700),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white70),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white70),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _apiKeyController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Enter OpenWeatherMap API Key',
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.key,
                          color: Colors.white, weight: 700),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white70),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white70),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      helperText: '', // Empty helper text
                      helperStyle: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                    child: Row(
                      children: [
                        const Text(
                          'Get your API key from ',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => launchUrl(
                                Uri.parse('https://openweathermap.org')),
                            child: const Text(
                              'openweathermap.org',
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _fetchWeather,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2980B9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Get Weather',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
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
    super.key,
    required this.currentWeather,
    required this.forecast,
    required this.cityName,
  });

  Color _getTimeBasedColor(String condition, DateTime time) {
    condition = condition.toLowerCase();
    final hour = time.hour;

    // Night time (7 PM - 5 AM)
    if (hour >= 19 || hour < 5) {
      if (condition.contains('rain') || condition.contains('drizzle')) {
        return const Color(0xFF1A1F25); // Dark navy for rain at night
      } else if (condition.contains('cloud')) {
        return const Color(0xFF232B38); // Dark slate for clouds at night
      } else if (condition.contains('clear')) {
        return const Color(0xFF1A237E); // Deep blue for clear night
      } else if (condition.contains('snow')) {
        return const Color(0xFF263238); // Dark blue-grey for snow at night
      } else if (condition.contains('thunder')) {
        return const Color(0xFF1A1A2E); // Very dark blue for storms at night
      }
      return const Color(0xFF121212); // Default night color
    }

    // Morning (5 AM - 11 AM)
    else if (hour >= 5 && hour < 11) {
      if (condition.contains('rain') || condition.contains('drizzle')) {
        return const Color(0xFF6D8A96); // Soft blue-grey for morning rain
      } else if (condition.contains('cloud')) {
        return const Color(0xFF90A4AE); // Light grey-blue for morning clouds
      } else if (condition.contains('clear')) {
        return const Color(0xFF64B5F6); // Bright blue for clear morning
      } else if (condition.contains('snow')) {
        return const Color(0xFF90CAF9); // Light blue for morning snow
      } else if (condition.contains('thunder')) {
        return const Color(0xFF546E7A); // Dark grey-blue for morning storms
      }
      return const Color(0xFF42A5F5); // Default morning color
    }

    // Evening (4 PM - 7 PM)
    else if (hour >= 16 && hour < 19) {
      if (condition.contains('rain') || condition.contains('drizzle')) {
        return const Color(0xFFE65100); // Dark orange for evening rain
      } else if (condition.contains('cloud')) {
        return const Color(0xFFFB8C00); // Orange for evening clouds
      } else if (condition.contains('clear')) {
        return const Color(0xFFFF9800); // Bright orange for clear evening
      } else if (condition.contains('snow')) {
        return const Color(0xFFFFB74D); // Light orange for evening snow
      } else if (condition.contains('thunder')) {
        return const Color(0xFFE64A19); // Deep orange for evening storms
      }
      return const Color(0xFFFF9800); // Default evening color
    }

    // Daytime (11 AM - 4 PM)
    else {
      if (condition.contains('rain') || condition.contains('drizzle')) {
        return const Color(0xFF2C3E50); // Original rain color
      } else if (condition.contains('cloud')) {
        return const Color(0xFF34495E); // Original cloud color
      } else if (condition.contains('clear')) {
        return const Color(0xFF2980B9); // Original clear color
      } else if (condition.contains('snow')) {
        return const Color(0xFF516A78); // Original snow color
      } else if (condition.contains('thunder')) {
        return const Color(0xFF2C3A47); // Original thunder color
      }
      return const Color(0xFF1A5CAD); // Original default color
    }
  }

  @override
  Widget build(BuildContext context) {
    final weatherCondition = currentWeather['weather'][0]['main'];
    final now = DateTime.now();
    final backgroundColor = _getTimeBasedColor(weatherCondition, now);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Custom App Bar
          SliverAppBar(
            expandedHeight: 320,
            floating: false,
            pinned: true,
            backgroundColor: backgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildMainWeatherCard(backgroundColor),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(cityName, style: const TextStyle(color: Colors.white)),
          ),

          // Main Content
          SliverPadding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildTodayDetails(),
                const SizedBox(height: 24),
                _buildWeatherSummary(),
                const SizedBox(height: 24),
                _buildHourlyForecast(),
                const SizedBox(height: 24),
                _buildWeeklyForecast(),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainWeatherCard(Color backgroundColor) {
    final now = DateTime.now();
    final timeStr = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    final dateStr =
        '${_getDayName(now.weekday)}, ${now.day} ${_getMonthName(now.month)}';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            backgroundColor,
            backgroundColor.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                timeStr,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                ),
              ),
              Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _getWeatherIcon(
                      currentWeather['weather'][0]['icon'],
                      60,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${currentWeather['main']['temp'].round()}°',
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  currentWeather['weather'][0]['description']
                      .toString()
                      .toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 12),
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
    final now = DateTime.now();
    final weatherCondition = currentWeather['weather'][0]['main'];
    final backgroundColor =
        _getTimeBasedColor(weatherCondition, now).withOpacity(0.15);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hourly Forecast',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: hourlyList.length,
            itemBuilder: (context, index) {
              final hourData = hourlyList[index];
              final time =
                  DateTime.fromMillisecondsSinceEpoch(hourData['dt'] * 1000);
              final hour = time.hour == 0
                  ? '12 AM'
                  : time.hour > 12
                      ? '${time.hour - 12} PM'
                      : '${time.hour} AM';

              return Container(
                width: 85,
                margin: EdgeInsets.only(
                  left: index == 0 ? 16 : 8,
                  right: index == hourlyList.length - 1 ? 16 : 8,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      hour,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _getWeatherIcon(
                        hourData['weather'][0]['icon'],
                        35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${hourData['main']['temp'].round()}°',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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
    final now = DateTime.now();
    final weatherCondition = currentWeather['weather'][0]['main'];
    final backgroundColor =
        _getTimeBasedColor(weatherCondition, now).withOpacity(0.15);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '5-Day Forecast',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
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
    final Set<String> seenDates = {};

    // Get tomorrow's date
    final DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
    final String tomorrowKey =
        '${tomorrow.year}-${tomorrow.month}-${tomorrow.day}';

    for (var item in items) {
      final DateTime date =
          DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
      final String dateKey = '${date.year}-${date.month}-${date.day}';

      // Skip dates before tomorrow
      if (dateKey.compareTo(tomorrowKey) < 0) continue;

      if (!seenDates.contains(dateKey)) {
        seenDates.add(dateKey);
        dailyForecasts.add(item);

        // Break if we have 7 days
        if (dailyForecasts.length >= 7) break;
      }
    }

    return dailyForecasts;
  }

  Widget _buildDailyForecastItem(Map<String, dynamic> day) {
    final date = DateTime.fromMillisecondsSinceEpoch(day['dt'] * 1000);
    final avgTemp =
        ((day['main']['temp_max'] + day['main']['temp_min']) / 2).round();
    final weatherDescription =
        _getShortWeatherDescription(day['weather'][0]['main']);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              _getDayName(date.weekday),
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            children: [
              _getWeatherIcon(
                day['weather'][0]['icon'],
                35,
              ),
              Text(
                '$avgTemp°',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(
              weatherDescription,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getShortWeatherDescription(String mainWeather) {
    switch (mainWeather.toLowerCase()) {
      case 'thunderstorm':
        return 'Stormy';
      case 'drizzle':
        return 'Light Rain';
      case 'rain':
        return 'Rainy';
      case 'snow':
        return 'Snowy';
      case 'clear':
        return 'Clear Sky';
      case 'clouds':
        return 'Cloudy';
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'Poor Visibility';
      default:
        return mainWeather;
    }
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

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  Widget _buildWeatherSummary() {
    final weatherCondition = currentWeather['weather'][0]['main'];
    final now = DateTime.now();
    final backgroundColor =
        _getTimeBasedColor(weatherCondition, now).withOpacity(0.15);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: _getTimeBasedColor(weatherCondition, now),
              ),
              const SizedBox(width: 8),
              const Text(
                'Weather Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
    );
  }

  Widget _getWeatherIcon(String iconCode, double size) {
    // Map weather codes to custom icons
    switch (iconCode) {
      // Clear sky
      case '01d':
        return Icon(
          Icons.wb_sunny_rounded,
          size: size,
          color: Colors.deepOrangeAccent,
        );
      case '01n':
        return Icon(
          Icons.nightlight_round,
          size: size,
          color: Colors.yellowAccent,
        );

      // Few clouds
      case '02d':
        return Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.wb_sunny_rounded,
              size: size,
              color: Colors.deepOrangeAccent,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Icon(
                Icons.cloud,
                size: size * 0.7,
                color: Colors.grey[300],
              ),
            ),
          ],
        );
      case '02n':
        return Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.nightlight_round,
              size: size,
              color: Colors.yellowAccent,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Icon(
                Icons.cloud,
                size: size * 0.7,
                color: Colors.grey[400],
              ),
            ),
          ],
        );

      // Scattered clouds
      case '03d':
      case '03n':
        return Icon(
          Icons.cloud,
          size: size,
          color: Colors.grey[400],
        );

      // Broken clouds
      case '04d':
      case '04n':
        return Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.cloud,
              size: size,
              color: Colors.grey[400],
            ),
            Positioned(
              right: size * 0.2,
              bottom: 0,
              child: Icon(
                Icons.cloud,
                size: size * 0.7,
                color: Colors.grey[500],
              ),
            ),
          ],
        );

      // Shower rain
      case '09d':
      case '09n':
        return Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.cloud,
              size: size,
              color: Colors.grey[600],
            ),
            Positioned(
              bottom: 0,
              child: Icon(
                Icons.water_drop,
                size: size * 0.4,
                color: Colors.blue[300],
              ),
            ),
          ],
        );

      // Rain
      case '10d':
      case '10n':
        return Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.cloud,
              size: size,
              color: Colors.grey[600],
            ),
            Positioned(
              bottom: 0,
              left: size * 0.2,
              child: Icon(
                Icons.water_drop,
                size: size * 0.4,
                color: Colors.blue[300],
              ),
            ),
            Positioned(
              bottom: 0,
              right: size * 0.2,
              child: Icon(
                Icons.water_drop,
                size: size * 0.4,
                color: Colors.blue[300],
              ),
            ),
          ],
        );

      // Thunderstorm
      case '11d':
      case '11n':
        return Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.cloud,
              size: size,
              color: Colors.grey[700],
            ),
            Positioned(
              bottom: 0,
              child: Icon(
                Icons.flash_on,
                size: size * 0.5,
                color: Colors.yellowAccent,
              ),
            ),
          ],
        );

      // Snow
      case '13d':
      case '13n':
        return Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.cloud,
              size: size,
              color: Colors.grey[300],
            ),
            Positioned(
              bottom: 0,
              child: Icon(
                Icons.ac_unit,
                size: size * 0.5,
                color: Colors.white,
              ),
            ),
          ],
        );

      // Mist, smoke, haze, etc.
      case '50d':
      case '50n':
        return Icon(
          Icons.cloud,
          size: size,
          color: Colors.grey[400],
        );

      // Default case
      default:
        return Image.network(
          'https://openweathermap.org/img/wn/$iconCode@2x.png',
          width: size,
          height: size,
        );
    }
  }
}
