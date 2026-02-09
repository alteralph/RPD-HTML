import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io' show Platform;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'logic.dart';
import 'screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, 
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarContrastEnforced: false, 
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await initializeDateFormatting('pt_BR', null);

  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    try {
      await windowManager.ensureInitialized();
      windowManager.waitUntilReadyToShow().then((_) async {
        await windowManager.setTitle('RPD Sky');
        await windowManager.show();
      });
    } catch (e) {
      print('Window manager initialization failed: $e');
    }
  }

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppData())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, child) {
        return MaterialApp(
          title: 'RPD Sky',
          debugShowCheckedModeBanner: false,
          theme: appData.isDarkMode ? ThemeData.dark() : ThemeData.light(),
          locale: appData.locale,
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('pt', 'BR'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              resizeToAvoidBottomInset: false, 
              body: Theme(
                data: Theme.of(context).copyWith(
                  textSelectionTheme: TextSelectionThemeData(
                    selectionColor: appData.isDarkMode
                        ? Colors.cyanAccent.withValues(alpha: 0.3)
                        : Colors.blue.withValues(alpha: 0.3),
                    cursorColor:
                        appData.isDarkMode ? Colors.cyanAccent : Colors.blue,
                    selectionHandleColor:
                        appData.isDarkMode ? Colors.cyanAccent : Colors.blue,
                  ),
                ),
                child: child!,
              ),
            );
          },
          home: const HomePage(),
        );
      },
    );
  }
}