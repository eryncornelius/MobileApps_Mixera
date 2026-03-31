import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/app.dart';
import 'di/injection.dart';

// IMPOPET FOR DEBIUGGING 
// import '../features/home/presentation/pages/home_page.dart';
// import  'features/home/presentation/pages/wardrobe_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await initDependencies();
  runApp(const MixeraApp());
}

// ------------------------------------------------------------------------------------------------
// DEBUGGING PAGE (WITHOUT AUTHORIZATION)


// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await dotenv.load(fileName: ".env");
//   await initDependencies();
//   runApp(const MaterialApp(
//     debugShowCheckedModeBanner: false,
//     home: HomePage(),
//   ));
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await dotenv.load(fileName: ".env");
//   await initDependencies();
//   runApp(const MaterialApp(
//     debugShowCheckedModeBanner: false,
//     home: WardrobePage(),
//   ));
// }
