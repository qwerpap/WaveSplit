import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Сервис для централизованной навигации с анимациями
/// context.go = fade transition (замена текущего экрана)
/// context.push = slide transition (добавление нового экрана в стек)
class NavigationService {
  NavigationService._();

  /// Навигация с fade анимацией (замена экрана)
  static void navigateReplace(BuildContext context, String route, {Object? extra}) {
    context.go(route, extra: extra);
  }

  /// Навигация с slide анимацией (добавление в стек)
  static Future<T?> navigatePush<T extends Object?>(
    BuildContext context, 
    String route, {
    Object? extra,
  }) {
    return context.push<T>(route, extra: extra);
  }

  /// Возврат назад
  static void navigateBack<T extends Object?>(BuildContext context, [T? result]) {
    if (context.canPop()) {
      context.pop(result);
    }
  }

  /// Проверка возможности возврата
  static bool canGoBack(BuildContext context) {
    return context.canPop();
  }

  /// Навигация с заменой всего стека
  static void navigateAndClearStack(BuildContext context, String route, {Object? extra}) {
    context.go(route, extra: extra);
  }
}