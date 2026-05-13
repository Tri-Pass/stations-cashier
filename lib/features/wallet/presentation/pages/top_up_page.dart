import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/wallet/presentation/widgets/wallet_flow_shared.dart';

class TopUpPage extends StatefulWidget {
  const TopUpPage({super.key});

  @override
  State<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  int _step = 0;
  WalletOption? _selectedMethod;
  double _amount = 0;
  final _amountCtrl = TextEditingController();
  bool _loading = false;
  bool _loadingOptions = true;
  List<WalletOption> _options = [];
  String? _error;
  String? _resultUrl;
  bool _noUrlSuccess = false;

  @override
  void initState() {
    super.initState();
    _fetchOptions();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchOptions() async {
    setState(() {
      _loadingOptions = true;
      _error = null;
    });
    try {
      // TODO: GET /api/cashier/wallet/options?type=topup
      await Future.delayed(const Duration(milliseconds: 400));
      setState(() {
        _options = [
          const WalletOption(
              reqType: 1, code: 'guichet_qr', label: 'Guichet (QR)'),
          const WalletOption(
              reqType: 2, code: 'bank', label: 'Virement bancaire'),
        ];
        _loadingOptions = false;
      });
    } catch (e) {
      setState(() {
        _loadingOptions = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // TODO: POST /api/cashier/wallet/increase { amount, reqType }
      await Future.delayed(const Duration(milliseconds: 600));
      setState(() {
        _noUrlSuccess = true;
        _step = 3;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  bool get _canProceed {
    if (_step == 0) return _selectedMethod != null;
    if (_step == 1) return _amount > 0;
    return true;
  }

  Future<void> _next() async {
    if (_step == 2) {
      final ok = await showWalletPasswordSheet(context);
      if (ok && mounted) _submit();
      return;
    }
    setState(() => _step++);
  }

  void _back() {
    if (_step == 0) {
      context.pop();
      return;
    }
    setState(() {
      _step--;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = AppColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: c.textPrimary, size: 18),
          onPressed: _step == 3 ? () => context.pop() : _back,
        ),
        title: Text(l.topUpWalletTitle,
            style: TextStyle(
                color: c.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: Column(children: [
          if (_step < 3) WalletStepDots(step: _step, total: 3),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildStep(l, c),
            ),
          ),
          if (_step < 3)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(children: [
                if (_error != null) walletErrorBanner(_error!),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed:
                        (_canProceed && !_loading && !_loadingOptions)
                            ? _next
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.teal,
                      disabledBackgroundColor: c.surface,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text(
                            _step == 2
                                ? l.confirmTopUpBtn
                                : l.continueBtn,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                  ),
                ),
              ]),
            ),
        ]),
      ),
    );
  }

  Widget _buildStep(AppLocalizations l, AppColors c) {
    switch (_step) {
      case 0:
        return _buildMethodStep(l, c);
      case 1:
        return _buildAmountStep(l, c);
      case 2:
        return _buildConfirmStep(l);
      case 3:
        return _buildResultStep(l);
      default:
        return const SizedBox();
    }
  }

  Widget _buildMethodStep(AppLocalizations l, AppColors c) {
    if (_loadingOptions) {
      return const Center(
          child: Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: CircularProgressIndicator(color: AppColors.primary),
      ));
    }
    if (_options.isEmpty) {
      return Center(
          child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(children: [
          Text(_error ?? l.noResults,
              style: TextStyle(color: c.textSecondary, fontSize: 14)),
          const SizedBox(height: 16),
          TextButton(
              onPressed: _fetchOptions,
              child: Text(l.retry,
                  style: const TextStyle(color: AppColors.primary))),
        ]),
      ));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l.chooseTopUpMethod,
          style: TextStyle(
              color: c.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text(l.howToTopUp,
          style: TextStyle(color: c.textSecondary, fontSize: 14)),
      const SizedBox(height: 24),
      ..._options.map((o) => _OptionCard(
            option: o,
            selected: identical(_selectedMethod, o),
            onTap: () => setState(() => _selectedMethod = o),
          )),
    ]);
  }

  Widget _buildAmountStep(AppLocalizations l, AppColors c) {
    final methodName = walletOptionName(context, _selectedMethod!);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l.topUpAmountTitle,
          style: TextStyle(
              color: c.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text('${l.modeSubLabel}$methodName',
          style: TextStyle(color: c.textSecondary, fontSize: 14)),
      const SizedBox(height: 32),
      Center(
        child: Text('${_amount.toStringAsFixed(0)} MAD',
            style: TextStyle(
                color: c.textPrimary,
                fontSize: 48,
                fontWeight: FontWeight.bold)),
      ),
      const SizedBox(height: 24),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: walletAmountPresets
            .map((p) => WalletPresetChip(
                  amount: p,
                  selected: _amount == p,
                  onTap: () {
                    setState(() => _amount = p.toDouble());
                    _amountCtrl.text = p.toString();
                  },
                ))
            .toList(),
      ),
      const SizedBox(height: 20),
      walletInputField(
        controller: _amountCtrl,
        hint: l.otherAmount,
        icon: Icons.payments_outlined,
        keyboardType: const TextInputType.numberWithOptions(decimal: false),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (v) =>
            setState(() => _amount = double.tryParse(v) ?? 0),
      ),
    ]);
  }

  Widget _buildConfirmStep(AppLocalizations l) {
    final opt = _selectedMethod!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l.confirmTopUp,
          style: TextStyle(
              color: AppColors.of(context).textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold)),
      const SizedBox(height: 24),
      walletSummaryTile(l.modeLabel, walletOptionName(context, opt),
          walletOptionIcon(opt), walletOptionColor(opt)),
      const SizedBox(height: 12),
      walletSummaryTile(l.amountLabel, '${_amount.toStringAsFixed(0)} MAD',
          Icons.payments_outlined, AppColors.teal),
    ]);
  }

  Widget _buildResultStep(AppLocalizations l) {
    if (_noUrlSuccess || _resultUrl == null || _resultUrl!.isEmpty) {
      return WalletResultBanner(
        icon: Icons.check_circle,
        color: AppColors.teal,
        title: l.topUpSentTitle,
        subtitle: l.topUpSentSubtitle,
        onDone: () => context.pop(true),
      );
    }
    final methodKey =
        '${_selectedMethod?.code ?? ''} ${_selectedMethod?.label ?? ''}'
            .toLowerCase();
    final isQr =
        methodKey.contains('qr') || methodKey.contains('guichet');
    return WalletUrlResultCard(
      url: _resultUrl!,
      title: isQr ? l.qrTopUpTitle : l.paymentLinkTitle,
      subtitle: isQr ? l.qrTopUpSubtitle : l.cardLinkSubtitle,
      onDone: () => context.pop(true),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final WalletOption option;
  final bool selected;
  final VoidCallback onTap;
  const _OptionCard(
      {required this.option, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = walletOptionColor(option);
    final icon = walletOptionIcon(option);
    final name = walletOptionName(context, option);
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.1) : c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? color : c.border,
              width: selected ? 1.5 : 1),
        ),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Text(name,
                  style: TextStyle(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15))),
          if (selected) Icon(Icons.check_circle, color: color, size: 20),
        ]),
      ),
    );
  }
}
