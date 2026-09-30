import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/error_handling_screen/error_screen/error_screen.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/utils/app_size.dart';
import 'package:belwork/utils/app_theme.dart';
import 'package:belwork/utils/app_theme_configuration.dart';
import 'package:belwork/utils/languages/language_provider.dart';
import 'package:belwork/utils/observer/logger_ob_server.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
final AppRoutes appRoutes = AppRoutes.instance;
final GlobalKey<OverlayState> appOverlayKey = GlobalKey<OverlayState>();

class MainAppEntry extends StatefulWidget {
  const MainAppEntry({super.key});

  @override
  State<MainAppEntry> createState() => _MainAppEntryState();
}

class _MainAppEntryState extends State<MainAppEntry> {
  Key providerKey = UniqueKey();
  void resetRiverpod() {
    setState(() {
      providerKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    /////////////////
    AppSize.size = MediaQuery.of(context).size;

    //////////////// main services
    return ProviderScope(key: providerKey, observers: [LoggerObServer()], child: MainApp());
  }
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  @override
  Widget build(BuildContext context) {
    final ThemeMode themeMode = ref.watch(themeProvider);
    final selectedLanguage = ref.watch(languageProvider);
    final langParts = selectedLanguage.split('_');
    final langCode = langParts[0].toLowerCase();
    final countryCode = langParts.length > 1 ? langParts[1] : null;

    return MaterialApp.router(
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      routerConfig: appRoutes.router,
      title: "Flutter",
      color: Colors.white,
      themeAnimationCurve: Curves.easeInOut,
      themeAnimationDuration: Duration.zero,
      theme: AppThemeConfiguration.instance.lightThemeData,
      darkTheme: AppThemeConfiguration.instance.darkThemeData,
      themeMode: themeMode,
      locale: Locale(langCode, countryCode),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('en', 'GB'),
        Locale('en'),
        Locale('fr', 'FR'),
        Locale('fr'),
        Locale('nl', 'NL'),
        Locale('nl'),
        Locale('de', 'DE'),
        Locale('de'),
        Locale('pl', 'PL'),
        Locale('pl'),
        Locale('uk', 'UA'),
        Locale('uk'),
        Locale('bg', 'BG'),
        Locale('bg'),
        Locale('ar', 'SA'),
        Locale('ar'),
        Locale('tr', 'TR'),
        Locale('tr'),
        Locale('ro', 'RO'),
        Locale('ro'),
        Locale('es', 'ES'),
        Locale('es'),
        Locale('it', 'IT'),
        Locale('it'),
        Locale('pt', 'PT'),
        Locale('pt'),
      ],

      builder: (context, child) {
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return Overlay(
            key: appOverlayKey,
            initialEntries: [OverlayEntry(builder: (context) => ErrorScreen())],
          );
        };

        return Overlay(
          key: appOverlayKey,
          initialEntries: [OverlayEntry(builder: (context) => child ?? SizedBox())],
        );
      },
    );
  }
}
