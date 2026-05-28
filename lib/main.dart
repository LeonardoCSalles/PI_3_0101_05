import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';
import 'models/player_state.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Erro Firebase: $e');
  }

  // Carrega o jogador salvo localmente
  String? jogadorId = await StorageService.carregarJogadorId();
  String? nomeJogador = await StorageService.carregarNomeJogador();

  if (jogadorId != null && nomeJogador != null) {
    PlayerState.jogadorId = jogadorId;
    PlayerState.nomeJogador = nomeJogador;
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}