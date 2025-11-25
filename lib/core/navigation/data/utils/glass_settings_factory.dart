import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../constants/bottom_navigation_ui_constants.dart';
import '../constants/navigation_colors.dart';

class GlassSettingsFactory {
  GlassSettingsFactory._();

  static LiquidGlassSettings createSettings(bool isDark) {
    return LiquidGlassSettings(
      refractiveIndex: BottomNavigationUIConstants.glassRefractiveIndex,
      thickness: BottomNavigationUIConstants.glassThickness,
      blur: BottomNavigationUIConstants.glassBlur,
      saturation: BottomNavigationUIConstants.glassSaturation,
      lightIntensity: isDark
          ? BottomNavigationUIConstants.glassLightIntensityDark
          : BottomNavigationUIConstants.glassLightIntensityLight,
      ambientStrength: isDark
          ? BottomNavigationUIConstants.glassAmbientStrengthDark
          : BottomNavigationUIConstants.glassAmbientStrengthLight,
      lightAngle: BottomNavigationUIConstants.glassLightAngle,
      glassColor: NavigationColors.getGlassColor(isDark),
      chromaticAberration: BottomNavigationUIConstants.glassChromaticAberration,
    );
  }
}

