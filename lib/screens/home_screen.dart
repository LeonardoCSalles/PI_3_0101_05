import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/player_state.dart';
import 'game_screen.dart';
import 'cadastro_screen.dart';


class HomeScreen extends StatelessWidget {
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

          // ESCURECER A IMAGEM
          Container(
            color: Colors.black.withOpacity(0.6),
          ),

          // CONTEÚDO
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Mistério no Campus',
                  style: TextStyle(
                    fontFamily: 'RPG',  
                    fontSize: 36,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 40),

                // BOTÃO ESTILIZADO
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white, width: 2),
                    padding: EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (PlayerState.temJogador) {
                      // jogador já existe, carrega o progresso
                      var progresso = await FirebaseService.carregarProgresso(
                        PlayerState.jogadorId!,
                      );
                      if (progresso != null) {
                        PlayerState.ambientesDesbloqueados =
                            List<String>.from(progresso['ambientesDesbloqueados']);
                        PlayerState.ambienteAtual = progresso['ambienteAtual'];
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GameScreen()),
                      );
                    } else {
                      // primeira vez, vai para o cadastro
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CadastroScreen()),
                      );
                    }
                  },
                  child: Text(
                    'INICIAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}