import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data.dart';
import 'state.dart';

const kBg = Color(0xFF0B0F0D), kSurface = Color(0xFF121614), kBorder = Color(0xFF232924);
const kAccent = Color(0xFF10B981), kAccentLight = Color(0xFF34D399), kMuted = Color(0xFF7E8B83);
const upColor = Color(0xFF34D399), downColor = Color(0xFFFF3B30);

class CoinIcon extends StatelessWidget {
  final Coin c;
  final double size;
  const CoinIcon(this.c, {super.key, this.size = 40});
  static const _glyph = {'BTC': '₿', 'ETH': '◆', 'USDT': '₮', 'SOL': '◎'};
  static const _palette = [Color(0xFFF59E0B), Color(0xFF818CF8), Color(0xFF2DD4BF), Color(0xFFC084FC), Color(0xFFF472B6), Color(0xFF60A5FA)];

  @override
  Widget build(BuildContext context) {
    if (c.image != null && c.image!.isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.transparent,
        backgroundImage: NetworkImage(c.image!),
        onBackgroundImageError: (_, __) {},
      );
    }
    final col = _palette[c.symbol.codeUnits.fold<int>(0, (a, b) => a + b) % _palette.length];
    return Container(
      width: size, height: size, alignment: Alignment.center,
      decoration: BoxDecoration(shape: BoxShape.circle, color: col.withOpacity(.2), border: Border.all(color: col.withOpacity(.4))),
      child: Text(_glyph[c.symbol] ?? c.symbol.substring(0, min(2, c.symbol.length)),
          style: TextStyle(color: col, fontWeight: FontWeight.w700, fontSize: size * .36)),
    );
  }
}

String money(double v) => v >= 1
    ? '\$${v.toStringAsFixed(2).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}'
    : '\$${v.toStringAsFixed(4)}';
String compact(double v) => v >= 1e12
    ? '${(v / 1e12).toStringAsFixed(2)}T'
    : v >= 1e9 ? '${(v / 1e9).toStringAsFixed(1)}B' : '${(v / 1e6).toStringAsFixed(1)}M';
Color moveColor(double c) => c >= 0 ? upColor : downColor;
String pct(double c) => '${c >= 0 ? '+' : ''}${c.toStringAsFixed(1)}%';

LineChartData chartData(List<double> ys, Color c, {bool touch = false}) {
  if (ys.isEmpty) return LineChartData();
  final maxV = ys.reduce(max);
  final minV = ys.reduce(min);
  return LineChartData(
    gridData: FlGridData(
      show: touch,
      drawVerticalLine: false,
      horizontalInterval: (maxV - minV) > 0 ? (maxV - minV) : 1,
      getDrawingHorizontalLine: (value) => FlLine(color: Colors.white.withOpacity(0.1), dashArray: [4, 4], strokeWidth: 1),
    ),
    titlesData: FlTitlesData(
      show: touch,
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 64,
          getTitlesWidget: (value, meta) {
            if (value == maxV || value == minV) {
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(money(value), style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w500)),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    ),
    borderData: FlBorderData(show: false),
    lineTouchData: touch
        ? LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots
                  .map((s) => LineTooltipItem(money(s.y), const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)))
                  .toList(),
            ),
          )
        : const LineTouchData(enabled: false),
    lineBarsData: [
      LineChartBarData(
        spots: [for (var i = 0; i < ys.length; i++) FlSpot(i.toDouble(), ys[i])],
        isCurved: true,
        color: c,
        barWidth: 1.2,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [c.withOpacity(touch ? 0.35 : 0.15), c.withOpacity(0.0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    ],
  );
}

/// Handles loading, error and empty states for any list screen.
class StateBody extends StatelessWidget {
  final bool loading, empty;
  final String? error;
  final String emptyTitle, emptyText;
  final VoidCallback onRetry;
  final Widget child;
  const StateBody({super.key, required this.loading, required this.error, required this.empty, required this.emptyTitle,
      required this.emptyText, required this.onRetry, required this.child});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    if (loading) {
      return ListView.builder(
        itemCount: 8,
        itemBuilder: (_, __) => Container(
          height: 56, margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          decoration: BoxDecoration(color: t.colorScheme.surfaceContainerHighest.withOpacity(.6), borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
    if (error != null) {
      return Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.cloud_off, size: 40),
        const SizedBox(height: 12),
        Text("Can't load prices", style: t.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(error!, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        FilledButton(onPressed: onRetry, child: const Text('Retry')),
      ])));
    }
    if (empty) {
      return Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.search_off, size: 40),
        const SizedBox(height: 12),
        Text(emptyTitle, style: t.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(emptyText, textAlign: TextAlign.center),
      ])));
    }
    return child;
  }
}

class MiniStrengthBars extends StatelessWidget {
  final Coin c;
  const MiniStrengthBars(this.c, {super.key});

  @override
  Widget build(BuildContext context) {
    final color = moveColor(c.change);
    final heights = c.change >= 0 ? [4.0, 6.0, 12.0, 16.0] : [6.0, 12.0, 6.0, 4.0];
    final opacities = c.change >= 0 ? [0.4, 0.6, 0.8, 1.0] : [1.0, 0.8, 0.6, 0.4];
    
    return SizedBox(
      height: 20,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(4, (i) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          width: 4,
          height: heights[i],
          decoration: BoxDecoration(
            color: color.withOpacity(opacities[i]),
            borderRadius: BorderRadius.circular(2),
          ),
        )),
      ),
    );
  }
}

class CoinTile extends StatelessWidget {
  final Coin c;
  final bool showStar;
  final EdgeInsets margin;
  const CoinTile(this.c, {super.key, this.showStar = true, this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 4)});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final saved = s.watch.contains(c.id);
    return Container(
      margin: margin,
      decoration: BoxDecoration(color: kSurface.withOpacity(.7), borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(c))),
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, 10, showStar ? 4 : 12, 10),
            child: Row(children: [
              CoinIcon(c),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), overflow: TextOverflow.ellipsis),
                Text(c.symbol, style: const TextStyle(color: kMuted, fontSize: 11)),
              ])),
              Container(
                width: 56, 
                alignment: Alignment.centerRight,
                child: MiniStrengthBars(c),
              ),
              const SizedBox(width: 8),
              SizedBox(width: 84, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(money(c.price), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(c.change >= 0 ? '▲ ' : '▼ ', style: TextStyle(color: moveColor(c.change), fontSize: 9)),
                  Text('${c.change.abs().toStringAsFixed(2)}%', style: TextStyle(color: moveColor(c.change), fontSize: 11, fontWeight: FontWeight.w600)),
                ]),
              ])),
              if (showStar)
                IconButton(
                  tooltip: 'Toggle watchlist',
                  icon: Icon(saved ? Icons.star : Icons.star_border, color: saved ? kAccentLight : kMuted),
                  onPressed: () => s.toggle(c.id),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}

class CoinList extends StatelessWidget {
  final List<Coin> coins;
  const CoinList(this.coins, {super.key});
  @override
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: context.read<AppState>().load,
        child: ListView.builder(itemCount: coins.length, itemBuilder: (_, i) => CoinTile(coins[i])),
      );
}

class MarketsScreen extends StatelessWidget {
  const MarketsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final list = s.visible;
    return Scaffold(
      backgroundColor: kBg,
      body: Container(
        decoration: const BoxDecoration(color: kBg, gradient: RadialGradient(center: Alignment(0, -0.95), radius: 0.9, colors: [Color(0x2410B981), Color(0x000B0F0D)])),
        child: SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text('Markets', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: TextField(
            onChanged: s.setQuery,
            decoration: InputDecoration(
              hintText: 'Search coins', prefixIcon: const Icon(Icons.search), isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            for (final f in const {'all': 'All', 'up': 'Gainers', 'down': 'Losers'}.entries)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(label: Text(f.value), selected: s.filter == f.key, onSelected: (_) => s.setFilter(f.key)),
              ),
            const Spacer(),
            PopupMenuButton<String>(
              icon: const Icon(Icons.sort),
              tooltip: 'Sort',
              initialValue: s.sort,
              onSelected: s.setSort,
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'cap', child: Text('Market cap')),
                PopupMenuItem(value: 'price', child: Text('Price')),
                PopupMenuItem(value: 'change', child: Text('24h change')),
                PopupMenuItem(value: 'volume', child: Text('Volume')),
              ],
            ),
          ]),
        ),
        Expanded(
          child: StateBody(
            loading: s.loading && s.coins.isEmpty,
            error: s.coins.isEmpty ? s.error : null,
            empty: list.isEmpty,
            emptyTitle: 'No coins match "${s.query}"',
            emptyText: 'Try a different name or symbol, or clear the filter.',
            onRetry: s.load,
            child: CoinList(list),
          ),
        ),
          ]),
        ),
      ),
    );
  }
}

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final list = s.saved;
    return Scaffold(
      backgroundColor: kBg,
      body: Container(
        decoration: const BoxDecoration(color: kBg, gradient: RadialGradient(center: Alignment(0, -0.95), radius: 0.9, colors: [Color(0x2410B981), Color(0x000B0F0D)])),
        child: SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text('Watchlist', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StateBody(
        loading: s.loading && s.coins.isEmpty,
        error: s.coins.isEmpty ? s.error : null,
        empty: list.isEmpty,
        emptyTitle: 'No coins yet',
        emptyText: 'Star a coin in Markets to follow it here.',
        onRetry: s.load,
        child: CoinList(list),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  Widget _card(BuildContext context, String k, String v, {Color? color}) => Card(
        margin: EdgeInsets.zero,
        child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(k, style: Theme.of(context).textTheme.bodySmall),
          Text(v, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
        ])),
      );

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final g = s.global;
    final sorted = [...s.coins]..sort((a, b) => b.change.compareTo(a.change));
    final n = min(3, sorted.length);
    Widget group(String title, List<Coin> l) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 4), child: Text(title, style: Theme.of(context).textTheme.titleSmall)),
          for (final c in l) CoinTile(c),
        ]);
    return Scaffold(
      backgroundColor: kBg,
      body: Container(
        decoration: const BoxDecoration(color: kBg, gradient: RadialGradient(center: Alignment(0, -0.95), radius: 0.9, colors: [Color(0x2410B981), Color(0x000B0F0D)])),
        child: SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text('Global Stats', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StateBody(
        loading: s.loading && s.coins.isEmpty,
        error: s.coins.isEmpty ? s.error : null,
        empty: s.coins.isEmpty,
        emptyTitle: 'No data',
        emptyText: 'Market data is not available yet.',
        onRetry: s.load,
        child: RefreshIndicator(
          onRefresh: s.load,
          child: ListView(children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 2.2,
                children: [
                  _card(context, 'Total market cap', '\$${compact((g['marketCap'] ?? 0).toDouble())}'),
                  _card(context, '24h volume', '\$${compact((g['volume'] ?? 0).toDouble())}'),
                  _card(context, 'Bitcoin dominance', '${(g['btcDominance'] ?? 0).toDouble().toStringAsFixed(1)}%'),
                  _card(context, 'Market 24h', pct((g['change24h'] ?? 0).toDouble()), color: moveColor((g['change24h'] ?? 0).toDouble())),
                ],
              ),
            ),
            group('Top gainers', sorted.take(n).toList()),
            group('Top losers', sorted.reversed.take(n).toList()),
          ]),
        ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class DetailScreen extends StatefulWidget {
  final Coin coin;
  const DetailScreen(this.coin, {super.key});
  @override
  State<DetailScreen> createState() => _DetailState();
}

class _DetailState extends State<DetailScreen> {
  String days = '7';
  late Future<List<List<double>>> chart;

  @override
  void initState() {
    super.initState();
    chart = _load();
  }

  Future<List<List<double>>> _load() => context.read<AppState>().api.chart(widget.coin.id, days);

  @override
  Widget build(BuildContext context) {
    final c = widget.coin;
    final s = context.watch<AppState>();
    final saved = s.watch.contains(c.id);
    final up = c.change >= 0;
    const primaryColor = Color(0xFF34D399);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    CircleAvatar(radius: 10, backgroundImage: c.image != null ? NetworkImage(c.image!) : null),
                    const SizedBox(width: 8),
                    Text(c.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                  ]),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(saved ? Icons.star : Icons.star_border, color: saved ? primaryColor : Colors.grey),
                  onPressed: () => s.toggle(c.id),
                  style: IconButton.styleFrom(backgroundColor: const Color(0xFF1E1E1E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ],
            ),
            const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF23352D), Color(0xFF121212)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF2C3E36), width: 1),
            ),
            child: Column(children: [
              Text('${c.symbol} =', style: const TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(money(c.price), style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1.5)),
              const SizedBox(height: 12),
              Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(up ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: primaryColor, size: 24),
                Text(pct(c.change), style: const TextStyle(color: primaryColor, fontWeight: FontWeight.w600, fontSize: 16)),
              ]),
            ]),
          ),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            for (final r in const {'1': '1D', '7': '1W', '30': '1M', '365': '1Y'}.entries)
              GestureDetector(
                onTap: () => setState(() { days = r.key; chart = _load(); }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: days == r.key ? const Color(0xFF2C2C2C) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(r.value, style: TextStyle(color: days == r.key ? primaryColor : Colors.grey, fontWeight: FontWeight.w600)),
                ),
              ),
          ]),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: FutureBuilder<List<List<double>>>(
              future: chart,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator(color: primaryColor));
                if (snap.hasError || (snap.data ?? []).isEmpty) {
                  return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('Chart unavailable', style: TextStyle(color: Colors.white)),
                    TextButton(onPressed: () => setState(() => chart = _load()), child: const Text('Retry', style: TextStyle(color: primaryColor))),
                  ]));
                }
                final ys = snap.data!.map((p) => p[1]).toList();
                return LineChart(chartData(ys, primaryColor, touch: true));
              },
            ),
          ),
          const SizedBox(height: 32),
          const BuySellPressureBar(),
          const SizedBox(height: 32),
          const RecentTradesList(),
          const SizedBox(height: 32),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('AI Suggestion', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)), child: const Text('24% ETH -> BTC', style: TextStyle(color: Colors.white))),
          ]),
          const SizedBox(height: 32),
          MarketDepthWidget(c),
          const SizedBox(height: 32),
          PerformanceWidget(c),
        ],
      ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
        ),
        child: Row(
          children: [
            Expanded(child: ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TradeScreen(coin: c, isBuy: true))), style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: Text('Buy ${c.symbol}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)))),
            const SizedBox(width: 16),
            Expanded(child: ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TradeScreen(coin: c, isBuy: false))), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF4E4E), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: Text('Sell ${c.symbol}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)))),
          ],
        ),
      ),
    );
  }
}

class MarketDepthWidget extends StatelessWidget {
  final Coin c;
  const MarketDepthWidget(this.c, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = c.price;
    final bids = [
      {'p': (p * 0.9998).toStringAsFixed(2), 'q': '1', 'r': 0.0},
      {'p': (p * 0.9996).toStringAsFixed(2), 'q': '3', 'r': 0.0},
      {'p': (p * 0.9994).toStringAsFixed(2), 'q': '23', 'r': 0.0},
      {'p': (p * 0.9992).toStringAsFixed(2), 'q': '7', 'r': 0.0},
      {'p': (p * 0.9990).toStringAsFixed(2), 'q': '600', 'r': 0.7},
    ];
    final asks = [
      {'p': (p * 1.0002).toStringAsFixed(2), 'q': '3,389', 'r': 0.3},
      {'p': (p * 1.0004).toStringAsFixed(2), 'q': '2', 'r': 0.0},
      {'p': (p * 1.0006).toStringAsFixed(2), 'q': '4', 'r': 0.0},
      {'p': (p * 1.0008).toStringAsFixed(2), 'q': '451', 'r': 0.1},
      {'p': (p * 1.0010).toStringAsFixed(2), 'q': '13,217', 'r': 0.9},
    ];

    Widget _qty(String text, bool isBid, double ratio) {
      final color = isBid ? upColor : downColor;
      return Expanded(
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            if (ratio > 0)
              FractionallySizedBox(
                widthFactor: ratio,
                child: Container(
                  height: 18,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(text, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
    }

    Widget _row(Map<String, dynamic> bid, Map<String, dynamic> ask) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(child: Text(bid['p'], style: const TextStyle(color: Colors.white, fontSize: 13))),
            _qty(bid['q'], true, bid['r'] as double),
            const SizedBox(width: 8),
            Container(width: 1, height: 14, color: Colors.white10),
            const SizedBox(width: 8),
            Expanded(child: Text(ask['p'], style: const TextStyle(color: Colors.white, fontSize: 13))),
            _qty(ask['q'], false, ask['r'] as double),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Market depth', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            Icon(Icons.keyboard_arrow_up, color: Colors.grey),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Buy orders', style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text('Sell orders', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('43.34%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text('56.66%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(flex: 4334, child: Container(height: 4, color: upColor)),
            Expanded(flex: 5666, child: Container(height: 4, color: downColor)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: const [
            Expanded(child: Text('Bid price', style: TextStyle(color: Colors.grey, fontSize: 12))),
            Expanded(child: Text('Qty', textAlign: TextAlign.right, style: TextStyle(color: Colors.grey, fontSize: 12))),
            SizedBox(width: 17),
            Expanded(child: Text('Ask price', style: TextStyle(color: Colors.grey, fontSize: 12))),
            Expanded(child: Text('Qty', textAlign: TextAlign.right, style: TextStyle(color: Colors.grey, fontSize: 12))),
          ],
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < 5; i++) _row(bids[i], asks[i]),
        const SizedBox(height: 12),
        Row(
          children: const [
            Expanded(child: Text('Bid total', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))),
            Expanded(child: Text('13,22,756', textAlign: TextAlign.right, style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))),
            SizedBox(width: 17),
            Expanded(child: Text('Ask total', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))),
            Expanded(child: Text('17,29,373', textAlign: TextAlign.right, style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))),
          ],
        ),
      ],
    );
  }
}

class PerformanceWidget extends StatelessWidget {
  final Coin c;
  const PerformanceWidget(this.c, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text('Performance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(width: 8),
            Icon(Icons.info_outline, color: Colors.grey, size: 16),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Today's Low", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Text((c.price * 0.95).toStringAsFixed(2), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text("Today's High", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Text((c.price * 1.08).toStringAsFixed(2), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: upColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Positioned(
              left: 140,
              top: 4,
              child: Icon(Icons.arrow_drop_up, color: Colors.white, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("52 Week Low", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text("52 Week High", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class TradeScreen extends StatefulWidget {
  final Coin coin;
  final bool isBuy;
  const TradeScreen({super.key, required this.coin, required this.isBuy});

  @override
  State<TradeScreen> createState() => _TradeState();
}

class _TradeState extends State<TradeScreen> {
  String amount = '0';
  
  void _append(String v) {
    setState(() {
      if (amount == '0' && v != '.') amount = v;
      else if (v == '.' && amount.contains('.')) return;
      else amount += v;
    });
  }

  void _backspace() {
    setState(() {
      if (amount.length > 1) amount = amount.substring(0, amount.length - 1);
      else amount = '0';
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isBuy ? const Color(0xFF34D399) : const Color(0xFFFF4E4E);
    final actionText = widget.isBuy ? 'Buy' : 'Sell';
    final parsed = double.tryParse(amount) ?? 0;
    
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text('$actionText ${widget.coin.name}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Text(widget.isBuy ? 'You are buying' : 'You are selling', style: const TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.isBuy ? '\$' : widget.coin.symbol + ' ', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.grey)),
                Text(amount, style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -2)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.isBuy 
                ? '≈ ${(widget.coin.price > 0 ? (parsed / widget.coin.price) : 0.0).toStringAsFixed(6)} ${widget.coin.symbol}' 
                : '≈ \$${(parsed * widget.coin.price).toStringAsFixed(2)}', 
              style: const TextStyle(color: Colors.grey, fontSize: 16)
            ),
            const Spacer(),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              childAspectRatio: 2,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (var i = 1; i <= 9; i++) 
                  TextButton(onPressed: () => _append(i.toString()), child: Text(i.toString(), style: const TextStyle(fontSize: 28, color: Colors.white))),
                TextButton(onPressed: () => _append('.'), child: const Text('.', style: TextStyle(fontSize: 28, color: Colors.white))),
                TextButton(onPressed: () => _append('0'), child: const Text('0', style: TextStyle(fontSize: 28, color: Colors.white))),
                IconButton(onPressed: _backspace, icon: const Icon(Icons.backspace_outlined, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: parsed > 0 ? () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Order placed to ${widget.isBuy ? 'buy' : 'sell'} $amount ${widget.isBuy ? 'USD of ' : ''}${widget.coin.name}!'),
                      backgroundColor: color,
                      behavior: SnackBarBehavior.floating,
                    ));
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    disabledBackgroundColor: color.withOpacity(0.3),
                    foregroundColor: widget.isBuy ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text('Review $actionText', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class SelectCoinScreen extends StatelessWidget {
  final bool isBuy;
  final List<Coin> coins;
  const SelectCoinScreen({super.key, required this.isBuy, required this.coins});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(isBuy ? 'Buy Asset' : 'Sell Asset',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: coins.length,
        itemBuilder: (ctx, i) {
          final c = coins[i];
          return ListTile(
            leading: CoinIcon(c, size: 36),
            title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Text(c.symbol, style: const TextStyle(color: Colors.grey)),
            trailing: Text(money(c.price), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TradeScreen(coin: c, isBuy: isBuy)));
            },
          );
        },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BuySellPressureBar extends StatelessWidget {
  const BuySellPressureBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Buy/Sell Pressure', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('Live', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 62,
              child: Container(
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF34D399),
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(4)),
                ),
              ),
            ),
            const SizedBox(width: 2),
            Expanded(
              flex: 38,
              child: Container(
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF4E4E),
                  borderRadius: BorderRadius.horizontal(right: Radius.circular(4)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('62% Buy', style: TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.w600)),
            Text('38% Sell', style: TextStyle(color: Color(0xFFFF4E4E), fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}

class RecentTradesList extends StatelessWidget {
  const RecentTradesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Trades', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        for (var i = 0; i < 5; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(i % 2 == 0 ? 'Buy' : 'Sell', style: TextStyle(color: i % 2 == 0 ? const Color(0xFF34D399) : const Color(0xFFFF4E4E), fontWeight: FontWeight.bold)),
                const Text('0.045', style: TextStyle(color: Colors.white)),
                Text(i == 0 ? 'Just now' : '${i * 2}m ago', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
      ],
    );
    
  }
}

