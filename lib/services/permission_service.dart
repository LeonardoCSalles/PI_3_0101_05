import 'package:geolocator/geolocator.dart';

class PermissionService {

  // Chama essa função antes de qualquer coisa no jogo
  static Future<bool> requestLocationPermission() async {
    
    // Verifica se o GPS do celular está ligado
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('GPS desligado');
      return false;
    }

    // Verifica se o app já tem permissão
    LocationPermission permission = await Geolocator.checkPermission();

    // Se nunca pediu, pede agora
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      
      if (permission == LocationPermission.denied) {
        print('Permissão negada');
        return false;
      }
    }

    // Se o usuário negou permanentemente, manda para as configurações
    if (permission == LocationPermission.deniedForever) {
      print('Permissão negada permanentemente');
      return false;
    }

    // Tudo certo, tem permissão!
    return true;
  }
}