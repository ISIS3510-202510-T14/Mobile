// lib/widgets/live_match_card.dart
import 'package:flutter/material.dart';
import '../../data/models/match_model.dart';
import 'base_match_card.dart';

class LiveMatchCard extends BaseMatchCard {
  const LiveMatchCard({Key? key, required MatchModel match})
      : super(key: key, match: match);

  @override
  Widget buildMatchContent(BuildContext context) {
    // Current score (if any)
    final scoreA = match.scoreTeamA ?? 0;
    final scoreB = match.scoreTeamB ?? 0;

    // Minute or time elapsed in the match
    final minute = match.minute ?? 0;

    // Format date/time if you still want to display it
    final dateString = "${match.dateTime.day}/${match.dateTime.month}/${match.dateTime.year}";
    final timeString = "${match.dateTime.hour.toString().padLeft(2, '0')}:${match.dateTime.minute.toString().padLeft(2, '0')}";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // "LIVE" indicator in red
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.circle, color: Colors.red, size: 10),
            const SizedBox(width: 4),
            Text(
              "LIVE",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Tournament title
        Text(
          match.tournament,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Row with team logos and scores
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Team A
            Column(
              children: [
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

            // Score A
            Text(
              scoreA.toString(),
              style: Theme.of(context).textTheme.titleMedium,
            ),

            // Separator (like " - ")
            const Text('-', style: TextStyle(fontSize: 16)),

            // Score B
            Text(
              scoreB.toString(),
              style: Theme.of(context).textTheme.titleMedium,
            ),

            // Team B
            Column(
              children: [
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

        // Show minute or time elapsed
        Text(
          "$minute’", // E.g. "53’"
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
        ),
        const SizedBox(height: 12),

        // "Bet Now" button
        ElevatedButton(
          onPressed: () {
            // Action for live betting
          },
          child: const Text('Bet Now'),
        ),

        const SizedBox(height: 16),

        // (Optional) date/time
        Text(
          "Date: $dateString, Time: $timeString",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
