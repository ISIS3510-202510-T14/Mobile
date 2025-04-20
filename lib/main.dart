import 'package:campus_picks/data/services/isolate_manager.dart';
import 'package:campus_picks/presentation/widgets/sync_status_listener.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'presentation/screens/place_bet_view.dart'; // or your chosen screen
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'presentation/viewmodels/user_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import "data/models/match_model.dart";
import 'dart:convert';
import 'presentation/viewmodels/bet_viewmodel.dart';
import 'data/services/connectivity_service.dart';
import 'presentation/viewmodels/auth_wrapper_viewmodel.dart';
import 'data/services/draft_sync_service.dart';  
import 'presentation/viewmodels/user_bets_view_model.dart';


// Global instance for local notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
/// Root messenger – lets us show SnackBars from anywhere
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable Firestore network (disable/enable as needed)
  await FirebaseFirestore.instance.disableNetwork();
  await FirebaseFirestore.instance.enableNetwork();

  // Initialize local notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();
  const InitializationSettings initializationSettings =
      InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  


  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      print('Notification clicked: ${response.payload}');
      if (response.actionId == "bet_now_action" && response.payload != null) {
         final data = jsonDecode(response.payload!);
          final matchData = data['match'] as Map<String, dynamic>;
          final match = MatchModel.fromJson(matchData);
          final userUID = data['userUID'] as String;
          // get the ConnectivityNotifier from our Provider tree
          final connectivity = Provider.of<ConnectivityNotifier>(
            navigatorKey.currentContext!,
            listen: false,
          );
          final betViewModel = BetViewModel(
            match: match,
            userId: userUID,
            connectivity: connectivity,
          );
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => BetScreen(viewModel: betViewModel),
            ),
          );

        print('User pressed bet now"');
      }
    },
  );

  // Spawn the background isolate for draft sync and other tasks
  await IsolateManager().initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserViewModel(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) => ConnectivityNotifier(),
         
        ),
        // Global service that auto‑syncs offline draft bets when connectivity returns
        ChangeNotifierProvider(
          lazy: false,
          create: (ctx) {
            final conn = ctx.read<ConnectivityNotifier>();
            return DraftSyncService(connectivity: conn);
          },
        ),
        // ────────────────────────────────────────────────────────────
        // make UserBetsViewModel global so any screen (including PlaceBetView)
        // can call context.read<UserBetsViewModel>()
        ChangeNotifierProvider(
          create: (ctx) => UserBetsViewModel(
            connectivityNotifier: ctx.read<ConnectivityNotifier>(),
          ),
        ),
        // ────────────────────────────────────────────────────────────
      ],
      child: SyncStatusListener(child: const MyApp()),
    ),
  );
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
    );
  }
}
