import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firebase_service.dart';
import '../models/player_state.dart';
import '../services/location_service.dart';
import '../models/location_model.dart';
import '../services/audio_service.dart';

class GameScreenPracaCentral extends StatefulWidget {
  @override
  _GameScreenPracaCentralState createState() => _GameScreenPracaCentralState();
}

class _GameScreenPracaCentralState extends State<GameScreenPracaCentral> {
  int _dialogueIndex = 0;
  bool _bloqueado = false;
  bool _showChoices = false;
  bool _typing = false;
  bool _showAvancar = false;
  bool _fimDeJogo = false;
  String _displayedText = '';
  String _fullText = '';
  String _speaker = '';

  final List<Map<String, String>> _dialogues = [
    {'speaker': 'NARRADOR', 'text': 'A praça está quieta. O sol já está baixo entre as árvores.'},
    {'speaker': 'NARRADOR', 'text': 'Nos bancos ao centro, uma figura aguarda. Era quem você procurava o tempo todo.'},
    {'speaker': 'MISTERIOSO', 'text': 'Eu sabia que você viria. Você seguiu todas as pistas.'},
    {'speaker': 'MISTERIOSO', 'text': 'Tenho algo para te mostrar. Algo que vai mudar tudo o que você sabe sobre este campus.'},
  ];

  TextStyle get _rpgStyle => GoogleFonts.pressStart2p(fontSize: 11, color: const Color(0xFFE0E0E0), height: 2.0);
  TextStyle get _rpgStyleYellow => GoogleFonts.pressStart2p(fontSize: 9, color: const Color(0xFFF8F800), letterSpacing: 1);
  TextStyle get _rpgStyleSmall => GoogleFonts.pressStart2p(fontSize: 8, color: const Color(0xFF505080), letterSpacing: 2);

  @override
  void initState() {
    super.initState();
    AudioService.tocar('fim_de_jogo.mp3');
    _verificarLocalizacao();
  }

  void _verificarLocalizacao() async {
    GameLocation? ambienteAtual = await LocationService.getAmbienteAtual();

    if (ambienteAtual?.id != 'praca_central') {
      setState(() {
        _bloqueado = true;
        _speaker = 'NARRADOR';
        _fullText = 'Você precisa estar na Praça Central para o desfecho da investigação. Dirija-se até lá.';
        _displayedText = _fullText;
        _typing = false;
      });
    } else {
      AudioService.tocar('praca_central.mp3');
      _startDialogue(0);
    }
  }

  void _startDialogue(int index) {
    setState(() {
      _dialogueIndex = index;
      _speaker = _dialogues[index]['speaker']!;
      _fullText = _dialogues[index]['text']!;
      _displayedText = '';
      _typing = true;
      _showChoices = false;
      _showAvancar = false;
    });
    _typeText();
  }

  void _typeText() async {
    for (int i = 0; i < _fullText.length; i++) {
      await Future.delayed(const Duration(milliseconds: 35));
      if (!mounted) return;
      setState(() => _displayedText = _fullText.substring(0, i + 1));
    }
    if (!mounted) return;
    setState(() {
      _typing = false;
      if (_dialogueIndex >= _dialogues.length - 1) _showChoices = true;
    });
  }

  void _onTapDialogue() {
    if (_typing) {
      setState(() {
        _typing = false;
        _displayedText = _fullText;
        if (_dialogueIndex >= _dialogues.length - 1) _showChoices = true;
      });
    } else if (_dialogueIndex < _dialogues.length - 1 && !_showChoices) {
      _startDialogue(_dialogueIndex + 1);
    }
  }

  void _escolher(int opcao) async {
    final respostas = [
      {'speaker': 'NARRADOR', 'text': 'Você aceita o envelope com cuidado. Dentro, documentos com nomes, datas e provas do que aconteceu. O mistério do campus foi finalmente desvendado.'},
      {'speaker': 'MISTERIOSO', 'text': 'Como quiser. Tudo começou há três meses, quando descobri que alguém estava usando os laboratórios para monitorar alunos e professores sem autorização. Eu precisava de ajuda para expor isso.'},
    ];

    setState(() {
      _showChoices = false;
      _speaker = respostas[opcao]['speaker']!;
      _fullText = respostas[opcao]['text']!;
      _displayedText = '';
      _typing = true;
      _fimDeJogo = false;
    });

    // digita o texto letra por letra
    for (int i = 0; i < _fullText.length; i++) {
      await Future.delayed(const Duration(milliseconds: 35));
      if (!mounted) return;
      setState(() => _displayedText = _fullText.substring(0, i + 1));
    }
    if (!mounted) return;
    setState(() => _typing = false);

    // salva no Firebase
    if (PlayerState.jogadorId != null) {
      await FirebaseService.registrarInteracao(
        jogadorId: PlayerState.jogadorId!,
        ambiente: 'praca_central',
        escolha: opcao == 0 ? 'aceitou_envelope' : 'exigiu_respostas',
      );
      await FirebaseService.salvarProgresso(
        jogadorId: PlayerState.jogadorId!,
        ambienteAtual: 'praca_central',
        ambientesDesbloqueados: PlayerState.ambientesDesbloqueados,
      );
    }

    // espera o jogador ler por 5 segundos antes de mostrar fim de jogo
    await Future.delayed(const Duration(seconds: 5));
    if (!mounted) return;

    setState(() {
      _fimDeJogo = true;
      _speaker = 'NARRADOR';
      _fullText = 'Parabéns! Você percorreu todo o campus e desvendou o Mistério no Campus!';
      _displayedText = _fullText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: SafeArea(
        child: Column(
          children: [
            if (_bloqueado)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                color: const Color(0xFF1A0000),
                child: Text(
                  '📍 FORA DO RAIO — PRAÇA CENTRAL',
                  style: GoogleFonts.pressStart2p(fontSize: 8, color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
              ),
            // BARRA
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('◆ PRAÇA CENTRAL ◆', style: _rpgStyleYellow),
                  Text('▶ ENTARDECER',
                      style: GoogleFonts.pressStart2p(fontSize: 9, color: const Color(0xFFFFAA00))),
                ],
              ),
            ),

            // CENA
            Container(
              height: screenHeight * 0.38,
              width: double.infinity,
              child: Stack(
                children: [
                  // CÉU GRADIENTE
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF1A0A2E), Color(0xFF2E1A0A), Color(0xFF0A1A0A)],
                        ),
                      ),
                    ),
                  ),

                  // ÁRVORES
                  Positioned(bottom: 40, left: 8, child: _buildArvore(90)),
                  Positioned(bottom: 40, left: 55, child: _buildArvore(65)),
                  Positioned(bottom: 40, right: 8, child: _buildArvore(90)),
                  Positioned(bottom: 40, right: 55, child: _buildArvore(65)),

                  // BANCO
                  Positioned(
                    bottom: 50, left: 0, right: 0,
                    child: Center(child: _buildBanco()),
                  ),

                  // PERSONAGEM
                  Positioned(
                    bottom: 50, left: 0, right: 0,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 40),
                        child: _buildMisterioso(),
                      ),
                    ),
                  ),

                  // PISO
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      height: 40,
                      color: const Color(0xFF0A1A0A),
                      foregroundDecoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: Color(0xFF1A3A1A), width: 3)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // DIÁLOGO
            Expanded(
              child: GestureDetector(
                onTap: _onTapDialogue,
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFF000010),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF000050),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Text(_speaker, style: _rpgStyleYellow),
                      ),
                      const SizedBox(height: 12),
                      Text(_displayedText, style: _rpgStyle),
                      if (!_typing && !_showChoices && !_fimDeJogo)
                        const Align(
                          alignment: Alignment.bottomRight,
                          child: Text('▼', style: TextStyle(color: Colors.white, fontSize: 14)),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // ESCOLHAS
            if (_showChoices)
              Container(
                color: const Color(0xFF000018),
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Text('— ESCOLHA —', style: _rpgStyleSmall),
                    const SizedBox(height: 8),
                    ...List.generate(2, (i) {
                      final opcoes = ['ACEITAR O ENVELOPE', 'EXIGIR RESPOSTAS DIRETAMENTE'];
                      return GestureDetector(
                        onTap: () => _escolher(i),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF000018),
                            border: Border.all(color: const Color(0xFF303060), width: 2),
                          ),
                          child: Row(
                            children: [
                              Text('► ', style: _rpgStyleYellow),
                              Expanded(child: Text(opcoes[i],
                                  style: GoogleFonts.pressStart2p(fontSize: 9, color: const Color(0xFFA0A0C0)))),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

            // FIM DE JOGO
            if (_fimDeJogo)
              GestureDetector(
                onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  color: const Color(0xFF001400),
                  child: Center(
                    child: Text('★ VOLTAR AO INÍCIO ★',
                        style: GoogleFonts.pressStart2p(
                            fontSize: 11,
                            color: const Color(0xFFF8F800),
                            letterSpacing: 2)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildArvore(double altura) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: altura * 0.7,
          decoration: BoxDecoration(
            color: const Color(0xFF1A4A1A),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
        ),
        Container(width: 8, height: altura * 0.3, color: const Color(0xFF5D3A1A)),
      ],
    );
  }

  Widget _buildBanco() {
    return Column(
      children: [
        Container(width: 55, height: 7, color: const Color(0xFF8B6914),
            foregroundDecoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFAA8930), width: 2)))),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 6, height: 16, color: const Color(0xFF6B4A10)),
            const SizedBox(width: 35),
            Container(width: 6, height: 16, color: const Color(0xFF6B4A10)),
          ],
        ),
      ],
    );
  }

  Widget _buildMisterioso() {
    return Column(
      children: [
        Container(
          width: 22, height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF8A7060),
            border: Border.all(color: const Color(0xFF6A5040), width: 2),
          ),
          child: Stack(children: [
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(height: 5, color: const Color(0xFF2A2A2A)),
            ),
          ]),
        ),
        Container(width: 24, height: 22, color: const Color(0xFF2A2A2A)),
        Container(width: 24, height: 14, color: const Color(0xFF1A1A1A)),
      ],
    );
  }
}