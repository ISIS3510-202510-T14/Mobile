import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../data/models/bet_with_match.dart';
import '../viewmodels/user_bets_view_model.dart';
import '../../data/services/connectivity_service.dart';

class UserBetsScreen extends StatelessWidget {
  const UserBetsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final connectivityNotifier = context.watch<ConnectivityNotifier>();

    return ChangeNotifierProvider<UserBetsViewModel>(
      create: (_) {
        final vm = UserBetsViewModel(connectivityNotifier: connectivityNotifier);
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) vm.loadBets(uid, forceRemote: false);
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
    final vm   = context.watch<UserBetsViewModel>();
    final conn = context.watch<ConnectivityNotifier>();
    final uid  = FirebaseAuth.instance.currentUser?.uid;
    final bool offline = !conn.isOnline;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bets'),
        bottom: offline
            ? const PreferredSize(
                preferredSize: Size.fromHeight(20),
                child: _OfflineBanner(),
              )
            : null,
      ),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : vm.bets.isNotEmpty
              ? RefreshIndicator(
                  onRefresh: () async { if (uid != null) await vm.loadBets(uid, forceRemote: true); },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    itemCount: vm.bets.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _BetCard(bet: vm.bets[i]),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async { if (uid != null) await vm.loadBets(uid, forceRemote: true); },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [SizedBox(height: 200), _EmptyState()],
                  ),
                ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      alignment: Alignment.center,
      color: Theme.of(context).colorScheme.primary,
      child: const Text(
        'OFF‑LINE · showing cached data',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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
          Icon(Icons.receipt_long, size: 80,
              color: Theme.of(context).colorScheme.primary),
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
    final t = Theme.of(context).textTheme;

    // Styles
    final labelStyle = t.bodySmall!
        .copyWith(color: cs.onSurface.withOpacity(0.6), height: 1.2);
    final valueStyle = t.bodyMedium!
        .copyWith(color: cs.onSurface, height: 1.3);
    final matchStyle = t.titleSmall!
        .copyWith(fontWeight: FontWeight.w600, fontSize: t.titleSmall!.fontSize! + 2);

    // Data
    final matchUp = bet.match?.name ?? bet.bet.matchName ?? 'Unknown match';
    final status = bet.bet.status;
    final team = bet.bet.team;
    final odds = bet.bet.odds?.toStringAsFixed(2) ?? '-';
    final placedAt = bet.bet.createdAt;
    final dateFmt = DateFormat('d MMM yyyy · HH:mm');

    // Format money in US style with cents smaller
    final stakeValue = bet.bet.stake;
    final nf = NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2);
    final stakeFmt = nf.format(stakeValue);
    final dotIndex = stakeFmt.lastIndexOf('.');
    final intPart = stakeFmt.substring(0, dotIndex);
    final centPart = stakeFmt.substring(dotIndex);

    // Status color/icon
    late Color statusColor;
    late IconData statusIcon;
    switch (status) {
      case 'won':
        statusColor = cs.secondary;
        statusIcon = Icons.trending_up;
        break;
      case 'lost':
        statusColor = cs.error;
        statusIcon = Icons.trending_down;
        break;
      default:
        statusColor = cs.tertiary;
        statusIcon = Icons.hourglass_bottom;
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: cs.primary, width: 2),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: MATCH & STATUS
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('MATCH', style: labelStyle),
                      const SizedBox(height: 4),
                      Text(matchUp,
                          style: matchStyle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                IntrinsicWidth(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 4),
                        Text(status.toUpperCase(),
                            style: t.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: statusColor)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Row 2: YOUR TEAM & ODDS
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('YOUR TEAM', style: labelStyle),
                      const SizedBox(height: 4),
                      Text(team, style: valueStyle),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ODDS', style: labelStyle),
                      const SizedBox(height: 4),
                      Text(odds, style: valueStyle),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Row 3: STAKE & PLACED AT
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('STAKE', style: labelStyle),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(text: intPart, style: valueStyle),
                            TextSpan(
                              text: centPart,
                              style: valueStyle.copyWith(
                                  fontSize: valueStyle.fontSize! * 0.8),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                if (placedAt != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PLACED AT', style: labelStyle),
                        const SizedBox(height: 4),
                        Text(dateFmt.format(placedAt.toLocal()), style: valueStyle),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
