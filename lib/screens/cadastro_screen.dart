import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  String _erro = '';

  void _iniciarJogo() async {
    final nome = _nomeController.text.trim();

    if (nome.isEmpty) {
      setState(() => _erro = 'Digite seu nome para continuar.');
      return;
    }

    if (nome.length < 2) {
      setState(() => _erro = 'Nome muito curto.');
      return;
    }

    setState(() {
      _carregando = true;
      _erro = '';
    });

    try {
      String jogadorId = await FirebaseService.criarJogador(nome);

      await FirebaseService.salvarProgresso(
        jogadorId: jogadorId,
        ambienteAtual: 'portaria',
        ambientesDesbloqueados: ['portaria'],
      );

      PlayerState.jogadorId = jogadorId;
      PlayerState.nomeJogador = nome;
      PlayerState.ambientesDesbloqueados = ['portaria'];
      PlayerState.ambienteAtual = 'portaria';

      setState(() => _carregando = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GameScreen()),
      );
    } catch (e) {
      setState(() {
        _carregando = false;
        _erro = 'Erro ao criar jogador. Tente novamente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // FUNDO
          SizedBox.expand(
            child: Image.asset(
              'assets/images/bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Container(color: Colors.black.withOpacity(0.75)),

          // CONTEÚDO
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mistério no Campus',
                    style: const TextStyle(
                      fontFamily: 'RPG',
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Nova Investigação',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 10,
                      color: Colors.white38,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Text(
                    'Como devo te chamar,\ninvestigador?',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 11,
                      color: Colors.white70,
                      height: 2,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // CAMPO NOME
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _nomeController,
                      style: GoogleFonts.pressStart2p(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                      maxLength: 20,
                      decoration: InputDecoration(
                        hintText: 'Seu nome...',
                        hintStyle: GoogleFonts.pressStart2p(
                          color: Colors.white24,
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                        counterStyle: const TextStyle(color: Colors.white24),
                      ),
                      onSubmitted: (_) => _iniciarJogo(),
                    ),
                  ),

                  // ERRO
                  if (_erro.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _erro,
                        style: GoogleFonts.pressStart2p(
                          fontSize: 8,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),

                  const SizedBox(height: 32),

                  // BOTÃO COMEÇAR
                  _carregando
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white38),
                        )
                      : SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _iniciarJogo,
                            child: Text(
                              'COMEÇAR INVESTIGAÇÃO',
                              style: GoogleFonts.pressStart2p(
                                color: Colors.white,
                                fontSize: 11,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),

                  const SizedBox(height: 16),

                  // BOTÃO VOLTAR
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'VOLTAR',
                        style: GoogleFonts.pressStart2p(
                          color: Colors.white38,
                          fontSize: 10,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}