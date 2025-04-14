import 'package:campus_picks/data/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../data/models/match_model.dart';
import 'base_match_card.dart';
import 'package:campus_picks/presentation/screens/place_bet_view.dart';
import '../viewmodels/bet_viewmodel.dart';

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
    // AuthRepository authRepository = AuthRepository();
    // User? user = FirebaseAuth.instance.currentUser;

    // if (user?.email != null) {
    //   authRepository.readToken(user!.email!).then((token) {
    //     if (token != null) {
    //       print('Token: $token');
       
          
    //       BetViewModel betViewModel = BetViewModel(
    //           match: match,
    //           userId: token,

    //       );


          
    //       Navigator.push(
    //           context,
    //           MaterialPageRoute(
    //             builder: (context) => BetScreen(viewModel: betViewModel),
    //           ),
    //       );
    //     } else {
    //       print('Token not found');
    //     }
    //   }).catchError((e) {
    //     print('Error reading token: $e');
    //   });
    // } else {
    //   print('User email is null');
    // }
    // // Acción del botón (por ejemplo, navegar a la pantalla de detalles)

    User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print('UID: ${user.uid}');
        
        BetViewModel betViewModel = BetViewModel(
          match: match,
          userId: user.uid, // Aquí usas el uid en lugar del token
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
    );
  }
}
