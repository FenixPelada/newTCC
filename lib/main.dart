import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test_project/theme/app_theme.dart';
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
    ProviderScope(
      child: MaterialApp(
        title: "Timetable project",
        theme: buildIfprTheme(),
        initialRoute: "/",
        routes: {
          "/": _page1,
          "/page2": _page2,
          "/page3": _page3},
      ),
    ),
  );
}

Widget _page1(BuildContext context) => const Page1();
Widget _page2(BuildContext context) => const Page2();
Widget _page3(BuildContext context) => const Page3();
