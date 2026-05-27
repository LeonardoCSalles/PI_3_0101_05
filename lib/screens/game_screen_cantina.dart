import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'game_screen_laboratorio.dart';
import '../services/firebase_service.dart';
import '../models/player_state.dart';
import '../services/location_service.dart';
import '../models/location_model.dart';
import '../services/audio_service.dart';

class GameScreenCantina extends StatefulWidget {
  @override
  _GameScreenCantinaState createState() => _GameScreenCantinaState();
}

class _GameScreenCantinaState extends State<GameScreenCantina> {
  int _dialogueIndex = 0;
  bool _bloqueado = false;
  bool _showChoices = false;
  bool _typing = false;
  bool _showAvancar = false;
  String _displayedText = '';
  String _fullText = '';
  String _speaker = '';

  final List<Map<String, String>> _dialogues = [
    {'speaker': 'NARRADOR', 'text': 'A cantina está quase vazia para essa hora do dia...'},
    {'speaker': 'NARRADOR', 'text': 'Bandejas abandonadas. Um copo virado. No canto, um funcionário limpa o balcão sem te olhar nos olhos.'},
    {'speaker': 'FUNCIONÁRIO', 'text': 'Ei, você... Eu vi algo sim. Mas prefiro não me meter nisso.'},
    {'speaker': 'FUNCIONÁRIO', 'text': 'Olha ali embaixo daquela mesa. Tem uma mochila esquecida desde ontem.'},
  ];

  TextStyle get _rpgStyle => GoogleFonts.pressStart2p(fontSize: 11, color: const Color(0xFFE0E0E0), height: 2.0);
  TextStyle get _rpgStyleYellow => GoogleFonts.pressStart2p(fontSize: 9, color: const Color(0xFFF8F800), letterSpacing: 1);
  TextStyle get _rpgStyleSmall => GoogleFonts.pressStart2p(fontSize: 8, color: const Color(0xFF505080), letterSpacing: 2);

  @override
  void initState() {
    super.initState();
    AudioService.tocar('cantina.mp3');
    _verificarLocalizacao();
  }

  void _verificarLocalizacao() async {
    GameLocation? ambienteAtual = await LocationService.getAmbienteAtual();

    if (ambienteAtual?.id != 'cantina') {
      setState(() {
        _bloqueado = true;
        _speaker = 'NARRADOR';
        _fullText = 'Você precisa estar na Cantina para continuar a investigação. Dirija-se até lá.';
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
      {'speaker': 'NARRADOR', 'text': 'Dentro da mochila você encontra um crachá universitário. O nome no crachá é o mesmo do bilhete que encontrou na biblioteca. A investigação está ficando séria.'},
      {'speaker': 'FUNCIONÁRIO', 'text': 'Olha... eu vi uma pessoa saindo às pressas daqui ontem à noite. Carregava uma mochila e parecia nervosa. Não sei mais nada, juro.'},
      {'speaker': 'NARRADOR', 'text': 'Você vira as costas, mas seus olhos ficam presos naquela mochila embaixo da mesa. Algo ali precisa ser investigado.'},
    ];

    setState(() {
      _showChoices = false;
      _speaker = respostas[opcao]['speaker']!;
      _fullText = respostas[opcao]['text']!;
      _displayedText = '';
      _typing = true;
      _showAvancar = false;
    });

    // digita o texto primeiro
    for (int i = 0; i < _fullText.length; i++) {
      await Future.delayed(const Duration(milliseconds: 35));
      if (!mounted) return;
      setState(() => _displayedText = _fullText.substring(0, i + 1));
    }
    if (!mounted) return;
    setState(() => _typing = false);

    if (opcao == 0) {
      // espera o jogador ler por 4 segundos antes de mostrar botão
      await Future.delayed(const Duration(seconds: 4));
      if (!mounted) return;
      if (PlayerState.jogadorId != null) {
        await FirebaseService.desbloquearAmbiente(
          jogadorId: PlayerState.jogadorId!,
          ambienteId: 'laboratorio',
        );
        await FirebaseService.registrarInteracao(
          jogadorId: PlayerState.jogadorId!,
          ambiente: 'cantina',
          escolha: 'examinou_mochila',
        );
      }
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
            if (_bloqueado)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                color: const Color(0xFF1A0000),
                child: Text(
                  '📍 FORA DO RAIO — CANTINA',
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
                  Text('◆ CANTINA ◆', style: _rpgStyleYellow),
                  Text('▶ TARDE', style: GoogleFonts.pressStart2p(fontSize: 9, color: const Color(0xFF00E400))),
                ],
              ),
            ),

            // CENA
            Container(
              height: screenHeight * 0.38,
              width: double.infinity,
              color: const Color(0xFF1A1208),
              child: Stack(
                children: [
                  // BALCÕES
                  Positioned(
                    top: 8, left: 0, right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildBalcao('SALGADOS', const Color(0xFF8B4513), '🥐'),
                        _buildBalcao('LANCHES', const Color(0xFF6B3410), '🍔'),
                        _buildBalcao('BEBIDAS', const Color(0xFF5B2808), '🥤'),
                      ],
                    ),
                  ),

                  // PISO
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      height: 40,
                      color: const Color(0xFF2A1F0E),
                      foregroundDecoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: Color(0xFF4A3F2E), width: 3)),
                      ),
                    ),
                  ),

                  // MESAS
                  Positioned(bottom: 40, left: 30, child: _buildMesa()),
                  Positioned(bottom: 40, left: 130, child: _buildMesa()),
                  Positioned(bottom: 40, right: 30, child: _buildMesa()),

                  // FUNCIONÁRIO
                  Positioned(top: 80, right: 30, child: _buildFuncionario()),

                  // MOCHILA
                  Positioned(bottom: 44, left: 80, child: _buildMochila()),
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
                      if (!_typing && !_showChoices && !_showAvancar)
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
                    ...List.generate(3, (i) {
                      final opcoes = ['EXAMINAR A MOCHILA', 'FALAR COM O FUNCIONÁRIO', 'IGNORAR E PROCURAR PISTAS'];
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

            // BOTÃO AVANÇAR
            if (_showAvancar)
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => GameScreenLaboratorio()),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  color: const Color(0xFF000030),
                  child: Center(
                    child: Text('► IR ATÉ O LABORATÓRIO',
                        style: GoogleFonts.pressStart2p(fontSize: 11, color: const Color(0xFFF8F800), letterSpacing: 2)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalcao(String label, Color color, String emoji) {
    return Container(
      width: 90,
      height: 70,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: color.withOpacity(0.5), width: 2),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Container(width: 70, height: 6, color: const Color(0xFFFFD700)),
          const SizedBox(height: 3),
          Container(width: 70, height: 6, color: const Color(0xFFFFD700).withOpacity(0.5)),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.pressStart2p(fontSize: 6, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildMesa() {
    return Column(
      children: [
        // TAMPO
        Container(width: 55, height: 8, color: const Color(0xFF8B6914),
            foregroundDecoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFAA8930), width: 2)))),
        // PERNAS
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(width: 6, height: 22, color: const Color(0xFF6B4A10)),
            Container(width: 6, height: 22, color: const Color(0xFF6B4A10)),
          ],
        ),
      ],
    );
  }

  Widget _buildFuncionario() {
    return Column(
      children: [
        Container(width: 22, height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFFD4956A),
              border: Border.all(color: const Color(0xFFA06040), width: 2),
            )),
        Container(width: 24, height: 22, color: const Color(0xFF2A5A2A)),
        Container(width: 24, height: 14, color: const Color(0xFF1A3A1A)),
      ],
    );
  }

  Widget _buildMochila() {
    return Container(
      width: 22, height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFF2A4A8B),
        border: Border.all(color: const Color(0xFF1A3A6B), width: 2),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Center(child: Container(width: 14, height: 10, color: const Color(0xFF1A3A6B))),
    );
  }
}