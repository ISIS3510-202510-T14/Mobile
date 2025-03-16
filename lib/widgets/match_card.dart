// lib/widgets/match_card.dart
import 'package:flutter/material.dart';
import '../data/models/match_model.dart';
import 'base_match_card.dart';

class MatchCard extends BaseMatchCard {
  const MatchCard({Key? key, required MatchModel match}) : super(key: key, match: match);

  @override
  Widget buildMatchContent(BuildContext context) {
    // Format date/time strings
    final dateString = "${match.dateTime.day}/${match.dateTime.month}/${match.dateTime.year}";
    final timeString = "${match.dateTime.hour.toString().padLeft(2, '0')}:${match.dateTime.minute.toString().padLeft(2, '0')}";

    return Column(
      // Center all content horizontally
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Centered tournament title
        Text(
          match.tournament,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Row to show teams and "VS" in the center
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Team A column (image on top, name below)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  match.logoTeamA,
                  width: 50,
                  height: 50,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported),
                ),
                const SizedBox(height: 8),
                Text(
                  match.teamA,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),

            // "VS" text column
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'VS',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),

            // Team B column (image on top, name below)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  match.logoTeamB,
                  width: 50,
                  height: 50,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported),
                ),
                const SizedBox(height: 8),
                Text(
                  match.teamB,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Centered "Bet Now" button
        ElevatedButton(
          onPressed: () {
            // Button action, e.g., navigate to details screen
          },
          child: const Text('Bet Now'),
        ),

        const SizedBox(height: 16),

        // Date and time text below the button
        Text(
          "Date: $dateString, Time: $timeString",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
