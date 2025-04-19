import 'package:campus_picks/data/models/bet_model.dart';
import 'package:campus_picks/data/repositories/bet_repository.dart';
import 'package:campus_picks/theme/spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../viewmodels/bet_viewmodel.dart';

/// Formats numeric input as US currency with commas and two decimals
class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Strip non-numeric characters
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return TextEditingValue(
      text: _formatter.format(0),
      selection: TextSelection.collapsed(offset: _formatter.format(0).length),
    );
    double value = double.parse(digits) / 100;
    String formatted = _formatter.format(value);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class BetScreen extends StatefulWidget {
  final BetViewModel viewModel;

  const BetScreen({super.key, required this.viewModel});

  @override
  _BetScreenState createState() => _BetScreenState();
}

class _BetScreenState extends State<BetScreen> {
  final _formKey = GlobalKey<FormState>();
  // Initialize with $0.00 by default
  final TextEditingController _amountController = TextEditingController(
    text: NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2).format(0),
  );
  String? selectedTeam;

  Future<void> _placeBet(double amount) async {
    final url = Uri.parse('http://localhost:8000/api/bets');
    final odds = selectedTeam == widget.viewModel.match.homeTeam
        ? widget.viewModel.oddsA
        : widget.viewModel.oddsB;
    final body = jsonEncode({
      "userId": widget.viewModel.userId,
      "eventId": widget.viewModel.match.acidEventId,
      "stake": amount,
      "odds": odds,
      "team": selectedTeam,
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final repo = BetRepository();
        await repo.insertBet(
          BetModel(
            betId: data['betId'],
            userId: widget.viewModel.userId,
            eventId: widget.viewModel.match.eventId,
            team: selectedTeam!,
            stake: amount,
            odds: odds,
            status: 'placed',
            createdAt: DateTime.parse(data['timestamp']),
            updatedAt: DateTime.parse(data['timestamp']),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            content: const Text('Bet placed successfully'),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: const Text('Failed to place bet'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text('Error: $e'),
        ),
      );
    }
  }

  void _confirmBet() {
    if (!_formKey.currentState!.validate()) return;
    // Parse formatted string back to double
    final raw = _amountController.text.replaceAll(RegExp(r'[^0-9.]'), '');
    final amount = double.tryParse(raw) ?? 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Image.asset(
          selectedTeam == widget.viewModel.match.homeTeam
              ? widget.viewModel.match.logoTeamA
              : widget.viewModel.match.logoTeamB,
          width: 50,
          height: 50,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.image_not_supported),
        ),
        content: Text(
          'Are you sure you want to bet ${_amountController.text} on $selectedTeam '
          'with odds of ${selectedTeam == widget.viewModel.match.homeTeam ? widget.viewModel.oddsA.toStringAsFixed(2) : widget.viewModel.oddsB.toStringAsFixed(2)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _placeBet(amount);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final vm = widget.viewModel;
    final spacing = const EdgeInsets.all(AppSpacing.l);

    return Scaffold(
      appBar: AppBar(title: const Text('Place bet')),
      body: SingleChildScrollView(
        padding: spacing,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ----- amount input -----
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [CurrencyInputFormatter()],
                textAlign: TextAlign.center,
                style: theme.textTheme.displayLarge!.copyWith(color: colors.primary),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                validator: (value) {
                  final raw = value?.replaceAll(RegExp(r'[^0-9.]'), '');
                  final v = double.tryParse(raw ?? '');
                  if (v == null || v <= 0) return 'Enter a positive amount';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              // ----- team selector -----
              Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpacing.s,
                children: [
                  _teamChip(
                    team: vm.match.homeTeam,
                    odds: vm.oddsA,
                    selected: selectedTeam == vm.match.homeTeam,
                    onTap: () => setState(() => selectedTeam = vm.match.homeTeam),
                    selectedColor: colors.secondary,
                  ),
                  _teamChip(
                    team: vm.match.awayTeam,
                    odds: vm.oddsB,
                    selected: selectedTeam == vm.match.awayTeam,
                    onTap: () => setState(() => selectedTeam = vm.match.awayTeam),
                    selectedColor: colors.tertiary,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // ----- submit -----
              ElevatedButton(
                onPressed: selectedTeam == null ? null : _confirmBet,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _teamChip({
    required String team,
    required double odds,
    required bool selected,
    required VoidCallback onTap,
    required Color selectedColor,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ChoiceChip(
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: selectedColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      label: SizedBox(
        width: 120,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              team,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 2),
            Text(
              odds.toStringAsFixed(2),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}