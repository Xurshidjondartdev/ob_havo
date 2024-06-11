// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:geocode/geocode.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:ob_havo/models/weather_models.dart';
import 'package:ob_havo/service/client_service.dart';
import 'package:ob_havo/widgets/blur.dart';

class ObHavoPage extends StatefulWidget {
  const ObHavoPage({super.key});

  @override
  State<ObHavoPage> createState() => _ObHavoPageState();
}

class _ObHavoPageState extends State<ObHavoPage> {
  ///properties
  bool isLoading = false;
  late WeatherModel weather;
  late double lat;
  late double lon;
  int fon = 0;
  Address address = Address();
  TextEditingController controller = TextEditingController();

  ///methods
  @override
  void initState() {
    super.initState();
    checkPermission().then((value) async {
      await fetchWeather();
    });
  }

  Future<void> checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    Position userPosition = await Geolocator.getCurrentPosition();
    lat = userPosition.latitude;
    lon = userPosition.longitude;
  }

  Future<void> fetchWeather() async {
    isLoading = false;
    setState(() {});
    String? str =
        await ClientService.get(api: ClientService.apiGetWeather, param: {
      "lat": lat.toString(),
      "lon": lon.toString(),
    });
    if (str != null) {
      weather = weatherModelFromJson(str);
      await reverse();
      if (weather.cloudPct! >= 75) {
        fon = 1;
      } else if (weather.cloudPct! >= 50 && weather.cloudPct! <= 74) {
        fon = 2;
      } else if (weather.cloudPct! <= 50) {
        fon = 3;
      }
      setState(() {
        isLoading = true;
      });
    }
  }

  // Vaqtni formatlash funksiyasi
  String formatTime(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('HH:mm').format(dateTime);
  }

  // Manzilni qidirish funksiyasi
  Future<void> search() async {
    String? str = await ClientService.get(
        api: ClientService.apiGetWeather,
        param: {'city': controller.text.toString()});
    if (str != null) {
      weather = weatherModelFromJson(str);
      await reverse();
      if (weather.cloudPct! >= 75) {
        fon = 1;
      } else if (weather.cloudPct! >= 50 && weather.cloudPct! <= 74) {
        fon = 2;
      } else if (weather.cloudPct! <= 50) {
        fon = 3;
      }
      setState(() {
        isLoading = true;
      });
    }
  }

  TextStyle textStyle = const TextStyle(
    fontSize: 20,
    color: Colors.white,
    fontWeight: FontWeight.w300,
  );

  // Reverse geocoding funksiyasi
  Future<void> reverse() async {
    try {
      address = await GeoCode().reverseGeocoding(latitude: lat, longitude: lon);
    } catch (e) {
      address = Address();
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            body: Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    fon == 0
                        ? "assets/images/raing.png"
                        : fon == 1
                            ? "assets/images/cloud.png"
                            : "assets/images/sun.png",
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Manzilni Kiriting'),
                                  content: TextFormField(
                                    controller: controller,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: 'Joylashuvni kiriting',
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Bekor qilish'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        await search();
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Qidirish'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        address.city != null
                            ? Text(
                                '${address.city}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'unknown city',
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.white,
                                ),
                              ),
                        IconButton(
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            fetchWeather();
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.more_vert_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        address.countryName != null
                            ? Text(
                                '${address.countryName}',
                                style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal),
                              )
                            : const Text('unknown'),
                        address.streetAddress != null
                            ? Text(
                                '${address.streetAddress}',
                                style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 25,
                                    fontWeight: FontWeight.normal),
                              )
                            : const Text('unknown address'),
                        const SizedBox(height: 30),
                        Text(
                          '${weather.temp}°C',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 75,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Shamol tezligi ${weather.windSpeed} m/s',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          'Namlik ko`rsatgichi ${weather.humidity} %',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        address.timezone != null
                            ? Text(
                                'Time zone ${address.timezone}',
                                style: const TextStyle(color: Colors.white),
                              )
                            : const Text(
                                'unknown',
                                style: TextStyle(color: Colors.white),
                              ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: BlurContainer(
                      child: SizedBox(
                        height: 300,
                        width: 300,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'Haroratning sezilishi ${weather.feelsLike}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal),
                            ),
                            Text(
                              'Maximal Harorat ${weather.maxTemp}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal),
                            ),
                            Text(
                              'Minimal Harorat ${weather.minTemp}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal),
                            ),
                            Text(
                              'Quyosh chiqishi ${formatTime(weather.sunrise!)}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal),
                            ),
                            Text(
                              'Quyosh botishi ${formatTime(weather.sunset!)}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50)
                ],
              ),
            ),
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}
