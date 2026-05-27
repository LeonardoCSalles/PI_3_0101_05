import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'game_screen_praca_central.dart';
import '../services/firebase_service.dart';
import '../models/player_state.dart';
import '../services/location_service.dart';
import '../models/location_model.dart';
import '../services/audio_service.dart';

class GameScreenLaboratorio extends StatefulWidget {
  @override
  _GameScreenLaboratorioState createState() => _GameScreenLaboratorioState();
}

class _GameScreenLaboratorioState extends State<GameScreenLaboratorio> {
  int _dialogueIndex = 0;
  bool _bloqueado = false;
  bool _showChoices = false;
  bool _typing = false;
  bool _showAvancar = false;
  String _displayedText = '';
  String _fullText = '';
  String _speaker = '';

  final List<Map<String, String>> _dialogues = [
    {'speaker': 'NARRADOR', 'text': 'O laboratório está escuro. Apenas um monitor ligado no canto ilumina a sala.'},
    {'speaker': 'NARRADOR', 'text': 'As câmeras estão cobertas com fita preta. Alguém planejou isso com cuidado.'},
    {'speaker': 'ALUNO', 'text': 'Você também veio verificar? Eu encontrei algo muito estranho nesse computador...'},
    {'speaker': 'ALUNO', 'text': 'São registros de acessos e coordenadas. Alguém estava rastreando pessoas dentro do campus.'},
  ];

  TextStyle get _rpgStyle => GoogleFonts.pressStart2p(fontSize: 11, color: const Color(0xFFE0E0E0), height: 2.0);
  TextStyle get _rpgStyleYellow => GoogleFonts.pressStart2p(fontSize: 9, color: const Color(0xFFF8F800), letterSpacing: 1);
  TextStyle get _rpgStyleSmall => GoogleFonts.pressStart2p(fontSize: 8, color: const Color(0xFF505080), letterSpacing: 2);

  @override
  void initState() {
    super.initState();
    AudioService.tocar('laboratorio.mp3');
    _verificarLocalizacao();
  }

  void _verificarLocalizacao() async {
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

    if (ambienteAtual?.id != 'laboratorio') {
      setState(() {
        _bloqueado = true;
        _speaker = 'SISTEMA';
        _fullText = 'Você precisa estar no Laboratório para continuar a investigação. Dirija-se até lá.';
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
    {'speaker': 'NARRADOR', 'text': 'Na tela você lê: "Encontro confirmado. Praça Central. 18h00. Venha sozinho." Era isso que estavam escondendo o tempo todo.'},
    {'speaker': 'ALUNO', 'text': 'Eu cheguei aqui por acaso e vi a tela aberta. Os registros mostram horários e nomes de professores. Alguém dentro do campus está por trás de tudo isso.'},
    {'speaker': 'NARRADOR', 'text': 'Você se aproxima das câmeras cobertas. A fita preta está bem fixada. Quem fez isso não queria deixar rastros. Mas já deixou pistas suficientes.'},
  ];

  setState(() {
    _showChoices = false;
    _speaker = respostas[opcao]['speaker']!;
    _fullText = respostas[opcao]['text']!;
    _displayedText = '';
    _typing = true;
    _showAvancar = false;
  });
  _typeText(); // igual à biblioteca — chama _typeText separado

  if (opcao == 0) {
    if (PlayerState.jogadorId != null) {
      await FirebaseService.desbloquearAmbiente(
        jogadorId: PlayerState.jogadorId!,
        ambienteId: 'praca_central',
      );
      await FirebaseService.registrarInteracao(
        jogadorId: PlayerState.jogadorId!,
        ambiente: 'laboratorio',
        escolha: 'examinou_monitor',
      );
    }
    await Future.delayed(
        Duration(milliseconds: 35 * respostas[0]['text']!.length + 500));
    if (!mounted) return;
    setState(() => _showAvancar = true);
  }
  // opcao 1 e 2 — não faz nada extra, o jogador clica para voltar as opções
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
                  '📍 FORA DO RAIO — LABORATÓRIO',
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
                  Text('◆ LABORATÓRIO ◆', style: _rpgStyleYellow),
                  Text('▶ NOITE', style: GoogleFonts.pressStart2p(fontSize: 9, color: const Color(0xFF00E400))),
                ],
              ),
            ),

            // CENA
            Container(
              height: screenHeight * 0.38,
              width: double.infinity,
              color: const Color(0xFF0A0A18),
              child: Stack(
                children: [
                  // COMPUTADORES - FILEIRA DE CIMA
                  Positioned(
                    top: 16, left: 0, right: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(4, (i) => _buildComputador(i == 1)),
                      ),
                    ),
                  ),

                  // PISO
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      height: 40,
                      color: const Color(0xFF151520),
                      foregroundDecoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: Color(0xFF252535), width: 3)),
                      ),
                    ),
                  ),

                  // PERSONAGEM ALUNO
                  Positioned(bottom: 40, right: 60, child: _buildAluno()),
                ],
              ),
            ),

            // DIÁLOGO
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
                      final opcoes = [
                        'EXAMINAR O MONITOR LIGADO',
                        'PERGUNTAR AO ALUNO MAIS DETALHES',
                        'VERIFICAR AS CÂMERAS',
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
                  MaterialPageRoute(builder: (_) => GameScreenPracaCentral()),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  color: const Color(0xFF000030),
                  child: Center(
                    child: Text('► IR ATÉ A PRAÇA CENTRAL',
                        style: GoogleFonts.pressStart2p(fontSize: 11, color: const Color(0xFFF8F800), letterSpacing: 2)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildComputador(bool ligado) {
    return Column(
      children: [
        Container(
          width: 55, height: 42,
          decoration: BoxDecoration(
            color: ligado ? const Color(0xFF001428) : const Color(0xFF1A1A2A),
            border: Border.all(
              color: ligado ? const Color(0xFF00AAFF) : const Color(0xFF333355),
              width: 2,
            ),
          ),
          child: ligado
              ? Padding(
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: double.infinity, height: 4, color: const Color(0xFF00FF00).withOpacity(0.8)),
                      const SizedBox(height: 3),
                      Container(width: double.infinity, height: 4, color: const Color(0xFF00FF00).withOpacity(0.5)),
                      const SizedBox(height: 3),
                      Container(width: 28, height: 4, color: const Color(0xFFFF4444).withOpacity(0.8)),
                      const SizedBox(height: 3),
                      Container(width: double.infinity, height: 4, color: const Color(0xFF00FF00).withOpacity(0.3)),
                    ],
                  ),
                )
              : null,
        ),
        Container(width: 8, height: 10, color: const Color(0xFF2A2A3A)),
        Container(width: 36, height: 5, color: const Color(0xFF2A2A3A)),
      ],
    );
  }

  Widget _buildAluno() {
    return Column(
      children: [
        Container(
          width: 22, height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFFD4A06A),
            border: Border.all(color: const Color(0xFFA08050), width: 2),
          ),
        ),
        Container(width: 24, height: 22, color: const Color(0xFF4A2A6A)),
        Container(width: 24, height: 14, color: const Color(0xFF2A1A3A)),
      ],
    );
  }
}