import 'package:flutter/material.dart';
import 'game_screen_biblioteca.dart'; // próxima tela
import 'package:misterio_no_campus/services/permission_service.dart';
import 'package:misterio_no_campus/services/location_service.dart';
import 'package:misterio_no_campus/models/location_model.dart';
import 'package:geolocator/geolocator.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  String _narrative = '';
  List<Map<String, dynamic>> _options = [];
  bool _showOptions = true;
  String _latitude = '--';
  String _longitude = '--';

  @override
void initState() {
  super.initState();
  _iniciarJogo(); // troca _loadPortaria() por _iniciarJogo()
}

void _iniciarJogo() async {
  bool temPermissao = await PermissionService.requestLocationPermission();

  if (!temPermissao) {
    setState(() {
      _narrative = 'Para jogar, você precisa permitir o acesso à localização.';
      _showOptions = false;
    });
    return;
  }

  // Captura e exibe as coordenadas na tela
  Position? posicao = await LocationService.getCurrentPosition();
  if (posicao != null) {
    setState(() {
      _latitude = posicao.latitude.toStringAsFixed(7);
      _longitude = posicao.longitude.toStringAsFixed(7);
    });
  }

  GameLocation? ambienteAtual = await LocationService.getAmbienteAtual();

  if (ambienteAtual?.id == 'portaria') {
    _loadPortaria();
  } else {
    setState(() {
      _narrative =
          'Você precisa estar na Portaria para iniciar a investigação.\n\n'
          'Dirija-se até a entrada principal do campus para começar.';
      _showOptions = false;
    });
  }
}

  void _loadPortaria() {
    setState(() {
      _narrative =
          'Você chega à entrada do campus e percebe que o movimento está menor do que o normal.\n\n'
          'O ambiente parece estranho, como se algo tivesse acontecido recentemente.\n\n'
          'Você sente que algo não está certo.';

      _options = [
        {
          'text': 'Observar melhor o ambiente',
          'action': () => _showResponse(
                'Você olha ao redor com mais atenção.\n'
                'Algumas pessoas parecem evitar conversar sobre algo.\n'
                'Isso só aumenta sua curiosidade.',
              ),
        },
        {
          'text': 'Ignorar e seguir caminho',
          'action': () => _showResponse(
                'Você tenta ignorar a sensação estranha, mas algo insiste em chamar sua atenção.\n'
                'Talvez seja melhor investigar antes de sair.',
              ),
        },
        {
          'text': 'Ir até a biblioteca',
          'action': () => _goToBiblioteca(),
        },
      ];
    });
  }

  void _showResponse(String text) {
    setState(() {
      _narrative = text;
      _showOptions = false;
    });

    // Após 3 segundos, volta as opções da portaria
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _showOptions = true;
      });
    });
  }

  void _goToBiblioteca() {
     Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GameScreenBiblioteca()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Portaria',
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

            // CAIXA DE COORDENADAS
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white12),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white.withOpacity(0.03),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        'LATITUDE',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _latitude,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                          fontFamily: 'RPG',
                        ),
                      ),
                    ],
                  ),
                  Container(width: 1, height: 30, color: Colors.white12),
                  Column(
                    children: [
                      Text(
                        'LONGITUDE',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _longitude,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                          fontFamily: 'RPG',
                        ),
                      ),
                    ],
                  ),
                ],
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