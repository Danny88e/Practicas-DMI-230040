// Datasource que consulta la API yesno.wtf y aplica la
// distribución de probabilidad: 40% Sí, 40% No, 20% Tal Vez.
//
// Para lograr 40/40/20 se generan 5 opciones equiprobables:
//   [yes, yes, no, no, maybe]
// Luego se usa el parámetro `force` para pedir exactamente esa respuesta.

import 'dart:math';
import 'package:dio/dio.dart';
import 'package:yes_no_app/domain/entities/message.dart';
import 'package:yes_no_app/infrastructure/models/yes_no_model.dart';

class GetYesNoAnswer {
  final _dio = Dio();

  // Las 5 opciones aseguran 40% yes, 40% no, 20% maybe
  final List<String> _options = ['yes', 'yes', 'no', 'no', 'maybe'];

  Future<Message> getAnswer() async {
    // Selección aleatoria respetando la distribución
    final randomAnswer = _options[Random().nextInt(_options.length)];

    final response = await _dio.get(
      'https://yesno.wtf/api',
      queryParameters: {'force': randomAnswer},
    );

    final yesNoModel = YesNoModel.fromJson(response.data);
    return yesNoModel.toMessageEntity();
  }
}
