import 'package:flutter/material.dart';

import '../../screens.dart';
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Container(
        decoration: const BoxDecoration(color: kBg, gradient: RadialGradient(center: Alignment(0, -0.95), radius: 0.9, colors: [Color(0x2410B981), Color(0x000B0F0D)])),
        child: SafeArea(
          child: Column(
            children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text('Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                 
                ],
              ),
            ),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                children: [
                  // Profile Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.person, color: Colors.white, size: 32),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(color: kSurface, shape: BoxShape.circle),
                                    child: const Icon(Icons.verified, color: kAccent, size: 16),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text('User', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: kAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                                        child: const Text('VIP Tier 3', style: TextStyle(color: kAccent, fontSize: 10, fontWeight: FontWeight.w800)),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Joined Oct 2022', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text('UID: 84920481', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w600)),
                                      const SizedBox(width: 4),
                                      Icon(Icons.copy, color: Colors.white.withOpacity(0.6), size: 12),
                                      const SizedBox(width: 8),
                                      const Text('• ', style: TextStyle(color: kAccent, fontSize: 12)),
                                      const Text('KYC Level 2', style: TextStyle(color: kAccent, fontSize: 12, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
                              child: Icon(Icons.edit, color: Colors.white.withOpacity(0.6), size: 16),
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatColumn('NET WORTH', '\$56,893'),
                            _buildStatColumn('30D PNL', '+24.8%', valueColor: kAccent),
                            _buildStatColumn('WIN RATE', '68.4%', valueColor: kAccent),
                            _buildStatColumn('SECURITY', '96/100', valueColor: kAccent),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Quick Actions Row
                  Row(
                    children: [
                      Expanded(child: _buildQuickAction(Icons.account_balance_wallet, 'Add Money', onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMoneyScreen()));
                      })),
                      const SizedBox(width: 8),
                      Expanded(child: _buildQuickAction(Icons.pie_chart, 'My Trades', onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const MyTradesScreen()));
                      })),
                      const SizedBox(width: 8),
                      Expanded(child: _buildQuickAction(Icons.receipt_long, 'Tax & Rpts')),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader('SECURITY & PROTECTION', trailingText: 'Ultra Secure', trailingColor: kAccent),
                  _buildSectionContainer([
                    _buildListTile(icon: Icons.lock_outline, title: 'Two-Factor Authentication', subtitle: 'Google Authenticator', trailing: _buildBadge('Active', true)),
                    _buildListTile(icon: Icons.fingerprint, title: 'FaceID / Biometric Login', subtitle: 'Instant trade authorization', trailing: _buildToggle(true)),
                    _buildListTile(icon: Icons.shield_outlined, title: 'Anti-Phishing Anti-Spoof', subtitle: 'Code: SAJ***99', hasChevron: true),
                    _buildListTile(icon: Icons.devices, title: 'Device Management', subtitle: '3 Authorized Terminals', hasChevron: true, isLast: true),
                  ]),
                  
                  const SizedBox(height: 24),
                  _buildSectionContainer([
                    _buildListTile(icon: Icons.headset_mic_outlined, title: '24/7 Priority Desk', subtitle: 'Average reply: < 2 minutes', hasChevron: true),
                    _buildListTile(icon: Icons.gavel_outlined, title: 'Terms of Service & Risk Policy', subtitle: '', trailing: const Icon(Icons.open_in_new, color: Colors.grey, size: 16), isLast: true, noSubtitle: true),
                  ]),
                  
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(24)),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.logout, color: Color(0xFFFF4E4E), size: 20),
                        SizedBox(width: 8),
                        Text('Log Out Session', style: TextStyle(color: Color(0xFFFF4E4E), fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                 
                 
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, {Color valueColor = Colors.white}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: valueColor, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildQuickAction(IconData icon, String label, {String? badgeText, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              Icon(icon, color: kAccent, size: 24),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.w600)),
            ],
          ),
          if (badgeText != null)
            Positioned(
              top: -16,
              right: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: kAccent, borderRadius: BorderRadius.circular(10)),
                child: Text(badgeText, style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            )
        ],
      ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {String? trailingText, Color? trailingColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          if (trailingText != null)
            Text(trailingText, style: TextStyle(color: trailingColor ?? Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    bool noSubtitle = false,
    Widget? trailing,
    bool hasChevron = false,
    bool isLast = false,
    String? titleBadge,
    bool titleIndicator = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        if (titleIndicator) ...[
                          const SizedBox(width: 6),
                          Container(width: 6, height: 6, decoration: const BoxDecoration(color: kAccent, shape: BoxShape.circle)),
                        ],
                        if (titleBadge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(color: kAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                            child: Text(titleBadge, style: const TextStyle(color: kAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                        ]
                      ],
                    ),
                    if (!noSubtitle) ...[
                      const SizedBox(height: 2),
                      Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
                    ]
                  ],
                ),
              ),
              if (trailing != null) trailing,
              if (hasChevron) const Icon(Icons.chevron_right, color: Colors.grey, size: 16),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, thickness: 1, color: Colors.white.withOpacity(0.05), indent: 52),
      ],
    );
  }

  Widget _buildBadge(String text, bool active) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: active ? kAccent.withOpacity(0.15) : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (active) ...[
                Container(width: 6, height: 6, decoration: BoxDecoration(color: kAccent, shape: BoxShape.circle)),
                const SizedBox(width: 4),
              ],
              Text(text, style: TextStyle(color: active ? kAccent : Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right, color: Colors.grey, size: 16),
      ],
    );
  }

  Widget _buildOutlineBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildToggle(bool active) {
    return Container(
      width: 44,
      height: 24,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: active ? kAccent : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: active ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: 20,
        height: 20,
        decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
      ),
    );
  }
}

class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({super.key});
  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final _controller = TextEditingController(text: '500');
  String _selectedMethod = 'Apple Pay';

  Widget _buildMethod(String title, String subtitle, IconData icon, Color color) {
    final isSelected = _selectedMethod == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? kAccent.withOpacity(0.1) : kSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? kAccent : kBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? kAccent : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add Money', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Container(
        decoration: const BoxDecoration(color: kBg, gradient: RadialGradient(center: Alignment(0, -0.95), radius: 0.9, colors: [Color(0x2410B981), Color(0x000B0F0D)])),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24.0),
                  children: [
                    const Text('Amount to Deposit', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text('\$', style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: '0.00',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: kBorder, height: 32),
                    const Text('Payment Method', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildMethod('UPI', 'Instant zero-fee transfer', Icons.qr_code_scanner, Colors.greenAccent),
                    _buildMethod('UPI Apps', 'GPay, PhonePe, Paytm', Icons.touch_app, Colors.blueAccent),
                    _buildMethod('Debit / Credit Card', 'Visa, Mastercard, Amex', Icons.credit_card, Colors.purpleAccent),
                    _buildMethod('Bank Transfer (IMPS/NEFT)', 'Usually takes 1-3 hours', Icons.account_balance, Colors.orangeAccent),
                    _buildMethod('Crypto Deposit', 'Deposit via external wallet', Icons.currency_bitcoin, Colors.amber),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => PaymentSimulationScreen(
                          method: _selectedMethod,
                          amount: _controller.text,
                        ),
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccent,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Confirm Deposit', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyTradesScreen extends StatelessWidget {
  const MyTradesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Trades & Stocks', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Container(
        decoration: const BoxDecoration(color: kBg, gradient: RadialGradient(center: Alignment(0, -0.95), radius: 0.9, colors: [Color(0x2410B981), Color(0x000B0F0D)])),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Net Worth', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  const Text('\$56,893', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                        child: const Row(
                          children: [
                            Icon(Icons.trending_up, color: Colors.greenAccent, size: 16),
                            SizedBox(width: 4),
                            Text('+24.8%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const Text('All Time', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Purchased Assets', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildTradeItem('Bitcoin', 'BTC', '0.15 BTC', '\$9,800.00', '+\$1,200.00', true),
            _buildTradeItem('Ethereum', 'ETH', '2.4 ETH', '\$5,400.00', '+\$840.50', true),
            _buildTradeItem('Solana', 'SOL', '15.0 SOL', '\$490.00', '-\$120.00', false),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildTradeItem(String name, String symbol, String holdings, String value, String profit, bool isUp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: kAccent.withOpacity(0.1),
            child: Text(symbol[0], style: const TextStyle(color: kAccent, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Shares: $holdings', style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Text('${isUp ? 'Profit' : 'Loss'}: $profit', style: TextStyle(color: isUp ? Colors.greenAccent : Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class PaymentSimulationScreen extends StatefulWidget {
  final String method;
  final String amount;
  const PaymentSimulationScreen({super.key, required this.method, required this.amount});

  @override
  State<PaymentSimulationScreen> createState() => _PaymentSimulationScreenState();
}

class _PaymentSimulationScreenState extends State<PaymentSimulationScreen> {
  final _pinController = TextEditingController();
  final _cardNumController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();
  String? _selectedUpiApp;
  bool _isProcessing = false;

  void _completePayment() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pop(context); // close payment screen
    Navigator.pop(context); // close add money screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Successfully added \$${widget.amount} via ${widget.method}!')),
    );
  }

  Widget _buildUpiPinView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.security, color: kAccent, size: 48),
          const SizedBox(height: 16),
          Text('Enter UPI PIN for ${widget.method}', style: const TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 32),
          TextField(
            controller: _pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 32, letterSpacing: 24),
            decoration: const InputDecoration(
              hintText: '••••',
              hintStyle: TextStyle(color: Colors.grey, letterSpacing: 24),
              border: InputBorder.none,
            ),
            onChanged: (v) {
              if (v.length == 4 || v.length == 6) _completePayment();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCardView() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Enter Card Details', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        _buildTextField('Card Number', _cardNumController, icon: Icons.credit_card, type: TextInputType.number),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTextField('MM/YY', _expiryController, type: TextInputType.datetime)),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('CVV', _cvvController, type: TextInputType.number, obscure: true)),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField('Cardholder Name', _nameController, type: TextInputType.name),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _completePayment,
          style: ElevatedButton.styleFrom(backgroundColor: kAccent, padding: const EdgeInsets.symmetric(vertical: 16)),
          child: Text('Pay \$${widget.amount}', style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildUpiAppsView() {
    final apps = ['GPay', 'PhonePe', 'Paytm', 'BHIM'];
    if (_selectedUpiApp != null) return _buildUpiPinView();
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(24),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: apps.map((app) => GestureDetector(
        onTap: () => setState(() => _selectedUpiApp = app),
        child: Container(
          decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.touch_app, color: Colors.blueAccent, size: 32),
              const SizedBox(height: 8),
              Text(app, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildGenericTransferView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_balance, color: Colors.orangeAccent, size: 48),
          const SizedBox(height: 24),
          const Text('Transfer Details', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(16)),
            child: const Column(
              children: [
                Text('Account Number: 000123456789', style: TextStyle(color: Colors.white, fontSize: 16)),
                SizedBox(height: 8),
                Text('IFSC / Routing: ABCD0123456', style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _completePayment,
            style: ElevatedButton.styleFrom(backgroundColor: kAccent, padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32)),
            child: const Text('I Have Transferred', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {IconData? icon, TextInputType? type, bool obscure = false}) {
    return TextField(
      controller: controller,
      keyboardType: type,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
        filled: true,
        fillColor: kSurface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (widget.method == 'UPI') {
      body = _buildUpiPinView();
    } else if (widget.method == 'UPI Apps') {
      body = _buildUpiAppsView();
    } else if (widget.method == 'Debit / Credit Card') {
      body = _buildCardView();
    } else {
      body = _buildGenericTransferView();
    }

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator(color: kAccent))
          : body,
    );
  }
}
