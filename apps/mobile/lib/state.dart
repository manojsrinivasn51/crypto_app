import 'package:flutter/foundation.dart';
import 'data.dart';

class AppState extends ChangeNotifier {
  // Creating an instance of the API
  final Api api = Api();
  
  // State variables
  List<Coin> coins = [];
  Map<String, dynamic> global = {};
  Set<String> watch = {};
  
  bool loading = false;
  String? error;
  
  // Filter and sort options
  String query = '';
  String sort = 'cap';
  String filter = 'all';
  
  // Current tab index
  int tab = 0;

  // Update the current tab
  void setTab(int value) { 
    tab = value; 
    notifyListeners(); 
  }

  // Load data from the API
  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    
    try {
      // Fetch coins, global stats, and watchlist at the same time
      final results = await Future.wait([
        api.coins(), 
        api.global(), 
        api.watchlist()
      ]);
      
      coins = results[0] as List<Coin>;
      global = results[1] as Map<String, dynamic>;
      
      // Convert watchlist list to a set for easier checking
      List<String> watchListStrings = results[2] as List<String>;
      watch = watchListStrings.toSet();
      
    } catch (e) {
      print("Error loading data: $e");
      error = 'Could not reach the market server. Check that the backend is running.';
    }
    
    loading = false;
    notifyListeners();
  }

  // Setters for search and filters
  void setQuery(String value) { 
    query = value; 
    notifyListeners(); 
  }
  
  void setSort(String value) { 
    sort = value; 
    notifyListeners(); 
  }
  
  void setFilter(String value) { 
    filter = value; 
    notifyListeners(); 
  }

  // Get the coins to show on the screen based on search and filters
  List<Coin> get visible {
    String searchQuery = query.toLowerCase();
    
    // First, filter the list
    List<Coin> filteredList = [];
    for (int i = 0; i < coins.length; i++) {
      Coin currentCoin = coins[i];
      String coinNameAndSymbol = (currentCoin.name + currentCoin.symbol).toLowerCase();
      
      // Check if it matches the search query
      bool matchesSearch = coinNameAndSymbol.contains(searchQuery);
      
      // Check if it matches the up/down filter
      bool matchesFilter = false;
      if (filter == 'all') {
        matchesFilter = true;
      } else if (filter == 'up' && currentCoin.change > 0) {
        matchesFilter = true;
      } else if (filter == 'down' && currentCoin.change < 0) {
        matchesFilter = true;
      }
      
      if (matchesSearch && matchesFilter) {
        filteredList.add(currentCoin);
      }
    }
    
    // Helper function to get the value to sort by
    double getSortValue(Coin c) {
      if (sort == 'cap') return c.marketCap;
      if (sort == 'price') return c.price;
      if (sort == 'change') return c.change;
      if (sort == 'volume') return c.volume;
      return 0.0;
    }
    
    // Then, sort the list
    filteredList.sort((a, b) {
      double valueA = getSortValue(a);
      double valueB = getSortValue(b);
      return valueB.compareTo(valueA);
    });
    
    return filteredList;
  }

  // Get only the coins that the user has saved
  List<Coin> get saved {
    List<Coin> savedCoins = [];
    for (int i = 0; i < coins.length; i++) {
      if (watch.contains(coins[i].id)) {
        savedCoins.add(coins[i]);
      }
    }
    return savedCoins;
  }

  // Add or remove a coin from the watchlist
  Future<void> toggle(String id) async {
    bool isAdding = !watch.contains(id);
    
    // Optimistically update the UI
    if (isAdding) {
      watch.add(id);
    } else {
      watch.remove(id);
    }
    notifyListeners();
    
    try {
      // Try to save to backend
      await api.setWatch(id, isAdding);
    } catch (e) {
      print("Failed to toggle watch: $e");
      
      // Revert the change if the API call failed
      if (isAdding) {
        watch.remove(id);
      } else {
        watch.add(id);
      }
      notifyListeners();
    }
  }
}
