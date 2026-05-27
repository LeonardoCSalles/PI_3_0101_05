import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firebase_service.dart';
import '../models/player_state.dart';
import 'game_screen.dart';
import 'cadastro_screen.dart';
import '../services/audio_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _carregando = false;

  void _iniciarNovo() {
    AudioService.tocar('titulo.mp3');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CadastroScreen()),
    );
  }

  void _continuar() async {
    if (!PlayerState.temJogador) return;

    AudioService.tocar('titulo.mp3');
    setState(() => _carregando = true);

    var progresso = await FirebaseService.carregarProgresso(
      PlayerState.jogadorId!,
    );

    if (progresso != null) {
      PlayerState.ambientesDesbloqueados =
          List<String>.from(progresso['ambientesDesbloqueados']);
      PlayerState.ambienteAtual = progresso['ambienteAtual'];
    }

    setState(() => _carregando = false);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // IMAGEM DE FUNDO — sem overlay para mostrar a beleza da imagem
          SizedBox.expand(
            child: Image.asset(
              'assets/images/bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // BOTÕES — posicionados na parte de baixo da tela
          Positioned(
            bottom: screenHeight * 0.18,
            left: 0,
            right: 40,
            child: Column(
              children: [
                if (_carregando)
                  const CircularProgressIndicator(color: Colors.white)
                else ...[

                  // BOTÃO INICIAR
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white, width: 2),
                      backgroundColor: Colors.black.withOpacity(0.4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 60,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _iniciarNovo,
                    child: Text(
                      'INICIAR',
                      style: GoogleFonts.pressStart2p(
                        color: Colors.white,
                        fontSize: 14,
                        letterSpacing: 2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // BOTÃO CONTINUAR
                  if (PlayerState.temJogador)
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white38, width: 2),
                        backgroundColor: Colors.black.withOpacity(0.4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 60,
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _continuar,
                      child: Text(
                        'CONTINUAR',
                        style: GoogleFonts.pressStart2p(
                          color: Colors.white54,
                          fontSize: 14,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}