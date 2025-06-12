import 'package:flutter/material.dart';
import 'package:gitnar/src/views/auth_view.dart';
import 'package:gitnar/src/views/home_view.dart';

abstract class Routes {
  static const home = '/';
  static const auth = '/auth';
}

final Map<String, WidgetBuilder> appRoutes = {
  Routes.home: (_) => const HomeView(),
  Routes.auth: (_) => const AuthView(),
};
