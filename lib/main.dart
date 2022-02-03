import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../utils/logger.dart';
import 'model/repositories/package_info/package_info_repository.dart';
import 'model/repositories/shared_preferences/shared_preference_repository.dart';
import 'presentation/pages/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  late final PackageInfo packageInfo;
  late final SharedPreferences sharedPreferences;
  Logger.configure();
  await Future.wait([
    Firebase.initializeApp(),
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]),
    Future(() async {
      packageInfo = await PackageInfo.fromPlatform();
    }),
    Future(() async {
      sharedPreferences = await SharedPreferences.getInstance();
    }),
    Future(() async {
      tz.initializeTimeZones();
      final currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
    }),
  ]);

  runApp(ProviderScope(
    overrides: [
      sharedPreferencesRepositoryProvider
          .overrideWithValue(SharedPreferencesRepository(sharedPreferences)),
      packageInfoRepositoryProvider
          .overrideWithValue(PackageInfoRepository(packageInfo)),
    ],
    child: const App(),
  ));
}
