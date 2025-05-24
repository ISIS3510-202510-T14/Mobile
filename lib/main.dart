// lib/main.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';                   // ← added
import 'package:newrelic_mobile/newrelic_mobile.dart';           // ← added
import 'package:newrelic_mobile/config.dart';                    // ← added
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';             // ← added

import 'package:campus_picks/data/services/isolate_manager.dart';
import 'package:campus_picks/data/services/connectivity_service.dart';
import 'package:campus_picks/data/services/draft_sync_service.dart';
import 'package:campus_picks/data/services/upload_service.dart';  // ← added
import 'package:campus_picks/data/services/user_metrics_service.dart';

import 'package:campus_picks/data/models/match_model.dart';

import 'package:campus_picks/presentation/widgets/sync_status_listener.dart';
import 'package:campus_picks/presentation/screens/place_bet_view.dart';
import 'package:campus_picks/presentation/viewmodels/user_viewmodel.dart';
import 'package:campus_picks/presentation/viewmodels/auth_wrapper_viewmodel.dart';
import 'package:campus_picks/presentation/viewmodels/bet_viewmodel.dart';
import 'package:campus_picks/presentation/viewmodels/user_bets_view_model.dart';
import 'package:campus_picks/presentation/viewmodels/cart_viewmodel.dart';
import 'package:campus_picks/presentation/screens/cart_screen.dart';

import 'theme/app_theme.dart';
import 'firebase_options.dart';

/// Global instance for local notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Allow navigation & snackbars from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  // 0) Load environment variables
  await dotenv.load(fileName: ".env");

  // 1) Ensure Flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  // ─── Firebase setup ──────────────────────────────────────────────────────────
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseFirestore.instance.disableNetwork();
  await FirebaseFirestore.instance.enableNetwork();

  // ─── Local notifications ────────────────────────────────────────────────────
  const androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings();
  const initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      if (response.actionId == 'bet_now_action' && response.payload != null) {
        final data = jsonDecode(response.payload!);
        final matchData = data['match'] as Map<String, dynamic>;
        final match = MatchModel.fromJson(matchData);
        final userUID = data['userUID'] as String;
        final connectivity = Provider.of<ConnectivityNotifier>(
          navigatorKey.currentContext!,
          listen: false,
        );
        final betVM = BetViewModel(
          match: match,
          userId: userUID,
          connectivity: connectivity,
        );
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => BetScreen(viewModel: betVM),
          ),
        );
      }
    },
  );

  // ─── Background isolate (draft sync) ────────────────────────────────────────
  await IsolateManager().initialize();

  // ─── 2) Initialize Workmanager ──────────────────────────────────────────────
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );

  // ─── 3) Schedule periodic upload task ───────────────────────────────────────
  Workmanager().registerPeriodicTask(
    'dailyErrorUpload',      // unique name
    'uploadErrorLogs',       // handled in callbackDispatcher
    frequency: const Duration(days: 1),  // once a day
    constraints: Constraints(networkType: NetworkType.connected),
  );

  // ─── 4) Start New Relic agent via startAgent ────────────────────────────────
  final nrToken = Platform.isAndroid
      ? dotenv.env['NEW_RELIC_ANDROID_APP_TOKEN']!
      : dotenv.env['NEW_RELIC_IOS_APP_TOKEN']!;
  final nrConfig = Config(
    accessToken: nrToken,
    printStatementAsEventsEnabled: true,
  );

  // Use `startAgent` when you only have the Config object:
  await NewrelicMobile.instance.startAgent(nrConfig);

  // ─── 5) Launch the app ──────────────────────────────────────────────────────
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserViewModel(), lazy: false),
        ChangeNotifierProvider(create: (_) => ConnectivityNotifier()),
        ChangeNotifierProvider(create: (ctx) => CartViewModel(
          connectivity: ctx.read<ConnectivityNotifier>(),
        )),
        ChangeNotifierProvider(
          lazy: false,
          create: (ctx) => DraftSyncService(
            connectivity: ctx.read<ConnectivityNotifier>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => UserBetsViewModel(
            connectivityNotifier: ctx.read<ConnectivityNotifier>(),
          ),
        ),
      ],
      child: SyncStatusListener(child: const MyApp()),
    ),
  );

  // Temporary
  await UploadService.uploadErrorLogs();
  await UserMetricsService.sendPendingMetrics();
}

/// Routes background tasks to your upload service
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == 'uploadErrorLogs') {
      await UploadService.uploadErrorLogs();
      await UserMetricsService.sendPendingMetrics();
    }
    return Future.value(true);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'Demo Matches',
      theme: AppTheme.darkTheme,
      home: const AuthWrapper(),
      routes: {
        '/cart': (context) => const CartPage(),
      }
    );
  }
}
