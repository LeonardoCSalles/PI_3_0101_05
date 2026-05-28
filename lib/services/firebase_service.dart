import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static const bool firebaseAtivo = true;

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<String> criarJogador(String nome) async {
    if (!firebaseAtivo) return 'jogador_teste';

    try {
      DocumentReference ref = await _db.collection('jogadores').add({
        'nome': nome,
        'dataCriacao': FieldValue.serverTimestamp(),
        'ambienteAtual': 'portaria',
      });
      return ref.id;
    } catch (e) {
      print('Erro ao criar jogador: $e');
      rethrow;
    }
  }

  static Future<void> salvarProgresso({
    required String jogadorId,
    required String ambienteAtual,
    required List<String> ambientesDesbloqueados,
  }) async {
    if (!firebaseAtivo) return;

    try {
      await _db.collection('progresso').doc(jogadorId).set({
        'jogadorId': jogadorId,
        'ambienteAtual': ambienteAtual,
        'ambientesDesbloqueados': ambientesDesbloqueados,
        'ultimaAtualizacao': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erro ao salvar progresso: $e');
    }
  }

  static Future<Map<String, dynamic>?> carregarProgresso(
      String jogadorId) async {
    if (!firebaseAtivo) return null;

    try {
      DocumentSnapshot doc =
          await _db.collection('progresso').doc(jogadorId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Erro ao carregar progresso: $e');
      return null;
    }
  }

  static Future<void> registrarInteracao({
    required String jogadorId,
    required String ambiente,
    required String escolha,
  }) async {
    if (!firebaseAtivo) return;

    try {
      await _db.collection('interacoes').add({
        'jogadorId': jogadorId,
        'ambiente': ambiente,
        'escolha': escolha,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erro ao registrar interacao: $e');
    }
  }

  static Future<void> desbloquearAmbiente({
    required String jogadorId,
    required String ambienteId,
  }) async {
    if (!firebaseAtivo) return;

    try {
      await _db.collection('progresso').doc(jogadorId).update({
        'ambientesDesbloqueados': FieldValue.arrayUnion([ambienteId]),
        'ambienteAtual': ambienteId,
        'ultimaAtualizacao': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erro ao desbloquear ambiente: $e');
    }
  }

  static Future<bool> ambienteDesbloqueado({
    required String jogadorId,
    required String ambienteId,
  }) async {
    if (!firebaseAtivo) return true;

    try {
      Map<String, dynamic>? progresso = await carregarProgresso(jogadorId);
      if (progresso == null) return false;
      List<dynamic> desbloqueados = progresso['ambientesDesbloqueados'] ?? [];
      return desbloqueados.contains(ambienteId);
    } catch (e) {
      print('Erro ao verificar ambiente: $e');
      return false;
    }
  }
}