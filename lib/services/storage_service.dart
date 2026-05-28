import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _jogadorIdKey = 'jogador_id';
  static const String _nomeJogadorKey = 'nome_jogador';

  // Salva o ID do jogador localmente
  static Future<void> salvarJogadorId(String id, String nome) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_jogadorIdKey, id);
    await prefs.setString(_nomeJogadorKey, nome);
  }

  // Carrega o ID do jogador salvo
  static Future<String?> carregarJogadorId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_jogadorIdKey);
  }

  // Carrega o nome do jogador salvo
  static Future<String?> carregarNomeJogador() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nomeJogadorKey);
  }

  // Remove os dados salvos
  static Future<void> limpar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_jogadorIdKey);
    await prefs.remove(_nomeJogadorKey);
  }
}