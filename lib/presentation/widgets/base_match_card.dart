// lib/widgets/base_match_card.dart
import 'package:flutter/material.dart';
import '../../data/models/match_model.dart';

abstract class BaseMatchCard extends StatelessWidget {
  final MatchModel match;

  const BaseMatchCard({Key? key, required this.match}) : super(key: key);

  /// This method returns the widget for the match content.
  /// Each subclass can override this to customize its appearance.
  Widget buildMatchContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    // Common card structure
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).colorScheme.primary
, width: 2),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Theme.of(context).cardColor,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: buildMatchContent(context),
      ),
    );
  }
}
