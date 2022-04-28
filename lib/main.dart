
import 'package:face_detection/facePage.dart';

import 'package:flutter/material.dart';

// import 'detector.dart';

void main(){
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      theme: ThemeData(primaryColor: Colors.teal[800],accentColor: Colors.teal),
      home: PersonMood(),
      debugShowCheckedModeBanner: false,
    );
  }
}