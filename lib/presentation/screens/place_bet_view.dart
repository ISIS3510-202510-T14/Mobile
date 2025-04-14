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
  final TextEditingController _amountController = TextEditingController(text: '0');
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
          SnackBar(content: Text('Bet placed successfully')),
        );
        Navigator.pop(context);
      } else {
        print('failed body: $body');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place bet')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _confirmBet() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0 ) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid bet amount')),
      );
      return;
    }
    
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
    final vm = widget.viewModel;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Input amount', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.yellow, fontSize: 32, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Image.asset(vm.match.logoTeamA, width: 50, height: 50,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported)),
                  Text(vm.match.homeTeam, style: const TextStyle(color: Colors.white))
                ],
              ),
              const SizedBox(width: 20),
              Column(
                children: [
                  Image.asset(vm.match.logoTeamB, width: 50, height: 50,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported)),
                  Text(vm.match.awayTeam, style: const TextStyle(color: Colors.white))
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            children: [
              ChoiceChip(
                label: SizedBox(
                  width: 120,
                  child: Text(
                    '${vm.match.homeTeam} (${vm.oddsA.toStringAsFixed(2)})',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                selected: selectedTeam == vm.match.homeTeam,
                onSelected: (selected) => setState(() => selectedTeam = vm.match.homeTeam),
                selectedColor: Colors.pink,
              ),
              ChoiceChip(
                label: SizedBox(
                  width: 120,
                  child: Text(
                    '${vm.match.awayTeam} (${vm.oddsB.toStringAsFixed(2)})',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                selected: selectedTeam == vm.match.awayTeam,
                onSelected: (selected) => setState(() => selectedTeam = vm.match.awayTeam),
                selectedColor: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15)),
            onPressed: selectedTeam == null ? null : _confirmBet,
            child: const Text('Submit', style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
        ],
      ),
    );
  }
}
