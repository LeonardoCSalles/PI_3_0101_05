import 'package:flutter/material.dart';
import 'game_screen_praca_central.dart';

class GameScreenLaboratorio extends StatefulWidget {
  @override
  _GameScreenLaboratorioState createState() => _GameScreenLaboratorioState();
}

class _GameScreenLaboratorioState extends State<GameScreenLaboratorio> {
  String _narrative = '';
  List<Map<String, dynamic>> _options = [];
  bool _showOptions = true;

  @override
  void initState() {
    super.initState();
    _loadLaboratorio();
  }

  void _loadLaboratorio() {
    setState(() {
      _narrative =
          'O laboratório está escuro, exceto por um monitor ligado no canto.\n\n'
          'A tela exibe uma janela de terminal aberta com comandos digitados.\n\n'
          'Alguém esteve aqui recentemente e saiu às pressas.';

      _options = [
        {
          'text': 'Examinar o monitor ligado',
          'action': () => _showResponse(
                'Na tela você vê um arquivo aberto.\n\n'
                'São coordenadas e horários. Alguém estava mapeando '
                'os movimentos de pessoas no campus.\n\n'
                '"Encontro marcado. Praça Central. 18h."',
                avancar: true,
              ),
        },
        {
          'text': 'Procurar pelos computadores',
          'action': () => _showResponse(
                'Os outros computadores estão desligados e trancados.\n\n'
                'Só o do canto tem algo relevante.',
              ),
        },
        {
          'text': 'Verificar as câmeras do lab',
          'action': () => _showResponse(
                'As câmeras estão cobertas com fita preta.\n\n'
                'Quem esteve aqui sabia o que estava fazendo.',
              ),
        },
      ];
    });
  }

  void _showResponse(String text, {bool avancar = false}) {
    setState(() {
      _narrative = text;
      _showOptions = false;
    });

    Future.delayed(Duration(seconds: 3), () {
      if (avancar) {
        _showBotaoAvancar();
      } else {
        setState(() {
          _showOptions = true;
        });
      }
    });
  }

  void _showBotaoAvancar() {
    setState(() {
      _showOptions = true;
      _options = [
        {
          'text': 'Ir até a Praça Central →',
          'action': () => _goToPracaCentral(),
        },
      ];
    });
  }

  void _goToPracaCentral() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => GameScreenPracaCentral()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Laboratório',
          style: TextStyle(
            fontFamily: 'RPG',
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white.withOpacity(0.05),
              ),
              child: Text(
                _narrative,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.6,
                  fontFamily: 'RPG',
                ),
              ),
            ),
            SizedBox(height: 32),
            if (_showOptions)
              ...(_options.map(
                (option) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white38),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: option['action'],
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        option['text'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontFamily: 'RPG',
                        ),
                      ),
                    ),
                  ),
                ),
              )),
          ],
        ),
      ),
    );
  }
}