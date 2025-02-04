import 'dart:convert';
import 'dart:ffi';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:weatherapplicationz/hourly_forecast_item.dart';
import 'package:weatherapplicationz/secrets.dart';
import 'additionalinfoitems.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = 'Coimbatore';
      final res = await http.get(Uri.parse(
          'http://api.openweathermap.org/data/2.5/forecast?q=$cityName&appid=$OpenWeatherAPIKey'));
      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw 'An unexpected error occured';
      }
      return data;
      //temp = (data['list'][0]['main']['temp']);
    } catch (e) {
      throw e.toString();
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                weather = getCurrentWeather();
              });
            },
            icon: const Icon(Icons.refresh_outlined),
          )
        ],
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: const CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          final data = snapshot.data!;
          final CurrentTemp = (data['list'][0]['main']['temp']);
          final CurrentSky = (data['list'][0]['weather'][0]['main']);
          final CurrentHumidity = (data['list'][0]['main']['humidity']);
          final CurrentPressure = (data['list'][0]['main']['pressure']);
          final CurrentWindSpeed = (data['list'][0]['wind']['speed']);
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 10,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              Text(
                                'Coimbatore',
                                style: TextStyle(
                                    fontSize: 24, fontStyle: FontStyle.italic),
                              ),
                              Text(
                                '${(CurrentTemp - 273.15).toStringAsFixed(2)} °C',
                                style: TextStyle(
                                  fontSize: 32,
                                ),
                              ),
                              Icon(
                                CurrentSky == 'Clouds' || CurrentSky == 'Rain'
                                    ? Icons.cloud
                                    : Icons.sunny,
                                size: 64,
                              ),
                              Text(
                                CurrentSky,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Hourly Forecast',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 16),
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: [
                //       for (int i = 0; i < 5; i++)
                //         HourlyForecast(
                //           hour: (data['list'][i + 1]['dt'].toString()),
                //           icon: (data['list'][i + 1]['weather'][0]['main'] ==
                //                       'Clouds' ||
                //                   data['list'][i + 1]['weather'][0]['main'] ==
                //                       'Rainy'
                //               ? Icons.cloud
                //               : Icons.sunny),
                //           temperature:
                //               (data['list'][i + 1]['main']['temp'].toString()),
                //         )
                //     ],
                //   ),
                // ),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        final hourlyForecast = data['list'][index + 1];
                        final hourlySky =
                            data['list'][index + 1]['weather'][0]['main'];
                        final hour = DateTime.parse(hourlyForecast['dt_txt']);
                        return HourlyForecastItem(
                            hour: DateFormat.j().format(hour),
                            temperature:
                                (hourlyForecast['main']['temp'] - 273.15)
                                        .toStringAsFixed(2) +
                                    ' °C',
                            icon: hourlySky == 'Clouds' || hourlySky == 'Rainy'
                                ? Icons.cloud
                                : Icons.sunny);
                      }),
                ),
                const SizedBox(height: 12),
                Text(
                  'Additional Information',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(children: [
                      AdditionalInfoItem(
                        icon: Icons.water_drop,
                        label: 'Humidity',
                        value: '$CurrentHumidity',
                      ),
                      AdditionalInfoItem(
                        icon: Icons.air,
                        label: 'Wind Speed',
                        value: '$CurrentWindSpeed',
                      ),
                      AdditionalInfoItem(
                        icon: Icons.beach_access,
                        label: 'Pressure',
                        value: '$CurrentPressure',
                      ),
                    ])),
                const SizedBox(height: 2),
              ],
            ),
          );
        },
      ),
    );
  }
}
