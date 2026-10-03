import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home.dart';
import 'screens.dart';
import 'state.dart';

void main() {
  AppState appState = AppState();
  
  // Load data immediately when the app starts
  appState.load();
  
  // Start the Flutter app and provide the state to all widgets
  runApp(
    ChangeNotifierProvider(
      create: (context) {
        return appState;
      },
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  // Helper method to create the dark theme
  ThemeData buildAppTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: kBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kAccent, 
        brightness: Brightness.dark
      ).copyWith(
        primary: kAccent, 
        surface: kBg
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent, 
        elevation: 0, 
        scrolledUnderElevation: 0
      ),
      cardTheme: CardThemeData(
        color: kSurface, 
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), 
          side: const BorderSide(color: kBorder)
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent, 
        selectedColor: const Color(0xFF262626), 
        showCheckmark: false,
        side: const BorderSide(color: kBorder), 
        shape: const StadiumBorder(),
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, 
        fillColor: kSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), 
          borderSide: const BorderSide(color: kBorder)
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), 
          borderSide: const BorderSide(color: kBorder)
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ledgerly',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const Shell(),
    );
  }
}

class Shell extends StatelessWidget {
  const Shell({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the AppState for changes
    AppState appState = context.watch<AppState>();
    
    return Scaffold(
      body: IndexedStack(
        index: appState.tab, 
        children: const [
          HomeScreen(), 
          MarketsScreen(), 
          StatsScreen(), 
          WatchlistScreen()
        ]
      ),
      bottomNavigationBar: BottomAppBar(
        color: kSurface,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 72,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildNavButton(0, Icons.home_outlined, Icons.home, 'Home', appState),
            buildNavButton(1, Icons.bar_chart, Icons.bar_chart, 'Markets', appState),
            buildNavButton(2, Icons.stacked_line_chart, Icons.stacked_line_chart, 'Stocks', appState),
            buildNavButton(3, Icons.star_border, Icons.star, 'Watchlist', appState),
          ],
        ),
      ),
    );
  }

  // Helper method to build navigation buttons
  Widget buildNavButton(int tabIndex, IconData offIcon, IconData onIcon, String label, AppState appState) {
    bool isSelected = appState.tab == tabIndex;
    
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        appState.setTab(tabIndex);
      },
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? onIcon : offIcon, 
              size: 26, 
              color: isSelected ? kAccentLight : kMuted
            ),
            const SizedBox(height: 4),
            Text(
              label, 
              style: TextStyle(
                fontSize: 10, 
                fontWeight: FontWeight.w600, 
                color: isSelected ? kAccentLight : kMuted
              )
            ),
          ],
        ),
      ),
    );
  }

  // Shows the bottom sheet when trying to trade
  void showTradeSheet(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, 
                height: 4, 
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3), 
                  borderRadius: BorderRadius.circular(2)
                )
              ),
              const SizedBox(height: 24),
              const Text(
                'Trade', 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildTradeAction(context, appState, true, 'Buy', Icons.add, const Color(0xFF34D399)),
                  buildTradeAction(context, appState, false, 'Sell', Icons.remove, const Color(0xFFFF4E4E)),
                  buildTradeAction(context, appState, true, 'Convert', Icons.swap_horiz, Colors.blueAccent),
                ],
              ),
              const SizedBox(height: 48),
            ],
          ),
        );
      },
    );
  }

  // Helper method to build each trade action button
  Widget buildTradeAction(BuildContext context, AppState appState, bool isBuy, String label, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        // Close the bottom sheet first
        Navigator.pop(context);
        
        // Then go to the selection screen if we have coins loaded
        if (appState.coins.isNotEmpty) {
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) {
                return SelectCoinScreen(coins: appState.coins, isBuy: isBuy);
              }
            )
          );
        }
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label, 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
          ),
        ],
      ),
    );
  }
}
