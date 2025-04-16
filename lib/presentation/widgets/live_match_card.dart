import 'package:flutter/material.dart';
import '../../data/models/match_model.dart';
import 'base_match_card.dart';
import 'favorite_button.dart'; // Asegúrate de tener este widget
import 'package:firebase_auth/firebase_auth.dart';
import 'package:campus_picks/presentation/screens/place_bet_view.dart';
import '../viewmodels/bet_viewmodel.dart';
import '../viewmodels/matches_view_model.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';


class LiveMatchCard extends BaseMatchCard {
  const LiveMatchCard({Key? key, required MatchModel match})
      : super(key: key, match: match);

  @override
  Widget buildMatchContent(BuildContext context) {
    final scoreA = match.scoreTeamA ?? 0;
    final scoreB = match.scoreTeamB ?? 0;
    final minute = match.minute ?? 0;

    final dateString =
        "${match.startTime.day}/${match.startTime.month}/${match.startTime.year}";
    final timeString =
        "${match.startTime.hour.toString().padLeft(2, '0')}:${match.startTime.minute.toString().padLeft(2, '0')}";

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

    // Se envuelve el contenido en un Stack para posicionar el botón sin perder el layout existente
    return Stack(
      children: [
        // Contenido principal
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            liveIndicator,
            const SizedBox(height: 8),
            Text(
              '${match.homeTeam} vs ${match.awayTeam}',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 100,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                         CachedNetworkImage(
                          imageUrl: match.logoTeamA, // Se asume que es una URL.
                          width: 40,
                          height: 40,
                          placeholder: (context, url) => const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
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
                Container(
                  width: 100,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                         CachedNetworkImage(
                          imageUrl: match.logoTeamB, // Se asume que es una URL.
                          width: 40,
                          height: 40,
                          placeholder: (context, url) => const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
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
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "$minute’",
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                User? user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  print('UID: ${user.uid}');
                  BetViewModel betViewModel = BetViewModel(
                    match: match,
                    userId: user.uid,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BetScreen(viewModel: betViewModel),
                    ),
                  );
                } else {
                  print('No hay usuario autenticado');
                }
              },
              child: const Text('Bet Now'),
            ),
            const SizedBox(height: 16),
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
        ),
        // Botón de favorito posicionado en la esquina superior derecha
        Positioned(
          top: 8,
          right: 8,
          child: FavoriteButton(
            initialFavorite: match.isFavorite, // Aquí puedes inyectar el estado inicial real
            onFavoriteChanged: (isFav) {
              // Sincronizar con el backend o actualizar el estado en el ViewModel
              Provider.of<MatchesViewModel>(context, listen: false).toggleFavorite(match.eventId, isFav, match);
              print("Match ${match.eventId} favorited: $isFav");
            },
          ),
        ),
      ],
    );
  }
}
