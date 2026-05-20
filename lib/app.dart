import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/air_quality_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/location_provider.dart';
import 'providers/recommendations_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/soil_provider.dart';
import 'providers/weather_provider.dart';
import 'screens/alerts_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/crop_form_screen.dart';
import 'screens/govt_schemes_screen.dart';
import 'screens/help_support_screen.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/market_prices_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/recommendations_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/guidance_screen.dart';
import 'screens/smart_features_screen.dart';
import 'screens/soil_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/weather_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/calculators_screen.dart';
import 'screens/ui_designer_screen.dart';
import 'theme/dynamic_theme.dart';

class ClimaGrowthApp extends StatelessWidget {
  const ClimaGrowthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => AirQualityProvider()),
        ChangeNotifierProvider(create: (_) => SoilProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => RecommendationsProvider()),
        ChangeNotifierProvider(
            create: (_) => SettingsProvider()..loadFromCache()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => DynamicThemeProvider()),
      ],
      child: Consumer2<SettingsProvider, DynamicThemeProvider>(
        builder: (ctx, settings, dynamicTheme, _) {
          return MaterialApp(
            title: 'ClimaGrowth',
            debugShowCheckedModeBanner: false,
            theme: dynamicTheme.data.toThemeData(Brightness.light),
            darkTheme: dynamicTheme.data.toThemeData(Brightness.dark),
            themeMode: settings.themeMode,
            initialRoute: '/',
            routes: {
              '/': (_) => const SplashScreen(),
              '/login': (_) => const LoginScreen(),
              '/signup': (_) => const SignupScreen(),
              '/forgot-password': (_) => const ForgotPasswordScreen(),
              '/home': (_) => const HomeScreen(),
              '/weather': (_) => const WeatherScreen(),
              '/soil': (_) => const SoilScreen(),
              '/map': (_) => const MapScreen(),
              '/alerts': (_) => const AlertsScreen(),
              '/chat': (_) => const ChatScreen(),
              '/crop-form': (_) => const CropFormScreen(),
              '/recommendations': (_) => const RecommendationsScreen(),
              '/notifications': (_) => const NotificationsScreen(),
              '/profile': (_) => const ProfileScreen(),
              '/settings': (_) => const SettingsScreen(),
              '/help': (_) => const HelpSupportScreen(),
              '/market': (_) => const MarketPricesScreen(),
              '/cart': (_) => const CartScreen(),
              '/schemes': (_) => const GovtSchemesScreen(),
              '/guidance': (_) => const GuidanceScreen(),
              '/smart-features': (_) => const SmartFeaturesScreen(),
              '/admin': (_) => const AdminLoginScreen(),
              '/admin/dashboard': (_) => const AdminDashboardScreen(),
              '/checkout': (_) =>
                  const CheckoutScreen(items: [], totalAmount: 0),
              '/calculators': (_) => const CalculatorsScreen(),
              '/ui-designer': (_) => const UIDesignerScreen(),
            },
          );
        },
      ),
    );
  }
}
