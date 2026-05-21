import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  // MUDA PARA true quando quiser ativar o Firebase
  static const bool firebaseAtivo = false;

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<String> criarJogador(String nome) async {
    if (!firebaseAtivo) return 'jogador_teste';
    
    DocumentReference ref = await _db.collection('jogadores').add({
      'nome': nome,
      'dataCriacao': FieldValue.serverTimestamp(),
      'ambienteAtual': 'portaria',
    });
    return ref.id;
  }

  static Future<void> salvarProgresso({
    required String jogadorId,
    required String ambienteAtual,
    required List<String> ambientesDesbloqueados,
  }) async {
    if (!firebaseAtivo) return;
    
    await _db.collection('progresso').doc(jogadorId).set({
      'jogadorId': jogadorId,
      'ambienteAtual': ambienteAtual,
      'ambientesDesbloqueados': ambientesDesbloqueados,
      'ultimaAtualizacao': FieldValue.serverTimestamp(),
    });
  }

  static Future<Map<String, dynamic>?> carregarProgresso(
      String jogadorId) async {
    if (!firebaseAtivo) return null;
    
    DocumentSnapshot doc =
        await _db.collection('progresso').doc(jogadorId).get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return null;
  }

  static Future<void> registrarInteracao({
    required String jogadorId,
    required String ambiente,
    required String escolha,
  }) async {
    if (!firebaseAtivo) return;
    
    await _db.collection('interacoes').add({
      'jogadorId': jogadorId,
      'ambiente': ambiente,
      'escolha': escolha,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> desbloquearAmbiente({
    required String jogadorId,
    required String ambienteId,
  }) async {
    if (!firebaseAtivo) return;
    
    await _db.collection('progresso').doc(jogadorId).update({
      'ambientesDesbloqueados': FieldValue.arrayUnion([ambienteId]),
      'ambienteAtual': ambienteId,
      'ultimaAtualizacao': FieldValue.serverTimestamp(),
    });
  }

  static Future<bool> ambienteDesbloqueado({
    required String jogadorId,
    required String ambienteId,
  }) async {
    if (!firebaseAtivo) return true;
    
    Map<String, dynamic>? progresso = await carregarProgresso(jogadorId);
    if (progresso == null) return false;

    List<dynamic> desbloqueados = progresso['ambientesDesbloqueados'] ?? [];
    return desbloqueados.contains(ambienteId);
  }
}