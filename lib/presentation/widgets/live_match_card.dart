// lib/presentation/widgets/live_match_card.dart
import 'package:campus_picks/data/services/connectivity_service.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../data/models/match_model.dart';
import '../viewmodels/bet_viewmodel.dart';
import '../viewmodels/matches_view_model.dart';
import '../screens/place_bet_view.dart';
import 'base_match_card.dart';
import 'favorite_button.dart';

class LiveMatchCard extends BaseMatchCard {
  const LiveMatchCard({Key? key, required MatchModel match})
      : super(key: key, match: match);

  @override
  Widget buildMatchContent(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final smallLabel = theme.textTheme.bodySmall
        ?.copyWith(color: colors.onSurface.withOpacity(0.6));

    final date = match.startTime;
    final dateString = '${date.day}/${date.month}/${date.year}';
    final timeString =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    // Scores for center display
    final int scoreA = match.scoreTeamA ?? 0;
    final int scoreB = match.scoreTeamB ?? 0;
    final hasScore = match.scoreTeamA != null && match.scoreTeamB != null;

    // Dynamic font sizing if needed
    final bool hasThreeDigits = scoreA >= 100 || scoreB >= 100;
    final double baseFontSize = theme.textTheme.titleLarge?.fontSize ?? 22;
    final double scoreFontSize =
        hasThreeDigits ? baseFontSize * 0.8 : baseFontSize;
    final scoreStyle = theme.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.bold,
      fontSize: scoreFontSize,
    );

    final liveIndicator = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.circle, color: Colors.red, size: 10),
        const SizedBox(width: 4),
        Text(
          'LIVE',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Favorite star above card
        Positioned(
          top: -12,
          left: 0,
          right: 0,
          child: Center(
            child: FavoriteButton(
              initialFavorite: match.isFavorite,
              onFavoriteChanged: (fav) {
                Provider.of<MatchesViewModel>(context, listen: false)
                    .toggleFavorite(match.eventId, fav, match);
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Teams row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _teamIconColumn(
                      context,
                      match.logoTeamA,
                      match.homeTeam,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Center score display inspired by FinishedMatchCard
                  hasScore
                      ? SizedBox(
                          width: 80,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(scoreA.toString(), style: scoreStyle),
                                const SizedBox(width: 4),
                                Text(':', style: scoreStyle),
                                const SizedBox(width: 4),
                                Text(scoreB.toString(), style: scoreStyle),
                              ],
                            ),
                          ),
                        )
                      : Text(
                          'VS',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _teamIconColumn(
                      context,
                      match.logoTeamB,
                      match.awayTeam,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Bet Now button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      final connectivity =
                          context.read<ConnectivityNotifier>();
                      final vm = BetViewModel(
                        match: match,
                        userId: user.uid,
                        connectivity: connectivity,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BetScreen(viewModel: vm),
                        ),
                      );
                    }
                  },
                  child: const Text('Bet Now'),
                ),
              ),
              const SizedBox(height: 12),
              // Date and venue
              Text('$dateString  •  $timeString', style: smallLabel),
              Text(match.venue, style: smallLabel),
              const SizedBox(height: 8),
              // Live indicator
              liveIndicator,
            ],
          ),
        ),
      ],
    );
  }

  Widget _teamIconColumn(
    BuildContext context,
    String imageUrl,
    String teamName,
  ) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CachedNetworkImage(
          imageUrl: imageUrl,
          width: 32,
          height: 32,
          placeholder: (_, __) => const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          errorWidget: (_, __, ___) => const Icon(
            Icons.image_not_supported,
            size: 32,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          teamName,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}