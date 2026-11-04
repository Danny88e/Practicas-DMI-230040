import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider que almacena el código del país seleccionado actualmente.
/// Por defecto es México (MX).
final selectedCountryProvider = StateProvider<String>((ref) => 'MX');
