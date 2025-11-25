import 'package:equatable/equatable.dart';

class NavigationItem extends Equatable {
  final String iconPath;
  final String label;
  final String route;

  const NavigationItem({
    required this.iconPath,
    required this.label,
    required this.route,
  });

  @override
  List<Object> get props => [iconPath, label, route];
}
