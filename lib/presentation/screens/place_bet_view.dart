// lib/presentation/screens/place_bet_view.dart
// UPDATED – adds confirmation dialog, offline draft flag, and unconditional pop

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:campus_picks/theme/spacing.dart';
import 'package:campus_picks/theme/app_shapes.dart';
import 'package:campus_picks/data/services/connectivity_service.dart';
import 'package:provider/provider.dart';
import '../viewmodels/bet_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../viewmodels/user_bets_view_model.dart';

/// Formats numeric input as US currency with commas and two decimals
class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter =
      NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      final zero = _formatter.format(0);
      return TextEditingValue(
        text: zero,
        selection: TextSelection.collapsed(offset: zero.length),
      );
    }
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
  final TextEditingController _amountController = TextEditingController(
    text: NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2)
        .format(0),
  );
  String? selectedTeam;
  late ConnectivityNotifier connectivity;

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onVmMessage);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onVmMessage);
    super.dispose();
  }

  void _onVmMessage() {
    final msg = widget.viewModel.lastMessage;
    if (msg != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
      widget.viewModel.lastMessage = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    connectivity = context.watch<ConnectivityNotifier>();
    final offline = !connectivity.isOnline;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final vm = widget.viewModel;
    const spacing = EdgeInsets.all(AppSpacing.l);

    return Scaffold(
      appBar: AppBar(title: const Text('Place bet')),
      body: Column(
        children: [
          if (offline)
            Container(
              height: 20,
              width: double.infinity,
              color: colors.primary,
              alignment: Alignment.center,
              child: Text(
                'OFF‑LINE  •  saving draft bet',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: colors.onPrimary),
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: spacing,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ----- amount input -----
                    TextFormField(
                      controller: _amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [CurrencyInputFormatter()],
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displayLarge!
                          .copyWith(color: colors.primary),
                      decoration: const InputDecoration(border: InputBorder.none),
                      validator: (value) {
                        final raw =
                            value?.replaceAll(RegExp(r'[^0-9.]'), '');
                        final v = double.tryParse(raw ?? '');
                        if (v == null || v <= 0) {
                          return 'Enter a positive amount';
                        }
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
                          onTap: () =>
                              setState(() => selectedTeam = vm.match.homeTeam),
                          selectedColor: colors.secondary,
                        ),
                        _teamChip(
                          team: vm.match.awayTeam,
                          odds: vm.oddsB,
                          selected: selectedTeam == vm.match.awayTeam,
                          onTap: () =>
                              setState(() => selectedTeam = vm.match.awayTeam),
                          selectedColor: colors.tertiary,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    // ----- submit -----
                    ElevatedButton(
                      onPressed: selectedTeam == null
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) return;

                              // ───── confirmation ─────
                              final bool? ok = await showDialog<bool>(
                                context: context,
                                builder: (ctx) {
                                  final cs = Theme.of(ctx).colorScheme;
                                  return AlertDialog(
                                    shape: AppShapes.dialogShape,
                                    backgroundColor: cs.surface,
                                    title: const Text('Confirm bet'),
                                    content: const Text(
                                        'Are you sure you want to place this bet?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, false),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(ctx, true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: cs.primary,
                                          foregroundColor: cs.onPrimary,
                                          shape: AppShapes.buttonShape,
                                        ),
                                        child: const Text('Yes, place bet'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              if (ok != true) return; // user cancelled

                              // ───── proceed ─────
                              final raw = _amountController.text
                                  .replaceAll(RegExp(r'[^0-9.]'), '');
                              final amount = double.tryParse(raw) ?? 0;
                              final bool offline = !connectivity.isOnline;

                              await widget.viewModel
                                  .placeBet(amount, selectedTeam!, offline);
                              if (offline) {
                                final uid = FirebaseAuth.instance.currentUser!.uid;
                                // ignore: use_build_context_synchronously
                                context.read<UserBetsViewModel>()
                                  .loadBets(uid, forceRemote: false);
                              }

                              // Always pop back after we queued the bet
                              if (mounted) Navigator.pop(context);
                            },
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
                  fontWeight: FontWeight.w600, color: colors.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}
