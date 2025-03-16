// lib/widgets/finished_match_card.dart
import 'package:flutter/material.dart';
import '../data/models/match_model.dart';
import 'base_match_card.dart';

class FinishedMatchCard extends BaseMatchCard {
  const FinishedMatchCard({Key? key, required MatchModel match})
      : super(key: key, match: match);

  @override
  Widget buildMatchContent(BuildContext context) {
    // Format date/time
    final dateString = "${match.dateTime.day}/${match.dateTime.month}/${match.dateTime.year}";
    final timeString = "${match.dateTime.hour.toString().padLeft(2, '0')}:${match.dateTime.minute.toString().padLeft(2, '0')}";

    // Determine scores
    final scoreA = match.scoreTeamA ?? 0;
    final scoreB = match.scoreTeamB ?? 0;

    // Check winner (if there's no tie)
    final isTie = scoreA == scoreB;
    final isTeamAWinner = scoreA > scoreB;
    final isTeamBWinner = scoreB > scoreA;

    // Example crown icon (you can replace it with a custom icon)
    final crownIcon = Icon(
      Icons.emoji_events,
      color: Colors.yellow.shade600,
      size: 20,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Tournament title
        Text(
          match.tournament,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Row with logos, scores, and potential crown for the winner
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Team A column
            Column(
              children: [
                // If Team A is winner, show a crown on top
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
                  match.teamA,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),

            // Score for Team A
            Text(
              scoreA.toString(),
              style: Theme.of(context).textTheme.titleMedium,
            ),

            // Separator for scores
            const Text(
              ':',
              style: TextStyle(fontSize: 18),
            ),

            // Score for Team B
            Text(
              scoreB.toString(),
              style: Theme.of(context).textTheme.titleMedium,
            ),

            // Team B column
            Column(
              children: [
                // If Team B is winner, show a crown on top
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
                  match.teamB,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),

        // If tie, show something like "Empate" or "Draw"
        if (isTie)
          Text(
            '¡Draw!',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey),
          ),

        const SizedBox(height: 12),

        // Additional info (date, time, location, etc.)
        Text(
          "Date: $dateString, Time: $timeString",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        // If you have location or other data, add it here
      ],
    );
  }
}
