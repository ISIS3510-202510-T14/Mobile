// lib/presentation/screens/user_bets_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../data/models/bet_with_match.dart';
import '../viewmodels/user_bets_view_model.dart';
import '../../data/services/connectivity_service.dart';

/// Shows the authenticated user’s betting history in a scrollable list.
/// Offline‑first: falls back to the SQLite cache when the device is offline.
class UserBetsScreen extends StatelessWidget {
  const UserBetsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final connectivityNotifier = context.watch<ConnectivityNotifier>();

    return ChangeNotifierProvider<UserBetsViewModel>(
      create: (_) {
        final vm = UserBetsViewModel(connectivityNotifier: connectivityNotifier);
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) vm.loadBets(uid);
        return vm;
      },
      child: const _UserBetsBody(),
    );
  }
}

class _UserBetsBody extends StatelessWidget {
  const _UserBetsBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UserBetsViewModel>();
    final offline = !context.watch<ConnectivityNotifier>().isOnline;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('My Bets')),
      body: Column(
        children: [
          if (offline)
            Container(
              width: double.infinity,
              color: primary,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: const Center(
                child: Text(
                  'OFF‑LINE  •  using cached bets',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          Expanded(
            child: vm.loading
                ? const Center(child: CircularProgressIndicator())
                : vm.error != null
                    ? Center(child: Text(vm.error!))
                    : vm.bets.isEmpty
                        ? const _EmptyState()
                        : ListView.separated(
                            padding: const EdgeInsets.only(top: 8, bottom: 24),
                            itemCount: vm.bets.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (_, i) => _BetCard(bet: vm.bets[i]),
                          ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long,
              size: 80, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          const Text('No bets yet', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class _BetCard extends StatelessWidget {
  const _BetCard({required this.bet});

  final BetWithMatch bet;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t  = Theme.of(context).textTheme;

    final m = bet.match; // could be null if the match was purged from cache
    final b = bet.bet;

    //------------------------------------------------------------------
    // DATA PREP
    //------------------------------------------------------------------
    final matchUp    = (m != null ? m.name : b.matchName) ?? 'Unknown match';
    final chosenTeam = b.team;
    final placedAt   = b.createdAt;
    final dateFmt    = DateFormat('d MMM yyyy · HH:mm');

    // status → colour/icon
    late final Color    statusColor;
    late final IconData statusIcon;
    switch (b.status) {
      case 'won':  statusColor = cs.secondary; statusIcon = Icons.trending_up;   break;
      case 'lost': statusColor = cs.error;     statusIcon = Icons.trending_down; break;
      default:     statusColor = cs.tertiary;  statusIcon = Icons.hourglass_bottom;
    }

    //------------------------------------------------------------------
    // UI
    //------------------------------------------------------------------
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: cs.primary, width: 2), // same outline as match cards
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //----------------------------------------------------------------
            // Top row  ·  matchup title + coloured status chip
            //----------------------------------------------------------------
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    matchUp,
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                _StatusChip(label: b.status, color: statusColor),
              ],
            ),

            const SizedBox(height: 12),

            //----------------------------------------------------------------
            // Chosen team & odds – with subtle labels
            //----------------------------------------------------------------
            Row(
              children: [
                //----------------------------------------------------------------
                // team
                //----------------------------------------------------------------
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TEAM',
                          style: t.bodySmall?.copyWith(
                            color: cs.onSurface.withOpacity(0.6),
                          )),
                      const SizedBox(height: 2),
                      Text(chosenTeam,
                          style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                //----------------------------------------------------------------
                // odds (if any)
                //----------------------------------------------------------------
                if (b.odds != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('ODDS',
                          style: t.bodySmall?.copyWith(
                            color: cs.onSurface.withOpacity(0.6),
                          )),
                      const SizedBox(height: 2),
                      Text(b.odds!.toStringAsFixed(2),
                          style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 12),

            //----------------------------------------------------------------
            // Stake & placed date
            //----------------------------------------------------------------
            Row(
              children: [
                Expanded(
                  child: Text('¢${b.stake.toStringAsFixed(0)}',
                      style: t.bodyMedium),
                ),
                if (placedAt != null)
                  Text(dateFmt.format(placedAt.toLocal()),
                      style: t.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.7))),
              ],
            ),

            //----------------------------------------------------------------
            // Optional: match status + date (if we still have the MatchModel)
            //----------------------------------------------------------------
            if (m != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(m.status,
                        style: t.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.7))),
                  ),
                  Text(dateFmt.format(m.startTime.toLocal()),
                      style: t.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.7))),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}


class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 4),
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}
