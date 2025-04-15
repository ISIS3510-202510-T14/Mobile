import 'package:flutter/material.dart';
import '../../data/models/match_model.dart';
import 'base_match_card.dart';
import 'favorite_button.dart';
import '../viewmodels/matches_view_model.dart';
import 'package:provider/provider.dart';


class FinishedMatchCard extends BaseMatchCard {
  const FinishedMatchCard({Key? key, required MatchModel match})
      : super(key: key, match: match);

  @override
  Widget buildMatchContent(BuildContext context) {
    final dateString =
        "${match.dateTime.day}/${match.dateTime.month}/${match.dateTime.year}";
    final timeString =
        "${match.dateTime.hour.toString().padLeft(2, '0')}:${match.dateTime.minute.toString().padLeft(2, '0')}";
    final scoreA = match.scoreTeamA ?? 0;
    final scoreB = match.scoreTeamB ?? 0;

    final isTie = scoreA == scoreB;
    final isTeamAWinner = scoreA > scoreB;
    final isTeamBWinner = scoreB > scoreA;

    final crownIcon = Icon(
      Icons.emoji_events,
      color: Colors.yellow.shade600,
      size: 20,
    );

    // Contenido principal de la card
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '${match.homeTeam} vs ${match.awayTeam}',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isTeamAWinner && !isTie) crownIcon,
                      const SizedBox(height: 4),
                      Image.asset(
                        match.logoTeamA,
                        width: 40,
                        height: 40,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        match.homeTeam,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 100,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        scoreA.toString(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Text(
                        ':',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        scoreB.toString(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isTeamBWinner && !isTie) crownIcon,
                      const SizedBox(height: 4),
                      Image.asset(
                        match.logoTeamB,
                        width: 40,
                        height: 40,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        match.awayTeam,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        if (isTie)
          Text(
            '¡Draw!',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey),
          ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Date: $dateString, Time: $timeString",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                "Venue: ${match.venue}",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );

    // Se envuelve el contenido en un Stack e incluye el FavoriteButton
    return Stack(
      children: [
        content,
        Positioned(
          top: 8,
          right: 8,
          child: FavoriteButton(
            initialFavorite: match.isFavorite,
            onFavoriteChanged: (isFav) {
              // Aquí actualizas el estado en la base de datos local o en tu ViewModel
              Provider.of<MatchesViewModel>(context, listen: false).toggleFavorite(match.eventId, isFav, match);
              print("Match ${match.eventId} favorited: $isFav");
            },
          ),
        ),
      ], 
    );
  }
}
