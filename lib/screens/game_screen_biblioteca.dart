import 'package:flutter/material.dart';
// import 'game_screen_cantina.dart'; // descomentar quando criar a próxima tela

class GameScreenBiblioteca extends StatefulWidget {
  @override
  _GameScreenBibliotecaState createState() => _GameScreenBibliotecaState();
}

class _GameScreenBibliotecaState extends State<GameScreenBiblioteca> {
  String _narrative = '';
  List<Map<String, dynamic>> _options = [];
  bool _showOptions = true;

  @override
  void initState() {
    super.initState();
    _loadBiblioteca();
  }

  void _loadBiblioteca() {
    setState(() {
      _narrative =
          'O silêncio da biblioteca é quase absoluto.\n\n'
          'Enquanto anda entre as estantes, algo chama sua atenção: '
          'um caderno aberto em uma mesa.\n\n'
          'Você se aproxima e percebe que há um bilhete escrito às pressas.';

      _options = [
        {
          'text': 'Ler o bilhete',
          'action': () => _showResponse(
                '"Se algo acontecer comigo, procure no laboratório."\n\n'
                'A mensagem é direta e urgente.\n'
                'Agora você tem um novo destino.',
                avancar: true,
              ),
        },
        {
          'text': 'Ignorar o bilhete',
          'action': () => _showResponse(
                'Você decide não mexer no caderno.\n\n'
                'Mas a sensação de estar perdendo algo importante '
                'não sai da sua cabeça.',
              ),
        },
        {
          'text': 'Explorar mais a biblioteca',
          'action': () => _showResponse(
                'Você procura por mais pistas, mas não encontra '
                'nada além do silêncio.',
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
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => GameScreenLaboratorio()),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Biblioteca',
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
            // CAIXA DE NARRATIVA
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

            // OPÇÕES
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