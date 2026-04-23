import 'package:flutter/material.dart';

class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jogo iniciado'),
      ),
      body: Center(
        child: Text(
          'Aqui começa o RPG!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}