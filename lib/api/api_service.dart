import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:titulos/models/titulo.dart';

class ApiService {
  final String baseUrl = 'http://131.255.83.254:8181/rest/WSBORDR';

  Future<List<Bordero>> fetchBorderos({
    required String borderoDe,
    required String borderoAte,
    required String cfilial,
  }) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/borderos?borderoDe=$borderoDe&borderoAte=$borderoAte&cfilial=$cfilial'),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> data = jsonResponse['data'];

      return data.map((item) {
        List<Titulo> titulos = (item["titulos"] as List).map((t) {
          return Titulo(
            titulo: t["numero"],
            cliente: t["nome"],
            valor: (t["valor"] as num).toDouble(),
            vencimento: t["vencto"],
          );
        }).toList();

        return Bordero(
          id: item["numbor"],
          descricao: "Borderô ${item["numbor"]}",
          titulos: titulos,
        );
      }).toList();
    } else {
      throw Exception('Erro ao carregar borderôs: ${response.statusCode}');
    }
  }
}
