import 'package:geolocator/geolocator.dart';
import 'permission_service.dart';
import '../models/location_model.dart';


class LocationService {
   // MUDA PARA false quando for testar no campus de verdade
  static const bool modoDesenvolvedor = true;
  // Pega a posição atual do jogador uma vez
  static Future<Position?> getCurrentPosition() async {
    bool temPermissao = await PermissionService.requestLocationPermission();

    if (!temPermissao) return null;

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Erro ao pegar localização: $e');
      return null;
    }
  }

  // Calcula a distância em metros entre dois pontos
  static double calcularDistancia({
    required double latAtual,
    required double lonAtual,
    required double latDestino,
    required double lonDestino,
  }) {
    return Geolocator.distanceBetween(
      latAtual,
      lonAtual,
      latDestino,
      lonDestino,
    );
  }

  // Verifica se o jogador está dentro do raio de um ambiente
  static bool estaNoAmbiente({
    required Position posicaoAtual,
    required GameLocation ambiente,
  }) {
    double distancia = calcularDistancia(
      latAtual: posicaoAtual.latitude,
      lonAtual: posicaoAtual.longitude,
      latDestino: ambiente.latitude,
      lonDestino: ambiente.longitude,
    );

    return distancia <= ambiente.radiusMeters;
  }

  // Verifica qual ambiente o jogador está agora
  static Future<GameLocation?> getAmbienteAtual() async {
  // Se estiver em modo desenvolvedor, retorna a portaria direto
  if (modoDesenvolvedor) {
    return gameLocations.firstWhere((l) => l.id == 'portaria');
  }

  Position? posicao = await getCurrentPosition();
  if (posicao == null) return null;

  for (GameLocation ambiente in gameLocations) {
    if (ambiente.isUnlocked && estaNoAmbiente(
      posicaoAtual: posicao,
      ambiente: ambiente,
    )) {
      return ambiente;
    }
  }

  return null;
}

  // Qual o ambiente mais próximo agora (para dar dica ao jogador)
  static Future<Map<String, dynamic>?> getAmbienteMaisProximo() async {
    Position? posicao = await getCurrentPosition();
    if (posicao == null) return null;

    GameLocation? maisProximo;
    double menorDistancia = double.infinity;

    for (GameLocation ambiente in gameLocations) {
      if (!ambiente.isUnlocked) continue;

      double distancia = calcularDistancia(
        latAtual: posicao.latitude,
        lonAtual: posicao.longitude,
        latDestino: ambiente.latitude,
        lonDestino: ambiente.longitude,
      );

      if (distancia < menorDistancia) {
        menorDistancia = distancia;
        maisProximo = ambiente;
      }
    }

    if (maisProximo == null) return null;

    return {
      'ambiente': maisProximo,
      'distancia': menorDistancia.toStringAsFixed(0), // ex: "42"
    };
  }

  // Stream — atualiza a posição em tempo real enquanto o jogador caminha
  static Stream<Position> getPosicaoEmTempoReal() {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // atualiza a cada 5 metros andados
      ),
    );
  }
}