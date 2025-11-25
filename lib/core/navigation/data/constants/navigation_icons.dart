import 'package:flutter/material.dart';

class NavigationIcons {
  NavigationIcons._();

  static const IconData home = Icons.home;
  static const IconData history = Icons.history;
  static const IconData settings = Icons.settings;
  static const IconData profile = Icons.person;
  
  static IconData getIconByRoute(String route) {
    switch (route) {
      case '/home':
        return home;
      case '/history':
        return history;
      case '/settings':
        return settings;
      case '/profile':
        return profile;
      default:
        return home;
    }
  }
}

