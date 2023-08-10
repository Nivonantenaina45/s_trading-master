import 'package:flutter/material.dart';
import 'package:s_trading/pages/login.dart';
import 'package:connectivity/connectivity.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _State();
}

class _State extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _navigatetologin();
  }

  _navigatetologin() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
    await Future.delayed(const Duration(milliseconds: 1500), () {});
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) =>const Login()));
    }else
      {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Pas de connection internet'),
            content: Text('Vérifié votre connection internet et ressayé.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
  }


  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image(
          image: AssetImage(
            'assets/logo_strading.jpg',
          ),
          height: 200,
          width: 200,
        ),
      ),
    );
  }
}
