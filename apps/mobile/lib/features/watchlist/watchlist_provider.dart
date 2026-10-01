import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPrefsProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());

class WatchlistNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    return ref.read(sharedPrefsProvider).getStringList('watchlist') ?? [];
  }

  void toggle(String id) {
    if (state.contains(id)) {
      state = state.where((e) => e != id).toList();
    } else {
      state = [...state, id];
    }
    ref.read(sharedPrefsProvider).setStringList('watchlist', state);
  }
}

final watchlistProvider = NotifierProvider<WatchlistNotifier, List<String>>(WatchlistNotifier.new);
