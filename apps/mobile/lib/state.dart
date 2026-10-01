import 'package:flutter/foundation.dart';
import 'data.dart';

class AppState extends ChangeNotifier {
  final api = Api();
  List<Coin> coins = [];
  Map<String, dynamic> global = {};
  Set<String> watch = {};
  bool loading = false;
  String? error;
  String query = '', sort = 'cap', filter = 'all';
  int tab = 0;

  void setTab(int v) { tab = v; notifyListeners(); }

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final r = await Future.wait([api.coins(), api.global(), api.watchlist()]);
      coins = r[0] as List<Coin>;
      global = r[1] as Map<String, dynamic>;
      watch = (r[2] as List<String>).toSet();
    } catch (e) {
      error = 'Could not reach the market server. Check that the backend is running.';
    }
    loading = false;
    notifyListeners();
  }

  void setQuery(String v) { query = v; notifyListeners(); }
  void setSort(String v) { sort = v; notifyListeners(); }
  void setFilter(String v) { filter = v; notifyListeners(); }

  List<Coin> get visible {
    final q = query.toLowerCase();
    final l = coins
        .where((c) =>
            (c.name + c.symbol).toLowerCase().contains(q) &&
            (filter == 'all' || (filter == 'up' ? c.change > 0 : c.change < 0)))
        .toList();
    double key(Coin c) => {'cap': c.marketCap, 'price': c.price, 'change': c.change, 'volume': c.volume}[sort]!;
    l.sort((a, b) => key(b).compareTo(key(a)));
    return l;
  }

  List<Coin> get saved => coins.where((c) => watch.contains(c.id)).toList();

  Future<void> toggle(String id) async {
    final on = !watch.contains(id);
    on ? watch.add(id) : watch.remove(id);
    notifyListeners();
    try {
      await api.setWatch(id, on);
    } catch (_) {
      on ? watch.remove(id) : watch.add(id);
      notifyListeners();
    }
  }
}
