// Vista (View) en Flutter que muestra las apuestas recomendadas

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../data/models/recommended_bet_model.dart';
import '../viewmodels/recommended_bet_viewmodel.dart';
import 'package:intl/intl.dart';



class RecommendedBetCard extends StatelessWidget {
  final RecommendedBet bet;
  const RecommendedBetCard({Key? key, required this.bet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    // Ícono para la sección izquierda según el tipo de apuesta
    Widget leftIcon;
    if (bet.betType.toLowerCase() == "win") {
      leftIcon = Icon(Icons.emoji_events, size: 80, color: Colors.green);
    } else if (bet.betType.toLowerCase() == "caution") {
      leftIcon = Icon(Icons.error_outline, size: 80, color: Colors.orange); // Ícono distinto para caution
    } else {
      leftIcon = Icon(Icons.event, size: 80, color: Colors.grey);
    }

    // Ícono para la fila del tipo de apuesta
    Icon betTypeIcon;
    if (bet.betType.toLowerCase() == "win") {
      betTypeIcon = Icon(Icons.thumb_up, color: Colors.green, size: 24);
    } else if (bet.betType.toLowerCase() == "caution") {
      betTypeIcon = Icon(Icons.warning, color: Colors.orange, size: 24); // Ícono diferente para caution
    } else {
      betTypeIcon = Icon(Icons.info, color: Colors.grey, size: 24);
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Ícono representativo del evento, dinámico según el tipo de apuesta
            leftIcon,
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fila para el tipo de apuesta con ícono
                  Row(
                    children: [
                      betTypeIcon,
                      const SizedBox(width: 8),
                      Text(
                        bet.betType.toUpperCase(),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Descripción de la apuesta
                  Text(
                    bet.description,
                    textAlign: TextAlign.justify,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.3,
                          fontSize: 14,
                        ),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Fecha de recomendación
                  Text(
                    'Recommended on: ${dateFormat.format(bet.createdAt)}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  // Mostrar el eventId (opcional)
                  Text(
                    'Event ID: ${bet.eventId}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}




class RecommendedBetsScreen extends StatelessWidget {
  const RecommendedBetsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecommendedBetsViewModel()..fetchRecommendedBets(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Recommended Bets")),
        body: Consumer<RecommendedBetsViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (viewModel.error != null) {
              // En lugar de mostrar el error detallado, mostramos un mensaje amigable
              return const Center(
                child: Text(
                  "Unable to fetch recommendations. Please try again later.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              );
            } else if (viewModel.recommendedBets.isEmpty) {
              return const Center(child: Text("No recommendations available"));
            } else {
              return ListView.builder(
                itemCount: viewModel.recommendedBets.length,
                itemBuilder: (context, index) {
                  final bet = viewModel.recommendedBets[index];
                  return RecommendedBetCard(bet: bet);
                },
              );
            }
          },
        ),
      ),
    );
  }
}