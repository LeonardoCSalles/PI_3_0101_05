import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'game_screen_cantina.dart';
import '../services/firebase_service.dart';
import '../models/player_state.dart';
import '../services/location_service.dart';
import '../models/location_model.dart';
import '../services/audio_service.dart';

class GameScreenBiblioteca extends StatefulWidget {
  @override
  _GameScreenBibliotecaState createState() => _GameScreenBibliotecaState();
}

class _GameScreenBibliotecaState extends State<GameScreenBiblioteca> {
  int _dialogueIndex = 0;
  bool _bloqueado = false;
  bool _showChoices = false;
  bool _typing = false;
  bool _showAvancar = false;
  String _displayedText = '';
  String _fullText = '';
  String _speaker = 'NARRADOR';

  final List<Map<String, String>> _dialogues = [
    {'speaker': 'NARRADOR', 'text': 'O silêncio da biblioteca é absoluto. Apenas o som de páginas ao longe...'},
    {'speaker': 'NARRADOR', 'text': 'Entre as estantes, algo chama sua atenção: um caderno aberto sobre uma mesa.'},
    {'speaker': 'PROFESSOR', 'text': 'Psst! Você aí. Finalmente alguém apareceu.'},
    {'speaker': 'PROFESSOR', 'text': 'Eu deixei um bilhete nessa mesa. Precisamos conversar sobre o que está acontecendo no campus.'},
  ];

  TextStyle get _rpgStyle => GoogleFonts.pressStart2p(
    fontSize: 11,
    color: const Color(0xFFE0E0E0),
    height: 2.0,
  );

  TextStyle get _rpgStyleYellow => GoogleFonts.pressStart2p(
    fontSize: 9,
    color: const Color(0xFFF8F800),
    letterSpacing: 1,
  );

  TextStyle get _rpgStyleSmall => GoogleFonts.pressStart2p(
    fontSize: 8,
    color: const Color(0xFF505080),
    letterSpacing: 2,
  );

  @override
  void initState() {
    super.initState();
    AudioService.tocar('biblioteca.mp3');
    _verificarLocalizacao();
  }

  void _verificarLocalizacao() async {
    
      // modo desenvolvedor — pula verificação
  if (LocationService.modoDesenvolvedor) {
    _startDialogue(0);
    return;
  }

     setState(() {
    _speaker = '...';
    _fullText = 'Verificando localização...';
    _displayedText = 'Verificando localização...';
  });

    GameLocation? ambienteAtual = await LocationService.getAmbienteAtual();

    if (ambienteAtual?.id != 'biblioteca') {
      setState(() {
        _bloqueado = true;
        _speaker = 'NARRADOR';
        _fullText = 'Você precisa estar na Biblioteca para continuar a investigação. Dirija-se até lá.';
        _displayedText = _fullText;
        _typing = false;
      });
    } else {
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
      {'speaker': 'NARRADOR', 'text': 'Você pega o bilhete. "Se algo acontecer comigo, me procure na cantina." A tinta ainda fresca.'},
      {'speaker': 'NARRADOR', 'text': 'Você vasculha as estantes... nada além de livros antigos e poeira.'},
      {'speaker': 'PROFESSOR', 'text': 'Espere! Não vá ainda. Isso é importante para todos nós aqui no campus.'},
    ];

    setState(() {
      _showChoices = false;
      _speaker = respostas[opcao]['speaker']!;
      _fullText = respostas[opcao]['text']!;
      _displayedText = '';
      _typing = true;
      _showAvancar = false;
    });
    _typeText();

    if (opcao == 0) {
      if (PlayerState.jogadorId != null) {
        await FirebaseService.desbloquearAmbiente(
          jogadorId: PlayerState.jogadorId!,
          ambienteId: 'cantina',
        );
        await FirebaseService.registrarInteracao(
          jogadorId: PlayerState.jogadorId!,
          ambiente: 'biblioteca',
          escolha: 'leu_bilhete',
        );
      }
      // Espera o texto terminar de digitar
      await Future.delayed(Duration(milliseconds: 35 * respostas[0]['text']!.length + 500));
      if (!mounted) return;
      setState(() => _showAvancar = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: SafeArea(
        child: Column(
          children: [
            // coloca isso dentro do Column, antes da barra de localização
            if (_bloqueado)
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    color: const Color(0xFF1A0000),
                    child: Text(
                      '📍 FORA DO RAIO — BIBLIOTECA',
                      style: GoogleFonts.pressStart2p(fontSize: 8, color: Colors.redAccent),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() => _bloqueado = false);
                      _verificarLocalizacao();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      color: const Color(0xFF001A00),
                      child: Center(
                        child: Text(
                          '🔄 VERIFICAR LOCALIZAÇÃO',
                          style: GoogleFonts.pressStart2p(fontSize: 8, color: Colors.greenAccent),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            // BARRA DE LOCALIZAÇÃO
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('◆ BIBLIOTECA ◆', style: _rpgStyleYellow),
                  Text('▶ NOITE',
                      style: GoogleFonts.pressStart2p(
                          fontSize: 9, color: const Color(0xFF00E400))),
                ],
              ),
            ),

            // CENA
            Container(
              height: screenHeight * 0.38,
              width: double.infinity,
              color: const Color(0xFF1A0E2E),
              child: Stack(
                children: [
                  // JANELA
                  Positioned(
                    top: 20, left: 0, right: 0,
                    child: Center(
                      child: Container(
                        width: 90, height: 65,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A3A6E),
                          border: Border.all(color: const Color(0xFF6A5A8E), width: 3),
                        ),
                        child: GridView.count(
                          crossAxisCount: 2,
                          padding: const EdgeInsets.all(5),
                          mainAxisSpacing: 3,
                          crossAxisSpacing: 3,
                          physics: const NeverScrollableScrollPhysics(),
                          children: List.generate(4, (_) =>
                              Container(color: const Color(0x4D64B4FF))),
                        ),
                      ),
                    ),
                  ),

                  // ESTANTE ESQUERDA
                  Positioned(left: 0, bottom: 40, child: _buildShelf()),

                  // ESTANTE DIREITA
                  Positioned(right: 0, bottom: 40, child: _buildShelf()),

                  // PISO
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      height: 40,
                      color: const Color(0xFF2D1F0E),
                      foregroundDecoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: Color(0xFF4D3F2E), width: 3)),
                      ),
                    ),
                  ),

                  // MESA
                  Positioned(
                    bottom: 40, left: 0, right: 0,
                    child: Center(
                      child: Container(
                        width: 110, height: 22,
                        color: const Color(0xFF5D3A1A),
                        foregroundDecoration: const BoxDecoration(
                          border: Border(top: BorderSide(color: Color(0xFF7D5A3A), width: 3)),
                        ),
                      ),
                    ),
                  ),

                  // VELA
                  Positioned(
                    bottom: 62, left: 0, right: 0,
                    child: Center(
                      child: Container(width: 8, height: 16, color: const Color(0xFFE8D060)),
                    ),
                  ),

                  // PROFESSOR
                  Positioned(bottom: 40, right: 80, child: _buildProfessor()),
                ],
              ),
            ),

            // CAIXA DE DIÁLOGO
            Expanded(
              child: GestureDetector(
                onTap: _bloqueado ? null : _onTapDialogue,
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
                      if (!_typing && !_showChoices && !_showAvancar)
                        const Align(
                          alignment: Alignment.bottomRight,
                          child: Text('▼',
                              style: TextStyle(color: Colors.white, fontSize: 14)),
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
                    ...List.generate(3, (i) {
                      final opcoes = [
                        'LER O BILHETE MISTERIOSO',
                        'EXPLORAR AS ESTANTES',
                        'IGNORAR E CONTINUAR',
                      ];
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
                                  style: GoogleFonts.pressStart2p(
                                      fontSize: 9, color: const Color(0xFFA0A0C0)))),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

            // BOTÃO AVANÇAR — aparece após ler o bilhete
            if (_showAvancar)
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => GameScreenCantina()),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  color: const Color(0xFF000030),
                  child: Center(
                    child: Text('► IR ATÉ A CANTINA',
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

  Widget _buildShelf() {
    final colors = [
      const Color(0xFF8B1A1A),
      const Color(0xFF1A4A8B),
      const Color(0xFF2D8B1A),
      const Color(0xFF8B6B1A),
      const Color(0xFF6B1A8B),
    ];
    return Container(
      width: 64,
      height: 90,
      color: const Color(0xFF3D2B1A),
      child: Column(
        children: [
          Container(
            height: 44,
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF5D4B2A), width: 2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: colors.map((c) => Container(
                width: 11,
                height: 24.0 + (colors.indexOf(c) % 3) * 7,
                color: c,
                margin: const EdgeInsets.only(right: 1),
              )).toList(),
            ),
          ),
          Container(
            height: 44,
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF5D4B2A), width: 2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: colors.reversed.map((c) => Container(
                width: 11,
                height: 20.0 + (colors.indexOf(c) % 3) * 6,
                color: c,
                margin: const EdgeInsets.only(right: 1),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessor() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28, height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFFD4956A),
            border: Border.all(color: const Color(0xFFA06040), width: 2),
          ),
          child: Stack(children: [
            Positioned(top: 0, left: 0, right: 0,
                child: Container(height: 7, color: const Color(0xFF3A2010))),
            Positioned(top: 7, left: 3, right: 3,
                child: Row(children: [
                  Expanded(child: Container(height: 5, color: const Color(0x6664B4FF))),
                  const SizedBox(width: 2),
                  Expanded(child: Container(height: 5, color: const Color(0x6664B4FF))),
                ])),
          ]),
        ),
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFF2A3A6A),
            border: Border.all(color: const Color(0xFF1A2A5A), width: 2),
          ),
          child: Center(child: Container(width: 6, height: 18, color: const Color(0xFFAA2020))),
        ),
        Container(width: 30, height: 18, color: const Color(0xFF1A1A2A)),
      ],
    );
  }
}