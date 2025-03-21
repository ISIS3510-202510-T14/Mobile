import 'package:flutter/material.dart';
import '../../data/models/match_model.dart';
import 'base_match_card.dart';

class MatchCard extends BaseMatchCard {
  const MatchCard({Key? key, required MatchModel match}) : super(key: key, match: match);

  @override
  Widget buildMatchContent(BuildContext context) {
    // Usamos match.dateTime o match.startTime para formatear la fecha/hora
    final date = match.dateTime; 
    final dateString = "${date.day}/${date.month}/${date.year}";
    final timeString = "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";


    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Título del torneo centrado
        Text(
          '${match.homeTeam} vs ${match.awayTeam}',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Row para mostrar equipos y "VS" en el centro, usando Expanded para evitar overflow
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Columna para el equipo A
            Expanded(
              child: Column(
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
                    match.homeTeam,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Widget fijo para el texto "VS"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'VS',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),

            // Columna para el equipo B
            Expanded(
              child: Column(
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
                    match.awayTeam,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Botón "Bet Now" centrado
        ElevatedButton(
          onPressed: () {
            // Acción del botón (por ejemplo, navegar a la pantalla de detalles)
          },
          child: const Text('Bet Now'),
        ),

        const SizedBox(height: 16),

        // Texto de fecha y hora
        Text(
      "Date: ${match.startTime.day}/${match.startTime.month}/${match.startTime.year}, "
      "Time: ${match.startTime.hour.toString().padLeft(2, '0')}:${match.startTime.minute.toString().padLeft(2, '0')}",
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall,
    ),
      ],
    );
  }
}
