class PlayerState {
  static String? jogadorId;
  static String nomeJogador = '';
  static List<String> ambientesDesbloqueados = ['portaria'];
  static String ambienteAtual = 'portaria';

  // Desbloqueia um ambiente localmente
  static void desbloquear(String ambienteId) {
    if (!ambientesDesbloqueados.contains(ambienteId)) {
      ambientesDesbloqueados.add(ambienteId);
    }
    ambienteAtual = ambienteId;
  }

  // Verifica se tem jogador salvo
  static bool get temJogador => jogadorId != null;
}