// lib/presentation/screens/recommended_bet_screen.dart
// FINAL tweak: flat purple thumbs‑up icon in modal – no surrounding circle.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/recommended_bet_model.dart';
import '../viewmodels/recommended_bet_viewmodel.dart';

class RecommendedBetsScreen extends StatelessWidget {
  const RecommendedBetsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChangeNotifierProvider(
      create: (_) => RecommendedBetsViewModel()..fetchRecommendedBets(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Recommended Bets')),
        body: Consumer<RecommendedBetsViewModel>(
          builder: (_, vm, __) {
            if (vm.loading) return const Center(child: CircularProgressIndicator());
            if (vm.error != null) {
              return Center(child: Text('Unable to fetch recommendations', style: theme.textTheme.bodyMedium));
            }
            final bets = vm.recommendedBets;
            if (bets.isEmpty) {
              return Center(child: Text('No recommendations', style: theme.textTheme.bodyMedium));
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 6),
              separatorBuilder: (_, __) => const SizedBox(height: 2),
              itemCount: bets.length,
              itemBuilder: (_, i) => _BetCard(bet: bets[i]),
            );
          },
        ),
      ),
    );
  }
}

//──────────────────────────────────────────────────────── card ────
class _BetCard extends StatelessWidget {
  const _BetCard({required this.bet});
  final RecommendedBet bet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    late final IconData iconData;
    late final Color iconColor;
    switch (bet.betType.toLowerCase()) {
      case 'win':
        iconData = Icons.emoji_events;
        iconColor = theme.colorScheme.primary; // flat purple
        break;
      case 'caution':
        iconData = Icons.error_outline;
        iconColor = theme.colorScheme.error;
        break;
      default:
        iconData = Icons.info_outline;
        iconColor = theme.colorScheme.onSurface.withOpacity(.6);
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
      ),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(.12),
          radius: 26,
          child: Icon(iconData, size: 30, color: iconColor),
        ),
        title: Text(bet.description, style: theme.textTheme.bodyLarge, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(children: [
            Icon(Icons.calendar_today, size: 14, color: theme.colorScheme.onSurface.withOpacity(.6)),
            const SizedBox(width: 4),
            Text(dateFormat.format(bet.createdAt), style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(.6))),
          ]),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: iconColor.withOpacity(.15), borderRadius: BorderRadius.circular(8)),
          child: Text(bet.betType.toUpperCase(), style: theme.textTheme.bodySmall?.copyWith(color: iconColor, fontWeight: FontWeight.w600)),
        ),
        onTap: () => _showDetailModal(context),
      ),
    );
  }

  void _showDetailModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _BetDetailSheet(bet: bet),
    );
  }
}

//──────────────────────────────────────────── sheet ────
class _BetDetailSheet extends StatelessWidget {
  const _BetDetailSheet({required this.bet});
  final RecommendedBet bet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFmt = DateFormat('EEEE, d MMM yyyy  •  HH:mm');

    late final IconData icon;
    late final Color color;
    switch (bet.betType.toLowerCase()) {
      case 'win':
        icon  = Icons.thumb_up_alt_rounded;
        color = theme.colorScheme.primary; // flat purple
        break;
      case 'caution':
        icon  = Icons.warning_amber_rounded;
        color = theme.colorScheme.error;
        break;
      default:
        icon  = Icons.info_rounded;
        color = theme.colorScheme.tertiary;
    }

    return DraggableScrollableSheet(
      initialChildSize: .7,
      minChildSize: .4,
      maxChildSize: .9,
      builder: (_, controller) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(.9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SingleChildScrollView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(child: Container(width: 48, height: 4, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: theme.colorScheme.onSurface.withOpacity(.3), borderRadius: BorderRadius.circular(2)))),
                Row(children: [
                  Icon(icon, color: color, size: 48), // flat icon – no circle
                  const SizedBox(width: 16),
                  Expanded(child: Text(bet.betType.toUpperCase(), style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700))),
                ]),
                const SizedBox(height: 24),
                Text(bet.description, style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
                const SizedBox(height: 32),
                Row(children: [
                  Icon(Icons.event, size: 20, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(dateFmt.format(bet.createdAt), style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ]),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Got it', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
