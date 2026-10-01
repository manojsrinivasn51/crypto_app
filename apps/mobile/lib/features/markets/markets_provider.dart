import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/coin.dart';
import '../../data/services/api_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void updateQuery(String q) => state = q;
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

final marketsProvider = FutureProvider<List<Coin>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final api = ref.read(apiServiceProvider);
  if (query.isNotEmpty) {
    return api.search(query);
  }
  return api.getCoins();
});
