import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home.dart';
import 'screens.dart';
import 'state.dart';

void main() => runApp(ChangeNotifierProvider(create: (_) => AppState()..load(), child: const App()));

class App extends StatelessWidget {
  const App({super.key});

  ThemeData get _theme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBg,
        colorScheme: ColorScheme.fromSeed(seedColor: kAccent, brightness: Brightness.dark).copyWith(primary: kAccent, surface: kBg),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0, scrolledUnderElevation: 0),
        cardTheme: CardThemeData(
          color: kSurface, elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: kBorder)),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.transparent, selectedColor: const Color(0xFF262626), showCheckmark: false,
          side: const BorderSide(color: kBorder), shape: const StadiumBorder(),
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true, fillColor: kSurface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kBorder)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kBorder)),
        ),
      );

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Ledgerly',
        debugShowCheckedModeBanner: false,
        theme: _theme,
        home: const Shell(),
      );
}

class Shell extends StatelessWidget {
  const Shell({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Scaffold(
      body: IndexedStack(index: s.tab, children: const [HomeScreen(), MarketsScreen(), StatsScreen(), WatchlistScreen()]),
      bottomNavigationBar: BottomAppBar(
        color: kSurface,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 72,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navBtn(0, Icons.home_outlined, Icons.home, 'Home', s),
            _navBtn(1, Icons.bar_chart, Icons.bar_chart, 'Markets', s),
            _navBtn(2, Icons.stacked_line_chart, Icons.stacked_line_chart, 'Stocks', s),
            _navBtn(3, Icons.star_border, Icons.star, 'Watchlist', s),
          ],
        ),
      ),
    );
  }

  Widget _navBtn(int idx, IconData off, IconData on, String label, AppState s) {
    final sel = s.tab == idx;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => s.setTab(idx),
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(sel ? on : off, size: 26, color: sel ? kAccentLight : kMuted),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: sel ? kAccentLight : kMuted)),
          ],
        ),
      ),
    );
  }

  void _showTradeSheet(BuildContext context, AppState s) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              const Text('Trade', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _tradeAction(context, s, true, 'Buy', Icons.add, const Color(0xFF34D399)),
                  _tradeAction(context, s, false, 'Sell', Icons.remove, const Color(0xFFFF4E4E)),
                  _tradeAction(context, s, true, 'Convert', Icons.swap_horiz, Colors.blueAccent),
                ],
              ),
              const SizedBox(height: 48),
            ],
          ),
        );
      },
    );
  }

  Widget _tradeAction(BuildContext context, AppState s, bool isBuy, String label, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        if (s.coins.isNotEmpty) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => SelectCoinScreen(coins: s.coins, isBuy: isBuy)));
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
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
