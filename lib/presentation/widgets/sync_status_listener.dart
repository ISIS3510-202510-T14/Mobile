import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/draft_sync_service.dart';
import '../../main.dart' show scaffoldMessengerKey;

/// Listens to DraftSyncService.syncStatus and shows a SnackBar
class SyncStatusListener extends StatelessWidget {
  const SyncStatusListener({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    //     ⬇ we watch the ChangeNotifier itself once
    final service = context.watch<DraftSyncService>();

    return ValueListenableBuilder<String?>(
      valueListenable: service.syncStatus,
      builder: (_, msg, __) {
        if (msg != null) {
          // defer until after build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // use the global messenger key
            scaffoldMessengerKey.currentState?.showSnackBar(
              SnackBar(content: Text(msg)),
            );
            // clear the notifier so this SnackBar can show again later
            service.syncStatus.value = null;
          });
        }
        return child; // just pass‑through
      },
    );
  }
}
