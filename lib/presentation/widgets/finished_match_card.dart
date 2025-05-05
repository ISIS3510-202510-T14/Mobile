// lib/presentation/widgets/finished_match_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import '../../data/models/match_model.dart';
import '../viewmodels/matches_view_model.dart';
import 'base_match_card.dart';
import 'favorite_button.dart';

class FinishedMatchCard extends BaseMatchCard {
  const FinishedMatchCard({Key? key, required MatchModel match})
      : super(key: key, match: match);

  @override
  Widget buildMatchContent(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Small, subdued labels
    final smallLabel = theme.textTheme.bodySmall
        ?.copyWith(color: colors.onSurface.withOpacity(0.6));

    // Date/time formatting
    final date = match.startTime;
    final dateString = '${date.day}/${date.month}/${date.year}';
    final timeString =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    // Scores and winner flags
    final int scoreA = match.scoreTeamA ?? 0;
    final int scoreB = match.scoreTeamB ?? 0;
    final isTeamAWinner = scoreA > scoreB;
    final isTeamBWinner = scoreB > scoreA;

    // Determine dynamic score font size if three digits
    final bool hasThreeDigits = scoreA >= 100 || scoreB >= 100;
    final double baseFontSize =
        theme.textTheme.titleLarge?.fontSize ?? 22;
    final double scoreFontSize = hasThreeDigits
        ? baseFontSize * 0.8
        : baseFontSize;
    final scoreStyle = theme.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.bold,
      fontSize: scoreFontSize,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // total width inside the 16px padding on each side
              final total = constraints.maxWidth;
              const scoreW = 80.0;
              // split the rest equally
              final half = (total - scoreW) / 2;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ─── 3‑column row ───
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // left half
                      SizedBox(
                        width: half,
                        child: Align(
                          alignment: Alignment.center,
                          child: _teamBadge(
                            context: context,
                            imageUrl: match.logoTeamA,
                            teamName: match.homeTeam,
                            isWinner: isTeamAWinner,
                          ),
                        ),
                      ),

                      // center score (fixed)
                      SizedBox(
                        width: scoreW,
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
                      ),

                      // right half
                      SizedBox(
                        width: half,
                        child: Align(
                          alignment: Alignment.center,
                          child: _teamBadge(
                            context: context,
                            imageUrl: match.logoTeamB,
                            teamName: match.awayTeam,
                            isWinner: isTeamBWinner,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Date/time & venue
                  Text('$dateString  •  $timeString', style: smallLabel),
                  const SizedBox(height: 4),
                  Text(match.venue, style: smallLabel),
                ],
              );
            },
          ),
        ),

        // Favorite star centered above card
        Positioned(
          top: -12,
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.topCenter,
            child: Material(
              color: Colors.transparent,
              child: FavoriteButton(
                initialFavorite: match.isFavorite,
                onFavoriteChanged: (fav) {
                  Provider.of<MatchesViewModel>(context, listen: false)
                      .toggleFavorite(match.eventId, fav, match);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Exactly as before—icon + name with aura + ellipsizing.
  Widget _teamBadge({
    required BuildContext context,
    required String imageUrl,
    required String teamName,
    required bool isWinner,
  }) {
    final theme = Theme.of(context);
    final auraColor = isWinner
        ? theme.colorScheme.secondary.withOpacity(0.8)
        : theme.colorScheme.error.withOpacity(0.6);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: auraColor, blurRadius: 12, spreadRadius: 4),
            ],
          ),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: 32,
            height: 32,
            placeholder: (_, __) =>
                const SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 2)),
            errorWidget: (_, __, ___) => const Icon(Icons.image_not_supported, size: 32),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            teamName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}