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
    latitude: -22.834552,   // substituir no Maps
    longitude: -47.052778,  // substituir no Maps
    isUnlocked: true, // começa desbloqueado
  ),
  GameLocation(
    id: 'biblioteca',
    name: 'Biblioteca',
    description: 'Ambiente silencioso. Aqui está a primeira pista.',
    latitude: -22.834135,
    longitude: -47.051839,
  ),
  GameLocation(
    id: 'cantina',
    name: 'Cantina',
    description: 'Espaço com mesas e cadeiras. Algo aconteceu aqui.',
    latitude: -22.833101,
    longitude: -47.052358,
  ),
  GameLocation(
    id: 'laboratorio',
    name: 'Laboratório',
    description: 'Sala com computadores. Um deles ainda está ligado.',
    latitude: -22.833961,
    longitude: -47.052961,
  ),
  GameLocation(
    id: 'praca_central',
    name: 'Praça Central',
    description: 'Área aberta com bancos e árvores. O desfecho acontece aqui.',
    latitude: -22.833761,
    longitude: -47.052441,
  ),
];