import 'package:flutter/material.dart';

/// A global navigation service to handle routing outside of BuildContext
class NavigationService {
  // Global key for Navigator
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Push a new route
  static Future<dynamic> pushNamed(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(routeName, arguments: arguments);
  }

  /// Replace current route
  static Future<dynamic> pushReplacementNamed(String routeName,
      {Object? arguments}) {
    return navigatorKey.currentState!
        .pushReplacementNamed(routeName, arguments: arguments);
  }

  /// Pop the current route
  static void pop([Object? result]) {
    return navigatorKey.currentState!.pop(result);
  }

  /// Pop all routes and push a new one
  static Future<dynamic> pushNamedAndRemoveUntil(String routeName) {
    return navigatorKey.currentState!
        .pushNamedAndRemoveUntil(routeName, (route) => false);
  }
}
