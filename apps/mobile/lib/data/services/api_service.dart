import '../models/coin.dart';
import '../../core/api_client.dart';

class ApiService {
  Future<List<Coin>> getCoins({int page = 1, String? ids}) async {
    final response = await ApiClient.dio.get('/coins', queryParameters: {
      'page': page,
      if (ids != null) 'ids': ids,
    });
    final List data = response.data['data'] ?? [];
    return data.map((json) => Coin.fromJson(json)).toList();
  }

  Future<List<Coin>> search(String query) async {
    final response = await ApiClient.dio.get('/search', queryParameters: {'q': query});
    final List data = response.data['data']?['coins'] ?? [];
    return data.map((json) => Coin.fromJson(json)).toList();
  }

  Future<Map<String, dynamic>> getGlobalStats() async {
    final response = await ApiClient.dio.get('/market/global');
    return response.data['data'] ?? {};
  }
  
  Future<List<List<num>>> getChartData(String id, int days) async {
    final response = await ApiClient.dio.get('/coins/$id/chart', queryParameters: {'days': days});
    final List prices = response.data['data']?['prices'] ?? [];
    return prices.map((e) => [e[0] as num, e[1] as num]).toList();
  }
  
  Future<Map<String, dynamic>> getCoinDetail(String id) async {
    final response = await ApiClient.dio.get('/coins/$id');
    return response.data['data'] ?? {};
  }
}
