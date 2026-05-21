import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/player_state.dart';

class GameScreenPracaCentral extends StatefulWidget {
  @override
  _GameScreenPracaCentralState createState() => _GameScreenPracaCentralState();
}

class _GameScreenPracaCentralState extends State<GameScreenPracaCentral> {
  int _dialogueIndex = 0;
  bool _showChoices = false;
  bool _typing = false;
  String _displayedText = '';
  String _fullText = '';
  String _speaker = '';
  bool _fimDeJogo = false;

  final List<Map<String, String>> _dialogues = [
    {'speaker': 'NARRADOR', 'text': 'A praça está quieta. O sol já está baixo entre as árvores.'},
    {'speaker': 'NARRADOR', 'text': 'Nos bancos ao centro, uma figura aguarda. Era quem você procurava o tempo todo.'},
    {'speaker': 'MISTERIOSO', 'text': 'Eu sabia que você viria. Você seguiu todas as pistas.'},
    {'speaker': 'MISTERIOSO', 'text': 'Tenho algo para te mostrar. Algo que vai mudar tudo o que você sabe sobre este campus.'},
  ];

  @override
  void initState() {
    super.initState();
    _startDialogue(0);
  }

  void _startDialogue(int index) {
    setState(() {
      _dialogueIndex = index;
      _speaker = _dialogues[index]['speaker']!;
      _fullText = _dialogues[index]['text']!;
      _displayedText = '';
      _typing = true;
      _showChoices = false;
    });
    _typeText();
  }

  void _typeText() async {
    for (int i = 0; i < _fullText.length; i++) {
      await Future.delayed(const Duration(milliseconds: 40));
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
      {'speaker': 'NARRADOR', 'text': 'Você aceita o envelope. Dentro, documentos que revelam tudo. O mistério foi desvendado.'},
      {'speaker': 'MISTERIOSO', 'text': 'Como quiser. Vou te contar tudo. Cada detalhe do que aconteceu aqui no campus.'},
    ];

    setState(() {
      _showChoices = false;
      _speaker = respostas[opcao]['speaker']!;
      _fullText = respostas[opcao]['text']!;
      _displayedText = '';
      _typing = true;
    });
    _typeText();

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

    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    setState(() {
      _fimDeJogo = true;
      _showChoices = false;
      _speaker = 'NARRADOR';
      _fullText = 'Parabéns! Você percorreu todo o campus e desvendou o Mistério no Campus!';
      _displayedText = _fullText;
      _typing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: SafeArea(
        child: Column(
          children: [
            _buildLocationBar(),
            _buildScene(),
            GestureDetector(onTap: _onTapDialogue, child: _buildDialogueBox()),
            if (_showChoices) _buildChoices(),
            if (_fimDeJogo) _buildBotaoFim(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationBar() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text('◆ PRAÇA CENTRAL ◆',
              style: TextStyle(fontFamily: 'RPG', fontSize: 8, color: Color(0xFFF8F800))),
          Text('▶ ENTARDECER',
              style: TextStyle(fontFamily: 'RPG', fontSize: 7, color: Color(0xFFFFAA00))),
        ],
      ),
    );
  }

  Widget _buildScene() {
    return Container(
      height: 220,
      width: double.infinity,
      color: const Color(0xFF0A1A0A),
      child: Stack(
        children: [
          // CÉU
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
          Positioned(bottom: 36, left: 10, child: _buildArvore(80)),
          Positioned(bottom: 36, left: 60, child: _buildArvore(60)),
          Positioned(bottom: 36, right: 10, child: _buildArvore(80)),
          Positioned(bottom: 36, right: 60, child: _buildArvore(60)),

          // BANCO CENTRAL
          Positioned(
            bottom: 46,
            left: 0, right: 0,
            child: Center(child: _buildBanco()),
          ),

          // PERSONAGEM MISTERIOSO
          Positioned(
            bottom: 46,
            left: 0, right: 0,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 30),
                child: _buildMisterioso(),
              ),
            ),
          ),

          // PISO
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 36,
              color: const Color(0xFF0A1A0A),
              foregroundDecoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFF1A3A1A), width: 3)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArvore(double altura) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: altura * 0.7,
          decoration: const BoxDecoration(
            color: Color(0xFF1A4A1A),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
        ),
        Container(
          width: 8,
          height: altura * 0.3,
          color: const Color(0xFF5D3A1A),
        ),
      ],
    );
  }

  Widget _buildBanco() {
    return Column(
      children: [
        Container(width: 50, height: 6, color: const Color(0xFF8B6914)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 6, height: 14, color: const Color(0xFF6B4A10)),
            const SizedBox(width: 30),
            Container(width: 6, height: 14, color: const Color(0xFF6B4A10)),
          ],
        ),
      ],
    );
  }

  Widget _buildMisterioso() {
    return Column(
      children: [
        Container(
          width: 20,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFF8A7060),
            border: Border.all(color: const Color(0xFF6A5040), width: 2),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0, left: 0, right: 0,
                child: Container(height: 5, color: const Color(0xFF2A2A2A)),
              ),
            ],
          ),
        ),
        Container(
          width: 22,
          height: 20,
          color: const Color(0xFF2A2A2A),
        ),
        Container(
          width: 22,
          height: 12,
          color: const Color(0xFF1A1A1A),
        ),
      ],
    );
  }

  Widget _buildDialogueBox() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF000010),
      padding: const EdgeInsets.all(12),
      constraints: const BoxConstraints(minHeight: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF000050),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Text(_speaker,
                style: const TextStyle(
                    fontFamily: 'RPG', fontSize: 8, color: Color(0xFFF8F800))),
          ),
          const SizedBox(height: 8),
          Text(_displayedText,
              style: const TextStyle(
                  fontFamily: 'RPG', fontSize: 8,
                  color: Color(0xFFE0E0E0), height: 2.2)),
          if (!_typing && !_showChoices && !_fimDeJogo)
            const Align(
              alignment: Alignment.bottomRight,
              child: Text('▼', style: TextStyle(color: Colors.white, fontSize: 10)),
            ),
        ],
      ),
    );
  }

  Widget _buildChoices() {
    final opcoes = [
      'ACEITAR O ENVELOPE',
      'EXIGIR RESPOSTAS DIRETAMENTE',
    ];
    return Container(
      color: const Color(0xFF000018),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          const Text('— ESCOLHA —',
              style: TextStyle(fontFamily: 'RPG', fontSize: 7, color: Color(0xFF505080))),
          const SizedBox(height: 6),
          ...List.generate(opcoes.length, (i) => GestureDetector(
            onTap: () => _escolher(i),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              margin: const EdgeInsets.only(bottom: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF000018),
                border: Border.all(color: const Color(0xFF303060), width: 2),
              ),
              child: Row(
                children: [
                  const Text('► ',
                      style: TextStyle(fontFamily: 'RPG', fontSize: 9, color: Color(0xFFF8F800))),
                  Expanded(
                    child: Text(opcoes[i],
                        style: const TextStyle(
                            fontFamily: 'RPG', fontSize: 7, color: Color(0xFFA0A0C0))),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildBotaoFim() {
    return GestureDetector(
      onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        color: const Color(0xFF001400),
        child: const Center(
          child: Text('★ VOLTAR AO INÍCIO ★',
              style: TextStyle(
                  fontFamily: 'RPG', fontSize: 9,
                  color: Color(0xFFF8F800), letterSpacing: 2)),
        ),
      ),
    );
  }
}