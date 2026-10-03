import 'dart:convert';
import 'package:http/http.dart' as http;

// Helper function to safely convert dynamic values to double
double convertToDouble(dynamic value) {
  if (value == null) {
    return 0.0;
  }
  return value.toDouble();
}

class Coin {
  final String id;
  final String name;
  final String symbol;
  final String? image;
  final double price;
  final double change;
  final double volume;
  final double marketCap;
  final double circulating;
  final double? maxSupply;
  final List<double> spark;

  // Constructor
  Coin({
    required this.id,
    required this.name,
    required this.symbol,
    this.image,
    required this.price,
    required this.change,
    required this.volume,
    required this.marketCap,
    required this.circulating,
    this.maxSupply,
    required this.spark,
  });

  // Factory constructor to create a Coin object from JSON data
  factory Coin.fromJson(Map<String, dynamic> json) {
    // Safely parse the max supply
    double? parsedMaxSupply;
    if (json['max_supply'] != null) {
      parsedMaxSupply = convertToDouble(json['max_supply']);
    }

    // Safely parse the sparkline data
    List<double> parsedSparkline = [];
    if (json['sparkline_in_7d'] != null && json['sparkline_in_7d']['price'] != null) {
      List<dynamic> rawPrices = json['sparkline_in_7d']['price'];
      for (int i = 0; i < rawPrices.length; i++) {
        parsedSparkline.add(convertToDouble(rawPrices[i]));
      }
    }

    return Coin(
      id: json['id'],
      name: json['name'],
      symbol: (json['symbol'] as String).toUpperCase(),
      image: json['image'],
      price: convertToDouble(json['current_price']),
      change: convertToDouble(json['price_change_percentage_24h']),
      volume: convertToDouble(json['total_volume']),
      marketCap: convertToDouble(json['market_cap']),
      circulating: convertToDouble(json['circulating_supply']),
      maxSupply: parsedMaxSupply,
      spark: parsedSparkline,
    );
  }
}

class Api {
  // Direct CoinGecko API URL
  static const String baseUrl = String.fromEnvironment('API', defaultValue: 'https://api.coingecko.com/api/v3');

  // Generic method to make GET requests to the API
  Future<dynamic> getRequest(String path) async {
    Uri url = Uri.parse('$baseUrl$path');
    
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 12));
      
      if (response.statusCode != 200) {
        throw Exception('Server error: received status code ${response.statusCode}');
      }
      
      return jsonDecode(response.body);
    } catch (e) {
      print('Error making GET request to $path: $e');
      rethrow;
    }
  }

  // Fetch the list of coins
  Future<List<Coin>> coins() async {
    dynamic responseData = await getRequest('/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=true');
    
    List<dynamic> jsonList = responseData as List<dynamic>;
    List<Coin> coinList = [];
    
    for (int i = 0; i < jsonList.length; i++) {
      Map<String, dynamic> coinJson = jsonList[i] as Map<String, dynamic>;
      Coin parsedCoin = Coin.fromJson(coinJson);
      coinList.add(parsedCoin);
    }
    
    return coinList;
  }

  // Fetch global market data
  Future<Map<String, dynamic>> global() async {
    dynamic responseData = await getRequest('/global');
    Map<String, dynamic> globalData = responseData['data'];
    
    return {
      'marketCap': convertToDouble(globalData['total_market_cap']['usd']),
      'volume': convertToDouble(globalData['total_volume']['usd']),
      'btcDominance': convertToDouble(globalData['market_cap_percentage']['btc']),
      'change24h': convertToDouble(globalData['market_cap_change_percentage_24h_usd']),
    };
  }

  // Fetch chart data for a specific coin
  Future<List<List<double>>> chart(String coinId, String days) async {
    dynamic responseData = await getRequest('/coins/$coinId/market_chart?vs_currency=usd&days=$days');
    
    List<dynamic> pricesList = responseData['prices'] as List<dynamic>;
    List<List<double>> formattedChartData = [];
    
    for (int i = 0; i < pricesList.length; i++) {
      List<dynamic> point = pricesList[i];
      double timestamp = convertToDouble(point[0]);
      double price = convertToDouble(point[1]);
      
      formattedChartData.add([timestamp, price]);
    }
    
    return formattedChartData;
  }

  // Without a backend, we just return an empty watchlist and save it in memory (AppState)
  Future<List<String>> watchlist() async {
    return [];
  }

  // Set whether a coin is on the watchlist
  Future<void> setWatch(String coinId, bool isOn) async {
    // Simulate network delay for UI consistency
    await Future.delayed(const Duration(milliseconds: 200));
    print('Simulated setting watch for $coinId to $isOn');
  }
}
