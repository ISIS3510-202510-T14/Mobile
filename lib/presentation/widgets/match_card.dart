// lib/presentation/widgets/match_card.dart

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

class MatchCard extends BaseMatchCard {
  const MatchCard({Key? key, required MatchModel match})
      : super(key: key, match: match);

  @override
  Widget buildMatchContent(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Subdued labels for date/time and venue
    final smallLabel = theme.textTheme.bodySmall
        ?.copyWith(color: colors.onSurface.withOpacity(0.6));

    // Date/time strings
    final date = match.startTime;
    final dateString = '${date.day}/${date.month}/${date.year}';
    final timeString =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    return Stack(
      clipBehavior: Clip.none,
      children: [
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
                onFavoriteChanged: (isFav) {
                  Provider.of<MatchesViewModel>(context, listen: false)
                      .toggleFavorite(match.eventId, isFav, match);
                },
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              const vsColumnWidth = 40.0;
              final halfWidth = (totalWidth - vsColumnWidth) / 2;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Team icons + VS row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left team
                      SizedBox(
                        width: halfWidth,
                        child: Align(
                          alignment: Alignment.center,
                          child: _teamIconColumn(
                            context,
                            match.logoTeamA,
                            match.homeTeam,
                          ),
                        ),
                      ),

                      // VS label
                      SizedBox(
                        width: vsColumnWidth,
                        child: Center(
                          child: Text(
                            'VS',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),

                      // Right team
                      SizedBox(
                        width: halfWidth,
                        child: Align(
                          alignment: Alignment.center,
                          child: _teamIconColumn(
                            context,
                            match.logoTeamB,
                            match.awayTeam,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 'Bet Now' button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        User? user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          final vm = BetViewModel(
                            match: match,
                            userId: user.uid,
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

                  // Date & time
                  Text(
                    '$dateString  •  $timeString',
                    style: smallLabel,
                  ),

                  // Venue
                  Text(
                    match.venue,
                    style: smallLabel,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  /// Team icon + name column (no aura)
  Widget _teamIconColumn(
      BuildContext context, String imageUrl, String teamName) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CachedNetworkImage(
          imageUrl: imageUrl,
          width: 32,
          height: 32,
          placeholder: (_, __) =>
              const SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 2)),
          errorWidget: (_, __, ___) =>
              const Icon(Icons.image_not_supported, size: 32),
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
