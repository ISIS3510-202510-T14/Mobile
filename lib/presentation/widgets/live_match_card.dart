// lib/widgets/live_match_card.dart
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

    // Styles for small labels (less contrast)
    final labelStyle = theme.textTheme.bodySmall?.copyWith(
      color: colors.onSurface.withOpacity(0.6),
      fontSize: theme.textTheme.bodySmall!.fontSize! * 0.9,
    );

    final scoreA = match.scoreTeamA ?? 0;
    final scoreB = match.scoreTeamB ?? 0;
    final minute = match.minute ?? 0;

    final date = match.startTime;
    final dateString = "${date.day}/${date.month}/${date.year}";
    final timeString =
        "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";

    Widget liveIndicator = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.circle, color: Colors.red, size: 10),
        const SizedBox(width: 4),
        Text(
          "LIVE",
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
        // Favorite star centered above card
        Positioned(
          top: -12,
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.topCenter,
            child: FavoriteButton(
              initialFavorite: match.isFavorite,
              onFavoriteChanged: (isFav) {
                Provider.of<MatchesViewModel>(context, listen: false)
                    .toggleFavorite(match.eventId, isFav, match);
              },
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              liveIndicator,
              const SizedBox(height: 8),

              // Teams + minute row, evenly split with center fixed width
              LayoutBuilder(
                builder: (context, constraints) {
                  final totalWidth = constraints.maxWidth;
                  const centerWidth = 40.0;
                  final sideWidth = (totalWidth - centerWidth) / 2;
                  return Row(
                    children: [
                      SizedBox(
                        width: sideWidth,
                        child: _buildTeamColumn(
                          match.logoTeamA,
                          scoreA.toString(),
                          match.homeTeam,
                          theme,
                        ),
                      ),
                      SizedBox(
                        width: centerWidth,
                        child: Center(
                          child: Text(
                            '$minute’',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: colors.onSurface.withOpacity(0.6)),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: sideWidth,
                        child: _buildTeamColumn(
                          match.logoTeamB,
                          scoreB.toString(),
                          match.awayTeam,
                          theme,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(dateString, style: labelStyle),
                  const SizedBox(width: 8),
                  Text(timeString, style: labelStyle),
                ],
              ),
              const SizedBox(height: 4),
              Text(match.venue, style: labelStyle),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    final vm = BetViewModel(match: match, userId: user.uid);
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeamColumn(
    String logoUrl,
    String score,
    String team,
    ThemeData theme,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CachedNetworkImage(
          imageUrl: logoUrl,
          width: 32,
          height: 32,
          placeholder: (_, __) =>
              const SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 2)),
          errorWidget: (_, __, ___) => const Icon(Icons.image_not_supported, size: 32),
        ),
        const SizedBox(height: 4),
        Text(
          score,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          team,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
