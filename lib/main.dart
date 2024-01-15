import 'package:flutter/material.dart';
import 'pages/splash.dart';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationManager.initializeNotifications();
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Splash(),
    );
  }
}
class NotificationManager with WidgetsBindingObserver {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/s_trade');

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,

    );

    _setupRealTimeUpdates();

    WidgetsBinding.instance!.addObserver(NotificationManager());
  }

  @override
  Future<void> didReceiveLocalNotification(
      int? id, String? title, String? body, String? payload) async {
    // Called when the app receives a notification while in the foreground
    print('Received notification in foreground: $payload');
  }
  static Future<void> _showNotification(Map<String, dynamic> data) async {
    final tracking = data['tracking'];
    final codeClient = data['codeClient'];
    final modeEnvoie = data['modeEnvoie'];

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your_channel_id',
      'Your Channel Name',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Colis modifié',
      'Tracking: $tracking - codeClient: $codeClient - ModeEnvoie: $modeEnvoie',
      platformChannelSpecifics,
      payload: json.encode(data),
    );
  }

  static Future<void> _setupRealTimeUpdates() async{
    const apiUrl = 'https://s-tradingmadagasikara.com/getColis.php';

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        _fetchDataAndShowNotifications(apiUrl);
      }
    });
  }

  static Future<void> _fetchDataAndShowNotifications(String apiUrl) async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> colisData = json.decode(response.body);

        colisData.forEach((data) {
          if ((data['modeEnvoie'] != 'Aucun' && data['modeEnvoie'] != null) ||
              (data['codeClient'] != 'Aucun' && data['codeClient'] != null)) {
            _showNotification(data);
          }
        });
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }
}
