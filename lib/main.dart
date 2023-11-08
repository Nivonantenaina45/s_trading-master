import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'pages/splash.dart';

void main() {
  /* WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();*/
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // MyApp({super.key});
  /*final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

   MyApp() {
    _initializeNotifications();
    _setupRealTimeUpdates();
  }
  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/s_trade');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }
  Future<void> selectNotification(String payload) async {
    print('Notification sélectionnée: $payload');
  }
   void _showNotification(Map<String, dynamic> data) async {
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
       0, // Notification ID
       'Colis modifié',
       'Tracking: $tracking - codeClient: $codeClient -ModeEnvoie: $modeEnvoie',
       platformChannelSpecifics,
     );
   }
  void _setupRealTimeUpdates() {
    FirebaseFirestore.instance
        .collection('colisDetails')
        .snapshots()
        .listen((querySnapshot) {
      querySnapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.modified) {
          final data = change.doc.data() as Map<String, dynamic>;

          // Vérifiez si le codeClient a changé et que le modeEnvoie est null
          if (data['codeClient'] != '?'|| data['codeClient'] != null && data['modeEnvoie'] == null) {
            _showNotification(data);
          }

          // Ou, vérifiez si le modeEnvoie a changé et que le codeClient est '?'
          if (data['modeEnvoie'] != null && data['codeClient'] == '?') {
            _showNotification(data);
          }
        }
      });
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Splash(),
    );
  }
}
