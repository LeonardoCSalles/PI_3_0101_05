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
    this.radiusMeters = 30.0,
    this.isUnlocked = false,
  });
}

final List<GameLocation> gameLocations = [
  GameLocation(
    id: 'portaria',
    name: 'Portaria',
    description: 'Entrada principal do campus. Ponto de início da investigação.',
    latitude: 0.0,   // substituir no Maps
    longitude: 0.0,  // substituir no Maps
    isUnlocked: true, // começa desbloqueado
  ),
  GameLocation(
    id: 'biblioteca',
    name: 'Biblioteca',
    description: 'Ambiente silencioso. Aqui está a primeira pista.',
    latitude: 0.0,
    longitude: 0.0,
  ),
  GameLocation(
    id: 'cantina',
    name: 'Cantina',
    description: 'Espaço com mesas e cadeiras. Algo aconteceu aqui.',
    latitude: 0.0,
    longitude: 0.0,
  ),
  GameLocation(
    id: 'laboratorio',
    name: 'Laboratório',
    description: 'Sala com computadores. Um deles ainda está ligado.',
    latitude: 0.0,
    longitude: 0.0,
  ),
  GameLocation(
    id: 'praca_central',
    name: 'Praça Central',
    description: 'Área aberta com bancos e árvores. O desfecho acontece aqui.',
    latitude: 0.0,
    longitude: 0.0,
  ),
];