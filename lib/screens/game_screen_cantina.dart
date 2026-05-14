import 'package:flutter/material.dart';
import 'game_screen_laboratorio.dart';

class GameScreenCantina extends StatefulWidget {
  @override
  _GameScreenCantinaState createState() => _GameScreenCantinaState();
}

class _GameScreenCantinaState extends State<GameScreenCantina> {
  String _narrative = '';
  List<Map<String, dynamic>> _options = [];
  bool _showOptions = true;

  @override
  void initState() {
    super.initState();
    _loadCantina();
  }

  void _loadCantina() {
    setState(() {
      _narrative =
          'A cantina está quase vazia para essa hora do dia.\n\n'
          'Algumas mesas com bandejas abandonadas. Um copo virado.\n\n'
          'No canto, um funcionário limpa o balcão sem te olhar nos olhos.';

      _options = [
        {
          'text': 'Falar com o funcionário',
          'action': () => _showResponse(
                'Ele hesita antes de responder.\n\n'
                '"Eu vi algo sim... mas prefiro não me meter."\n\n'
                'Ele aponta discretamente para uma mochila esquecida embaixo de uma mesa.',
                avancar: false,
              ),
        },
        {
          'text': 'Examinar a mochila esquecida',
          'action': () => _showResponse(
                'Dentro da mochila você encontra um crachá universitário.\n\n'
                'O nome no crachá é o mesmo do bilhete que você encontrou na biblioteca.\n\n'
                'A investigação está ficando mais séria.',
                avancar: true,
              ),
        },
        {
          'text': 'Procurar mais pistas',
          'action': () => _showResponse(
                'Você vasculha as mesas próximas mas não encontra nada relevante.\n\n'
                'Só bandejas e restos de comida.',
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
          'text': 'Ir até o laboratório →',
          'action': () => _goToLaboratorio(),
        },
      ];
    });
  }

  void _goToLaboratorio() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => GameScreenLaboratorio()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Cantina',
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