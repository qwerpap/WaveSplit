import '../../../../constants/image_source.dart';
import '../models/navigation_item.dart';
import 'navigation_constants.dart';
import 'navigation_labels.dart';

class BottomNavigationConstants {
  BottomNavigationConstants._();

  static const List<NavigationItem> navigationItems = [
    NavigationItem(
      iconPath: ImageSource.home,
      label: NavigationLabels.home,
      route: NavigationConstants.home,
    ),
    NavigationItem(
      iconPath: ImageSource.history,
      label: NavigationLabels.history,
      route: NavigationConstants.history,
    ),
    NavigationItem(
      iconPath: ImageSource.settings,
      label: NavigationLabels.settings,
      route: NavigationConstants.settings,
    ),
    NavigationItem(
      iconPath: ImageSource.profile,
      label: NavigationLabels.profile,
      route: NavigationConstants.profile,
    ),
  ];
}
