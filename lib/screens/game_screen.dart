import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:misterio_no_campus/services/permission_service.dart';
import 'package:misterio_no_campus/services/location_service.dart';
import 'package:misterio_no_campus/models/location_model.dart';
import '../services/firebase_service.dart';
import '../models/player_state.dart';
import 'game_screen_biblioteca.dart';
import '../services/audio_service.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _dialogueIndex = 0;
  bool _showChoices = false;
  bool _typing = false;
  bool _showAvancar = false;
  String _displayedText = '';
  String _fullText = '';
  String _speaker = '';
  String _latitude = '--';
  String _longitude = '--';

  final List<Map<String, String>> _dialogues = [
    {'speaker': 'NARRADOR', 'text': 'Você chega à entrada do campus. O movimento está menor do que o normal...'},
    {'speaker': 'NARRADOR', 'text': 'O ambiente parece estranho. Como se algo tivesse acontecido recentemente.'},
    {'speaker': 'SEGURANÇA', 'text': 'Ei, você aí. Está procurando alguém?'},
    {'speaker': 'SEGURANÇA', 'text': 'Hoje cedo encontramos algo estranho perto da biblioteca. Recomendo você dar uma olhada.'},
  ];

  TextStyle get _rpgStyle => GoogleFonts.pressStart2p(
        fontSize: 11, color: const Color(0xFFE0E0E0), height: 2.0);

  TextStyle get _rpgStyleYellow => GoogleFonts.pressStart2p(
        fontSize: 9, color: const Color(0xFFF8F800), letterSpacing: 1);

  TextStyle get _rpgStyleSmall => GoogleFonts.pressStart2p(
        fontSize: 8, color: const Color(0xFF505080), letterSpacing: 2);

  @override
  void initState() {
    super.initState();
    _iniciarJogo();
  }

  void _iniciarJogo() async {
    bool temPermissao = await PermissionService.requestLocationPermission();

    if (!temPermissao) {
      setState(() {
        _speaker = 'SISTEMA';
        _fullText = 'Para jogar, você precisa permitir o acesso à localização.';
        _displayedText = _fullText;
        _showChoices = false;
      });
      return;
    }

    Position? posicao = await LocationService.getCurrentPosition();
    if (posicao != null) {
      setState(() {
        _latitude = posicao.latitude.toStringAsFixed(7);
        _longitude = posicao.longitude.toStringAsFixed(7);
      });
    }

    GameLocation? ambienteAtual = await LocationService.getAmbienteAtual();

    if (ambienteAtual?.id == 'portaria') {
      AudioService.tocar('portaria.mp3');
      _startDialogue(0);
    } else {
      setState(() {
        _speaker = 'SISTEMA';
        _fullText = 'Dirija-se até a entrada principal do campus para iniciar a investigação.';
        _displayedText = _fullText;
        _showChoices = false;
      });
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
      {'speaker': 'SEGURANÇA', 'text': 'Sim, perto da biblioteca. Um caderno aberto, um bilhete. Parecia urgente.'},
      {'speaker': 'NARRADOR', 'text': 'Você observa ao redor. As pessoas evitam se olhar. Algo definitivamente aconteceu aqui.'},
      {'speaker': 'NARRADOR', 'text': 'Você tenta ignorar, mas a sensação de que algo está errado não passa.'},
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
          ambienteId: 'biblioteca',
        );
        await FirebaseService.registrarInteracao(
          jogadorId: PlayerState.jogadorId!,
          ambiente: 'portaria',
          escolha: 'perguntou_seguranca',
        );
      }
      await Future.delayed(
          Duration(milliseconds: 35 * respostas[0]['text']!.length + 500));
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
            // BARRA DE LOCALIZAÇÃO
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('◆ PORTARIA ◆', style: _rpgStyleYellow),
                  Text('▶ DIA',
                      style: GoogleFonts.pressStart2p(
                          fontSize: 9, color: const Color(0xFF00E400))),
                ],
              ),
            ),

            // CENA
            Container(
              height: screenHeight * 0.38,
              width: double.infinity,
              color: const Color(0xFF0A1828),
              child: Stack(
                children: [
                  // CÉU
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF0A1828), Color(0xFF1A3A5A), Color(0xFF0A1828)],
                        ),
                      ),
                    ),
                  ),

                  // PORTÃO
                  Positioned(
                    top: 20, left: 0, right: 0,
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildPortaoLado(),
                          Container(
                            width: 80, height: 90,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A2A),
                              border: Border.all(color: const Color(0xFF8B6914), width: 3),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('PUC',
                                    style: GoogleFonts.pressStart2p(
                                        fontSize: 10, color: const Color(0xFF8B6914))),
                                Text('CAMPUS',
                                    style: GoogleFonts.pressStart2p(
                                        fontSize: 7, color: const Color(0xFF6B4914))),
                              ],
                            ),
                          ),
                          _buildPortaoLado(),
                        ],
                      ),
                    ),
                  ),

                  // PISO
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      height: 40,
                      color: const Color(0xFF2A2A2A),
                      foregroundDecoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: Color(0xFF4A4A4A), width: 3)),
                      ),
                    ),
                  ),

                  // SEGURANÇA
                  Positioned(bottom: 40, right: 60, child: _buildSeguranca()),

                  // COORDENADAS
                  Positioned(
                    bottom: 8, left: 12,
                    child: Row(
                      children: [
                        Text('LAT $_latitude  LNG $_longitude',
                            style: GoogleFonts.pressStart2p(
                                fontSize: 6, color: const Color(0xFF404060))),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // CAIXA DE DIÁLOGO
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
                        'PERGUNTAR SOBRE O OCORRIDO',
                        'OBSERVAR O AMBIENTE',
                        'IGNORAR E SEGUIR CAMINHO',
                      ];
                      return GestureDetector(
                        onTap: () => _escolher(i),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF000018),
                            border: Border.all(
                                color: const Color(0xFF303060), width: 2),
                          ),
                          child: Row(
                            children: [
                              Text('► ', style: _rpgStyleYellow),
                              Expanded(
                                child: Text(opcoes[i],
                                    style: GoogleFonts.pressStart2p(
                                        fontSize: 9,
                                        color: const Color(0xFFA0A0C0))),
                              ),
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
                  MaterialPageRoute(builder: (_) => GameScreenBiblioteca()),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  color: const Color(0xFF000030),
                  child: Center(
                    child: Text('► IR ATÉ A BIBLIOTECA',
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

  Widget _buildPortaoLado() {
    return Container(
      width: 20, height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3A),
        border: Border.all(color: const Color(0xFF8B6914), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(4, (_) =>
            Container(width: 8, height: 8, color: const Color(0xFF8B6914))),
      ),
    );
  }

  Widget _buildSeguranca() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26, height: 22,
          decoration: BoxDecoration(
            color: const Color(0xFFD4956A),
            border: Border.all(color: const Color(0xFFA06040), width: 2),
          ),
          child: Stack(children: [
            Positioned(top: 0, left: 0, right: 0,
                child: Container(height: 6, color: const Color(0xFF1A1A3A))),
          ]),
        ),
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A4A),
            border: Border.all(color: const Color(0xFF0A0A3A), width: 2),
          ),
          child: Center(
            child: Container(width: 10, height: 10,
                color: const Color(0xFFFFD700).withOpacity(0.8)),
          ),
        ),
        Container(width: 28, height: 16, color: const Color(0xFF0A0A2A)),
      ],
    );
  }
}