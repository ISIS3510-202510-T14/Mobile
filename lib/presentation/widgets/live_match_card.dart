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

    final smallLabel =
        theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withOpacity(0.6));

    final date = match.startTime;
    final dateString = '${date.day}/${date.month}/${date.year}';
    final timeString =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    final scoreA = match.scoreTeamA;
    final scoreB = match.scoreTeamB;
    final hasScore = scoreA != null && scoreB != null;

    final liveIndicator = Row(
      mainAxisAlignment: MainAxisAlignment.center,
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
        Positioned(
          top: -12,
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.topCenter,
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              const centerWidth = 40.0;
              final sideWidth = (totalWidth - centerWidth) / 2;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  liveIndicator,
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: sideWidth,
                        child: Align(
                          alignment: Alignment.center,
                          child: _teamIconColumn(
                            context,
                            match.logoTeamA,
                            match.homeTeam,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: centerWidth,
                        child: Center(
                          child: Text(
                            hasScore ? '${scoreA ?? ''} - ${scoreB ?? ''}' : 'VS',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: sideWidth,
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        User? user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          final connectivity = context.read<ConnectivityNotifier>();
                          final vm = BetViewModel(
                            match: match,
                            userId: user.uid,
                            connectivity: connectivity,
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => BetScreen(viewModel: vm)),
                          );
                        }
                      },
                      child: const Text('Bet Now'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('$dateString  •  $timeString', style: smallLabel),
                  Text(match.venue, style: smallLabel),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

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
          errorWidget: (_, __, ___) => const Icon(Icons.image_not_supported, size: 32),
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
