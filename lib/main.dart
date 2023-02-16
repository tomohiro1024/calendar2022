import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:calendar202211/pages/calender.dart';
import 'package:flutter/material.dart';

import 'amplifyconfiguration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Amplify.configure(amplifyconfig);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CalenderView(),
    );
  }
}
