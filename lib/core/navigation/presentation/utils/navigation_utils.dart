import '../../data/constants/bottom_navigation_constants.dart';

class NavigationUtils {
  NavigationUtils._();

  static int getCurrentIndex(String currentLocation) {
    for (int i = 0; i < BottomNavigationConstants.navigationItems.length; i++) {
      if (BottomNavigationConstants.navigationItems[i].route == currentLocation) {
        return i;
      }
    }
    return 0;
  }
}

