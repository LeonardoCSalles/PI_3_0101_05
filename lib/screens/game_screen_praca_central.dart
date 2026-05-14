import 'package:flutter/material.dart';

class GameScreenPracaCentral extends StatefulWidget {
  @override
  _GameScreenPracaCentralState createState() => _GameScreenPracaCentralState();
}

class _GameScreenPracaCentralState extends State<GameScreenPracaCentral> {
  String _narrative = '';
  List<Map<String, dynamic>> _options = [];
  bool _showOptions = true;
  bool _fimDeJogo = false;

  @override
  void initState() {
    super.initState();
    _loadPracaCentral();
  }

  void _loadPracaCentral() {
    setState(() {
      _narrative =
          'A praça está quieta. O sol já está baixo.\n\n'
          'Você vê uma figura sentada num banco, de costas para você.\n\n'
          'É a pessoa que você esteve procurando o tempo todo.';

      _options = [
        {
          'text': 'Se aproximar lentamente',
          'action': () => _showResponse(
                'A figura se vira antes de você chegar.\n\n'
                '"Eu sabia que você viria."\n\n'
                'Era um professor do campus. Ele segura um envelope.',
                avancar: false,
                proximaOpcao: true,
              ),
        },
        {
          'text': 'Observar de longe primeiro',
          'action': () => _showResponse(
                'Você se esconde atrás de uma árvore e observa.\n\n'
                'A figura está esperando. Olhando para o relógio.\n\n'
                'Você decide se aproximar.',
                avancar: false,
                proximaOpcao: true,
              ),
        },
      ];
    });
  }

  void _showResponse(String text,
      {bool avancar = false, bool proximaOpcao = false}) {
    setState(() {
      _narrative = text;
      _showOptions = false;
    });

    Future.delayed(Duration(seconds: 3), () {
      if (proximaOpcao) {
        _showOpcaoFinal();
      } else if (avancar) {
        _showFimDeJogo();
      } else {
        setState(() {
          _showOptions = true;
        });
      }
    });
  }

  void _showOpcaoFinal() {
    setState(() {
      _showOptions = true;
      _options = [
        {
          'text': 'Aceitar o envelope',
          'action': () => _showResponse(
                'Dentro do envelope há documentos que revelam tudo.\n\n'
                '"Guarde isso em segurança. Você foi o único que chegou até aqui."\n\n'
                'O mistério do campus foi desvendado.',
                avancar: true,
              ),
        },
        {
          'text': 'Recusar e exigir respostas',
          'action': () => _showResponse(
                '"Como você quiser."\n\n'
                'Ele conta tudo verbalmente. Cada detalhe.\n\n'
                'Você finalmente entende o que aconteceu no campus.',
                avancar: true,
              ),
        },
      ];
    });
  }

  void _showFimDeJogo() {
    setState(() {
      _fimDeJogo = true;
      _showOptions = false;
      _narrative =
          '🎉 Parabéns!\n\n'
          'Você percorreu todo o campus e desvendou o Mistério no Campus.\n\n'
          'A investigação chegou ao fim.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Praça Central',
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
                border: Border.all(
                  color: _fimDeJogo ? Colors.white54 : Colors.white24,
                ),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white.withOpacity(0.05),
              ),
              child: Text(
                _narrative,
                style: TextStyle(
                  color: _fimDeJogo ? Colors.white : Colors.white70,
                  fontSize: _fimDeJogo ? 18 : 16,
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
            if (_fimDeJogo)
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white54),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Voltar ao início',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontFamily: 'RPG',
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}