import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gitnar/src/context/app_context.dart';
import 'package:window_size/window_size.dart';
import 'package:gitnar/src/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setWindowMinSize(const Size(1280, 720));
  setWindowMaxSize(Size.infinite);
  await dotenv.load();
  await AppContext.instance.load();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final bool connected = AppContext.instance.isFullyConnected;

    return MaterialApp(
      title: "GitNar",
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: connected ? Routes.home : Routes.auth,
      routes: appRoutes,
      debugShowCheckedModeBanner: false,
    );
  }
}
