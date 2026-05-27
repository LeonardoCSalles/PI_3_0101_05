class GameLocation {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  bool isUnlocked;

  GameLocation({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.radiusMeters = 50.0,
    this.isUnlocked = false,
  });
}

final List<GameLocation> gameLocations = [
  GameLocation(
    id: 'portaria',
    name: 'Portaria',
    description: 'Entrada principal do campus. Ponto de início da investigação.',
    latitude: -22.8345598,   // substituir no Maps
    longitude: -47.0527831,  // substituir no Maps
    isUnlocked: true, // começa desbloqueado
  ),
  GameLocation(
    id: 'biblioteca',
    name: 'Biblioteca',
    description: 'Ambiente silencioso. Aqui está a primeira pista.',
    latitude: -22.8336483,
    longitude: -47.0519422,
  ),
  GameLocation(
    id: 'cantina',
    name: 'Cantina',
    description: 'Espaço com mesas e cadeiras. Algo aconteceu aqui.',
    latitude: -22.8330204,
    longitude: -47.0521787,
  ),
  GameLocation(
    id: 'laboratorio',
    name: 'Laboratório',
    description: 'Sala com computadores. Um deles ainda está ligado.',
    latitude: -22.8340787,
    longitude: -47.0554995,
  ),
  GameLocation(
    id: 'praca_central',
    name: 'Praça Central',
    description: 'Área aberta com bancos e árvores. O desfecho acontece aqui.',
    latitude: -22.833216,
    longitude: -47.052072,
  ),
];