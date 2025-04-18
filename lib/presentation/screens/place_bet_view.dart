import 'package:campus_picks/theme/spacing.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../viewmodels/bet_viewmodel.dart';

class BetScreen extends StatefulWidget {
  final BetViewModel viewModel;

  const BetScreen({super.key, required this.viewModel});

  @override
  _BetScreenState createState() => _BetScreenState();
}

class _BetScreenState extends State<BetScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  String? selectedTeam;
  
  Future<void> _placeBet(double amount) async {
    final url = Uri.parse('http://localhost:8000/api/bets');
    final odds = selectedTeam == widget.viewModel.match.homeTeam ? widget.viewModel.oddsA : widget.viewModel.oddsB;
    final body = jsonEncode({
      "userId": widget.viewModel.userId,
      "eventId": widget.viewModel.match.acidEventId,
      "stake": amount,
      "odds": odds,
      "team": selectedTeam,
      
    });
    
    print('Placing bet with body: $body');



    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            content: const Text('Bet placed successfully'),
          ),
        );
        Navigator.pop(context);
      } else {
        print('failed body: $body');
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
    final amount = double.parse(_amountController.text);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Image.asset(selectedTeam == widget.viewModel.match.homeTeam ? widget.viewModel.match.logoTeamA : widget.viewModel.match.logoTeamB, width: 50,height: 50,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
                  ),
        content: Text('Are you sure you want to bet ¢${amount.toStringAsFixed(0)} on $selectedTeam with odds of ${selectedTeam == widget.viewModel.match.homeTeam ? widget.viewModel.oddsA.toStringAsFixed(2) : widget.viewModel.oddsB.toStringAsFixed(2)}?'),
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
    final theme   = Theme.of(context);
    final colors  = theme.colorScheme;
    final vm      = widget.viewModel;
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
                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                textAlign: TextAlign.center,
                style: theme.textTheme.displayLarge!.copyWith(color: colors.primary),
                decoration: const InputDecoration(
                  hintText: '¢0',
                  border: InputBorder.none,
                ),
                validator: (value) {
                  final v = double.tryParse(value ?? '');
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
    required String  team,
    required double  odds,
    required bool    selected,
    required VoidCallback onTap,
    required Color   selectedColor,
  }) {
    final theme  = Theme.of(context);
    final colors = theme.colorScheme;

    return ChoiceChip(
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: selectedColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      label: SizedBox(
        width: 120,                        // fixed width keeps all chips equal
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
