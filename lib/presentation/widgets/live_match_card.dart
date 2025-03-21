// lib/widgets/live_match_card.dart
import 'package:flutter/material.dart';
import '../../data/models/match_model.dart';
import 'base_match_card.dart';

class LiveMatchCard extends BaseMatchCard {
  const LiveMatchCard({Key? key, required MatchModel match})
      : super(key: key, match: match);

  @override
  Widget buildMatchContent(BuildContext context) {
    // Score actual (fallback a 0)
    final scoreA = match.scoreTeamA ?? 0;
    final scoreB = match.scoreTeamB ?? 0;
  


    // Minuto actual o tiempo transcurrido
    final minute = match.minute ?? 0;

    // Formateo de fecha y hora usando match.startTime
    final dateString =
        "${match.startTime.day}/${match.startTime.month}/${match.startTime.year}";
    final timeString =
        "${match.startTime.hour.toString().padLeft(2, '0')}:${match.startTime.minute.toString().padLeft(2, '0')}";

    // Indicador LIVE (icono y texto)
    Widget liveIndicator = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.circle, color: Colors.red, size: 10),
        const SizedBox(width: 4),
        Text(
          "LIVE",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Indicador LIVE arriba
        liveIndicator,
        const SizedBox(height: 8),
        // Título del partido
        Text(
          '${match.homeTeam} vs ${match.awayTeam}',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        // Fila con la información de cada equipo
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Columna para el equipo A
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
                  scoreA.toString(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  match.homeTeam,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            // Columna para el equipo B
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
                  scoreB.toString(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  match.awayTeam,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Mostrar el minuto transcurrido (ejemplo: "53’")
        Text(
          "$minute’",
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 12),
        // Botón "Bet Now"
        ElevatedButton(
          onPressed: () {
            // Acción para apostar en vivo
          },
          child: const Text('Bet Now'),
        ),
        const SizedBox(height: 16),
        // Información de fecha y hora
        Text(
          "Date: $dateString, Time: $timeString",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
