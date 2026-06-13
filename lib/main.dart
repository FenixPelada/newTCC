import 'package:flutter/material.dart';
import 'package:flutter_test_project/pages/page1/page1.dart';
import 'package:flutter_test_project/pages/page2/page2.dart';
import 'package:flutter_test_project/pages/page3/page3.dart';

//supabase
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ecofbovidfhsetaxjpaa.supabase.co',
    publishableKey: 'sb_publishable_Fiv_B8zEEzkSyfBj21PKsw_4cUZtgG2',
  );

  runApp(
    MaterialApp(
      title: "Timetable project",
      initialRoute: "/",
      routes: {
        "/": (context) => const Page1(),
        "/page2": (context) => const Page2(),
        "/page3": (context) => const Page3(),
      },
    )
  );
}