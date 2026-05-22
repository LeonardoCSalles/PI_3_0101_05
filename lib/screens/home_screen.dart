import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firebase_service.dart';
import '../models/player_state.dart';
import 'game_screen.dart';
import 'cadastro_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _carregando = false;

  void _iniciarNovo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CadastroScreen()),
    );
  }

  void _continuar() async {
    if (!PlayerState.temJogador) return;

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
    return Scaffold(
      body: Stack(
        children: [
          // IMAGEM DE FUNDO
          SizedBox.expand(
            child: Image.asset(
              'assets/images/bg.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // OVERLAY ESCURO
          Container(color: Colors.black.withOpacity(0.6)),

          // CONTEÚDO
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // TÍTULO
                Text(
                  'Mistério no Campus',
                  style: TextStyle(
                    fontFamily: 'RPG',
                    fontSize: 36,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // SUBTÍTULO
                Text(
                  'Um RPG no Campus da PUC-Campinas',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 9,
                    color: Colors.white38,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 60),

                // CARREGANDO
                if (_carregando)
                  const CircularProgressIndicator(color: Colors.white38)
                else ...[

                  // BOTÃO INICIAR (novo jogo)
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white, width: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 60,
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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

                  const SizedBox(height: 16),

                  // BOTÃO CONTINUAR (só aparece se tem jogador salvo)
                  if (PlayerState.temJogador)
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white38, width: 2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 60,
                          vertical: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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