import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/player_state.dart';
import 'game_screen.dart';

class CadastroScreen extends StatefulWidget {
  @override
  _CadastroScreenState createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final TextEditingController _nomeController = TextEditingController();
  bool _carregando = false;

  void _iniciarJogo() async {
    if (_nomeController.text.trim().isEmpty) return;

    setState(() => _carregando = true);

    // Cria o jogador no Firebase
    String jogadorId = await FirebaseService.criarJogador(
      _nomeController.text.trim(),
    );

    // Salva progresso inicial
    await FirebaseService.salvarProgresso(
      jogadorId: jogadorId,
      ambienteAtual: 'portaria',
      ambientesDesbloqueados: ['portaria'],
    );

    // Guarda o estado local
    PlayerState.jogadorId = jogadorId;
    PlayerState.nomeJogador = _nomeController.text.trim();

    setState(() => _carregando = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => GameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mistério no Campus',
              style: TextStyle(
                fontFamily: 'RPG',
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Como devo te chamar, investigador?',
              style: TextStyle(
                fontFamily: 'RPG',
                fontSize: 13,
                color: Colors.white54,
              ),
            ),
            SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _nomeController,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'RPG',
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Digite seu nome...',
                  hintStyle: TextStyle(color: Colors.white24),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            SizedBox(height: 24),
            _carregando
                ? Center(
                    child: CircularProgressIndicator(color: Colors.white38),
                  )
                : OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white38),
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _iniciarJogo,
                    child: Text(
                      'COMEÇAR INVESTIGAÇÃO',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'RPG',
                        fontSize: 13,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}