import 'package:flutter/material.dart';
import 'package:ledgerly/features/profile/profile_screen.dart';
import 'package:provider/provider.dart';
import 'data.dart';
import 'screens.dart';
import 'state.dart';

const userName = 'user 1';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  String chip = 'Trending';

  String get _greeting {
    final h = DateTime.now().hour;
    return h < 12
        ? 'Good morning!'
        : h < 18
            ? 'Good afternoon!'
            : 'Good evening!';
  }

  Widget _circleButton(IconData icon, String tip, VoidCallback onTap,
          {bool dot = false}) =>
      Stack(children: [
        Material(
          color: kSurface,
          shape: const CircleBorder(side: BorderSide(color: kBorder)),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
                width: 40,
                height: 40,
                child: Icon(icon,
                    size: 18, color: Colors.white70, semanticLabel: tip)),
          ),
        ),
        if (dot)
          Positioned(
            top: 9,
            right: 9,
            child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                    color: kAccentLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: kBg, width: 1.5))),
          ),
      ]);

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final g = s.global;
    final cap = (g['marketCap'] ?? 0).toDouble(),
        vol = (g['volume'] ?? 0).toDouble(),
        ch = (g['change24h'] ?? 0).toDouble();
    final byChange = [...s.coins]..sort((a, b) => b.change.compareTo(a.change));
    final movers = switch (chip) {
      'Favorites' => s.saved,
      'Gainers' => byChange.where((c) => c.change > 0).toList(),
      'Losers' => byChange.reversed.where((c) => c.change < 0).toList(),
      _ => ([...s.coins]..sort((a, b) => b.volume.compareTo(a.volume))),
    }
        .take(6)
        .toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
              center: Alignment(0, -0.95),
              radius: 0.9,
              colors: [Color(0x2410B981), Color(0x000B0F0D)]),
        ),
        child: SafeArea(
          child: StateBody(
            loading: s.loading && s.coins.isEmpty,
            error: s.coins.isEmpty ? s.error : null,
            empty: s.coins.isEmpty,
            emptyTitle: 'No data',
            emptyText: 'Market data is not available yet.',
            onRetry: s.load,
            child: RefreshIndicator(
              onRefresh: s.load,
              child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  children: [
                    // Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_greeting,
                                  style: const TextStyle(
                                      color: kMuted,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 2),
                              const Text('Welcome, User',
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5)),
                            ],
                          ),
                        ),
                        _circleButton(
                            Icons.search, 'Search', () => s.setTab(1)),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const ProfileScreen()));
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: kSurface,
                                border:
                                    Border.all(color: kAccent.withOpacity(.4))),
                            child: Text(userName[0].toUpperCase(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: kAccentLight)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Market summary
                    const Text('TOTAL MARKET CAP',
                        style: TextStyle(
                            color: kMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1)),
                    const SizedBox(height: 6),
                    Text('\$${compact(cap)}',
                        style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1)),
                    const SizedBox(height: 6),
                    Row(children: [
                      Text('24h vol \$${compact(vol)}',
                          style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.fromLTRB(4, 2, 10, 2),
                        decoration: BoxDecoration(
                          color: moveColor(ch).withOpacity(.1),
                          borderRadius: BorderRadius.circular(99),
                          border:
                              Border.all(color: moveColor(ch).withOpacity(.2)),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(
                              ch >= 0
                                  ? Icons.arrow_drop_up
                                  : Icons.arrow_drop_down,
                              size: 18,
                              color: moveColor(ch)),
                          Text(pct(ch),
                              style: TextStyle(
                                  color: moveColor(ch),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ]),
                    const SizedBox(height: 24),
                    // YOUR ASSETS
                    PortfolioDrawer(s.coins),
                    const SizedBox(height: 24),
                    // Live Treemap
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(children: [
                            Icon(Icons.grid_view,
                                color: kAccentLight, size: 18),
                            SizedBox(width: 8),
                            Text('Live Treemap Map',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700)),
                          ]),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                color: const Color(0xFF16251E),
                                borderRadius: BorderRadius.circular(6)),
                            child: const Text('Market Cap',
                                style: TextStyle(
                                    color: kAccentLight,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ]),
                    const SizedBox(height: 16),
                    if (byChange.length >= 4)
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _TreeCard(byChange[0]),
                                  const SizedBox(height: 12),
                                  _TreeCard(byChange[3]),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _TreeCard(byChange[1]),
                                  const SizedBox(height: 12),
                                  _TreeCard(byChange[2]),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    if (byChange.length >= 7)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _TreeCard(byChange[3], mini: true)),
                          const SizedBox(width: 8),
                          Expanded(child: _TreeCard(byChange[4], mini: true)),
                          const SizedBox(width: 8),
                          Expanded(
                              child: _TreeCard(byChange[5],
                                  mini: true, red: true)),
                          const SizedBox(width: 8),
                          Expanded(
                              child: _TreeCard(byChange[6],
                                  mini: true, red: true)),
                        ],
                      ),
                    const SizedBox(height: 24),
                    // Top movers
                    const Text('Top Movers',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: [
                        for (final t in const [
                          'Trending',
                          'Favorites',
                          'Gainers',
                          'Losers'
                        ])
                          GestureDetector(
                            onTap: () => setState(() => chip = t),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 7),
                              decoration: BoxDecoration(
                                color: chip == t
                                    ? const Color(0xFF262626)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(99),
                                border: Border.all(
                                    color: chip == t
                                        ? const Color(0xFF404040)
                                        : Colors.transparent),
                              ),
                              child: Text(t,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          chip == t ? Colors.white : kMuted)),
                            ),
                          ),
                      ]),
                    ),
                    const SizedBox(height: 10),
                    if (movers.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                            child: Text(
                                'Nothing here yet. Star a coin to see it in Favorites.',
                                style: TextStyle(color: kMuted))),
                      )
                    else
                      for (final c in movers)
                        CoinTile(c,
                            showStar: false,
                            margin: const EdgeInsets.only(bottom: 8)),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Action(this.icon, this.label, this.onTap);

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kBorder)),
            child: Icon(icon, size: 22, color: kAccentLight),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70)),
        ]),
      );
}

class _TreeCard extends StatelessWidget {
  final Coin c;
  final bool mini;
  final bool red;
  final bool stretch;
  const _TreeCard(this.c,
      {this.mini = false, this.red = false, this.stretch = false});

  @override
  Widget build(BuildContext context) {
    final bgColor = red ? const Color(0xFF2A1015) : const Color(0xFF0C2417);
    final borderColor = red ? const Color(0xFF45151B) : const Color(0xFF143B25);
    final fgColor = red ? const Color(0xFFFF4E4E) : kAccentLight;

    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => DetailScreen(c))),
      child: Container(
        padding: EdgeInsets.all(mini ? 10 : 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!mini)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    CoinIcon(c, size: 24),
                    const SizedBox(width: 8),
                    Text(c.symbol,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ]),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                        color: fgColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(pct(c.change),
                        style: TextStyle(
                            color: fgColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            if (mini)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Text(c.symbol,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 11))),
                  Text(pct(c.change),
                      style: TextStyle(
                          color: fgColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            if (stretch) const Spacer() else SizedBox(height: mini ? 8 : 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(money(c.price),
                    style: TextStyle(
                        fontSize: mini ? 14 : 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5)),
                if (!mini) const SizedBox(height: 2),
                if (!mini)
                  Text('Cap \$${compact(c.marketCap)}',
                      style: const TextStyle(color: kMuted, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AssetTile extends StatelessWidget {
  final Coin c;
  final double amount;
  final double avgPrice;
  const _AssetTile(
      {required this.c, required this.amount, required this.avgPrice});

  @override
  Widget build(BuildContext context) {
    final currentValue = amount * c.price;
    final costBasis = amount * avgPrice;
    final profit = currentValue - costBasis;
    final profitPct = costBasis == 0 ? 0.0 : (profit / costBasis) * 100;

    return InkWell(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => DetailScreen(c))),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            CoinIcon(c, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text('${amount.toStringAsFixed(4)} ${c.symbol}',
                      style: const TextStyle(color: kMuted, fontSize: 13)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(money(currentValue),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(profit >= 0 ? '▲ ' : '▼ ',
                        style:
                            TextStyle(color: moveColor(profit), fontSize: 10)),
                    Text(
                        '\$${profit.abs().toStringAsFixed(2)} (${profitPct.abs().toStringAsFixed(2)}%)',
                        style: TextStyle(
                            color: moveColor(profit),
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PortfolioDrawer extends StatefulWidget {
  final List<Coin> coins;
  const PortfolioDrawer(this.coins, {super.key});

  @override
  State<PortfolioDrawer> createState() => _PortfolioDrawerState();
}

class _PortfolioDrawerState extends State<PortfolioDrawer> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.coins.isEmpty) return const SizedBox();

    final assets = [
      {'c': widget.coins[0], 'amount': 0.045, 'avg': 58000.0},
      if (widget.coins.length > 1)
        {'c': widget.coins[1], 'amount': 1.24, 'avg': 2800.0},
      if (widget.coins.length > 3)
        {'c': widget.coins[3], 'amount': 450.0, 'avg': 120.0},
    ];

    double totalValue = 0;
    for (final a in assets) {
      totalValue += (a['amount'] as double) * (a['c'] as Coin).price;
    }

    final collage = SizedBox(
      height: 32,
      width: 32.0 + (assets.length - 1) * 20.0,
      child: Stack(
        children: [
          for (var i = 0; i < assets.length; i++)
            Positioned(
              left: i * 20.0,
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: kBg, width: 2)),
                child: CoinIcon(assets[i]['c'] as Coin, size: 28),
              ),
            ),
        ],
      ),
    );

    final pctStrings = assets.map((a) {
      final val = (a['amount'] as double) * (a['c'] as Coin).price;
      final pct = totalValue > 0 ? (val / totalValue) * 100 : 0.0;
      return '${(a['c'] as Coin).symbol} ${pct.toStringAsFixed(0)}%';
    }).join(' • ');

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Your Portfolio',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                      if (!_expanded) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            collage,
                            const SizedBox(width: 16),
                            Expanded(
                                child: Text(pctStrings,
                                    style: const TextStyle(
                                        color: kMuted,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600))),
                          ],
                        ),
                      ]
                    ],
                  ),
                ),
                Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: kMuted),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: 8),
          for (final a in assets)
            _AssetTile(
                c: a['c'] as Coin,
                amount: a['amount'] as double,
                avgPrice: a['avg'] as double),
        ]
      ],
    );
  }
}
