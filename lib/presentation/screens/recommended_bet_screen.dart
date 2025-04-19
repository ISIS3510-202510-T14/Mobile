import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/recommended_bet_model.dart';
import '../viewmodels/recommended_bet_viewmodel.dart';

/// Elegant screen listing recommended bets with refined styling and detail modal.
class RecommendedBetsScreen extends StatelessWidget {
  const RecommendedBetsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChangeNotifierProvider(
      create: (_) => RecommendedBetsViewModel()..fetchRecommendedBets(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Recommended Bets'),
        ),
        body: Consumer<RecommendedBetsViewModel>(
          builder: (context, vm, _) {
            if (vm.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (vm.error != null) {
              return Center(
                child: Text(
                  'Unable to fetch recommendations',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              );
            }
            final bets = vm.recommendedBets;
            if (bets.isEmpty) {
              return Center(
                child: Text(
                  'No recommendations',
                  style: theme.textTheme.bodyMedium,
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: bets.length,
              itemBuilder: (context, index) => RecommendedBetCard(bet: bets[index]),
            );
          },
        ),
      ),
    );
  }
}

/// Card displaying a single recommended bet with concise labels and modern styling,
/// tapping opens a detail modal.
class RecommendedBetCard extends StatelessWidget {
  final RecommendedBet bet;
  const RecommendedBetCard({Key? key, required this.bet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    // Determine icon and color based on bet type
    late final IconData iconData;
    late final Color iconColor;
    switch (bet.betType.toLowerCase()) {
      case 'win':
        iconData = Icons.emoji_events;
        iconColor = theme.colorScheme.secondary;
        break;
      case 'caution':
        iconData = Icons.error_outline;
        iconColor = theme.colorScheme.error;
        break;
      default:
        iconData = Icons.info_outline;
        iconColor = theme.colorScheme.onSurface.withOpacity(0.6);
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
      ),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          radius: 28,
          child: Icon(iconData, size: 32, color: iconColor),
        ),
        title: Text(
          bet.description,
          style: theme.textTheme.bodyLarge,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.6)),
              const SizedBox(width: 4),
              Text(
                dateFormat.format(bet.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            bet.betType.toUpperCase(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: iconColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onTap: () => _showDetailModal(context),
      ),
    );
  }

  void _showDetailModal(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: theme.colorScheme.surface,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollCtrl) {
            return SingleChildScrollView(
              controller: scrollCtrl,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        betTypeIcon(),
                        size: 32,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        bet.betType.toUpperCase(),
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    bet.description,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 20, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                      const SizedBox(width: 8),
                      Text(
                        dateFormat.format(bet.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  IconData betTypeIcon() {
    switch (bet.betType.toLowerCase()) {
      case 'win':
        return Icons.thumb_up;
      case 'caution':
        return Icons.warning;
      default:
        return Icons.info;
    }
  }
}
