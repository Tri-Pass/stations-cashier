import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:cashier/core/constants/api_endpoints.dart';
import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/network/api_client.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/wallet/presentation/widgets/wallet_flow_shared.dart';

enum _WithdrawFlow { desk, bank, cashplus }

_WithdrawFlow _flowFor(WalletOption o) {
  if (o.reqType == 'rib') return _WithdrawFlow.bank;
  if (o.reqType == 'cashplus') return _WithdrawFlow.cashplus;
  return _WithdrawFlow.desk;
}

class WithdrawPage extends StatefulWidget {
  const WithdrawPage({super.key});

  @override
  State<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  int _step = 0;
  WalletOption? _selectedOption;
  double _amount = 0;
  final _amountCtrl = TextEditingController();
  final _ribCtrl = TextEditingController();
  final _benefCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _motifCtrl = TextEditingController();
  bool _loading = false;
  bool _loadingOptions = true;
  List<WalletOption> _options = [];
  String? _error;
  String? _resultUrl;

  @override
  void initState() {
    super.initState();
    _fetchOptions();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _ribCtrl.dispose();
    _benefCtrl.dispose();
    _phoneCtrl.dispose();
    _motifCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchOptions() async {
    setState(() {
      _loadingOptions = true;
      _error = null;
    });
    try {
      final res = await GetIt.instance<ApiClient>()
          .get(ApiEndpoints.walletOptions('withdraw'));
      final list = (res['data'] as List?) ?? [];
      setState(() {
        _options = list
            .map((e) => WalletOption.fromJson(e as Map<String, dynamic>))
            .toList();
        _loadingOptions = false;
      });
    } catch (e) {
      setState(() {
        _loadingOptions = false;
        _error = e.toString();
      });
    }
  }

  _WithdrawFlow? get _flow =>
      _selectedOption == null ? null : _flowFor(_selectedOption!);
  bool get _hasCredentialsStep =>
      _flow == _WithdrawFlow.bank || _flow == _WithdrawFlow.cashplus;
  int get _totalSteps => _hasCredentialsStep ? 4 : 3;
  int get _confirmStep => _hasCredentialsStep ? 3 : 2;
  int get _resultStep => _confirmStep + 1;

  bool get _canProceed {
    if (_step == 0) return _selectedOption != null;
    if (_step == 1) return _amount > 0;
    if (_step == 2 && _hasCredentialsStep) {
      if (_flow == _WithdrawFlow.bank) {
        return _ribCtrl.text.trim().isNotEmpty &&
            _benefCtrl.text.trim().isNotEmpty;
      }
      if (_flow == _WithdrawFlow.cashplus) {
        return _phoneCtrl.text.trim().isNotEmpty;
      }
    }
    return true;
  }

  Future<void> _next() async {
    final isConfirmStep = _step == (_totalSteps - 1);
    if (isConfirmStep) {
      final pin = await showWalletPasswordSheet(context);
      if (pin != null && mounted) _submit(pin);
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

  Future<void> _submit(String pin) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final body = <String, dynamic>{
        'amount': _amount.toInt(),
        'option': _selectedOption!.code,
        'code_pin': pin,
      };
      if (_flow == _WithdrawFlow.bank) {
        body['beneficiary'] = _benefCtrl.text.trim();
        body['rib'] = _ribCtrl.text.trim();
      } else if (_flow == _WithdrawFlow.cashplus) {
        body['phone'] = _phoneCtrl.text.trim();
        if (_motifCtrl.text.trim().isNotEmpty) {
          body['motif'] = _motifCtrl.text.trim();
        }
      }
      final res = await GetIt.instance<ApiClient>()
          .post(ApiEndpoints.walletWithdraw, body);
      final url = (res['data'] as Map?)?['url'] as String?;
      setState(() {
        _resultUrl = url;
        _step++;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
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
          onPressed: _step == _resultStep ? () => context.pop(true) : _back,
        ),
        title: Text(l.withdraw,
            style: TextStyle(
                color: c.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: Column(children: [
          if (_step < _resultStep)
            WalletStepDots(step: _step, total: _totalSteps),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildStep(l, c),
            ),
          ),
          if (_step < _resultStep)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(children: [
                if (_error != null) walletErrorBanner(_error!),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: (_canProceed && !_loading && !_loadingOptions)
                        ? _next
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
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
                                color: Colors.black, strokeWidth: 2))
                        : Text(
                            _step == _confirmStep
                                ? l.confirmWithdrawBtn
                                : l.continueBtn,
                            style: const TextStyle(
                                color: Colors.black,
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
    if (_step == 0) return _buildMethodStep(l, c);
    if (_step == 1) return _buildAmountStep(l, c);
    if (_step == 2 && _hasCredentialsStep) return _buildCredentialsStep(l, c);
    if (_step == _confirmStep) return _buildConfirmStep(l);
    return _buildResultStep(l);
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
          Text(l.noResults,
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
      Text(l.withdrawMethod,
          style: TextStyle(
              color: c.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text(l.howToWithdraw,
          style: TextStyle(color: c.textSecondary, fontSize: 14)),
      const SizedBox(height: 24),
      ..._options.map((o) => _OptionCard(
            option: o,
            selected: identical(_selectedOption, o),
            onTap: () => setState(() => _selectedOption = o),
          )),
    ]);
  }

  Widget _buildAmountStep(AppLocalizations l, AppColors c) {
    final name = walletOptionName(context, _selectedOption!);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l.withdrawAmountTitle,
          style: TextStyle(
              color: c.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text('${l.modeSubLabel}$name',
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
          onChanged: (v) => setState(() => _amount = double.tryParse(v) ?? 0)),
    ]);
  }

  Widget _buildCredentialsStep(AppLocalizations l, AppColors c) {
    if (_flow == _WithdrawFlow.bank) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.bankInfoTitle,
            style: TextStyle(
                color: c.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(l.enterBankInfo,
            style: TextStyle(color: c.textSecondary, fontSize: 14)),
        const SizedBox(height: 24),
        Text(l.beneficiaryName,
            style: TextStyle(color: c.textSecondary, fontSize: 13)),
        const SizedBox(height: 8),
        walletInputField(
            controller: _benefCtrl,
            hint: 'Mohamed Haitam',
            icon: Icons.person_outline,
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 16),
        Text(l.rib, style: TextStyle(color: c.textSecondary, fontSize: 13)),
        const SizedBox(height: 8),
        walletInputField(
            controller: _ribCtrl,
            hint: 'MA640011...',
            icon: Icons.credit_card,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {})),
      ]);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l.cashplusTitle,
          style: TextStyle(
              color: c.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text(l.cashplusRecipient,
          style: TextStyle(color: c.textSecondary, fontSize: 14)),
      const SizedBox(height: 24),
      Text(l.cashplusPhoneLabel,
          style: TextStyle(color: c.textSecondary, fontSize: 13)),
      const SizedBox(height: 8),
      walletInputField(
          controller: _phoneCtrl,
          hint: '06XXXXXXXX',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          onChanged: (_) => setState(() {})),
      const SizedBox(height: 16),
      Text(l.motif, style: TextStyle(color: c.textSecondary, fontSize: 13)),
      const SizedBox(height: 8),
      walletInputField(
          controller: _motifCtrl, hint: l.motifHint, icon: Icons.note_outlined),
    ]);
  }

  Widget _buildConfirmStep(AppLocalizations l) {
    final opt = _selectedOption!;
    final name = walletOptionName(context, opt);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l.confirmWithdrawTitle,
          style: TextStyle(
              color: AppColors.of(context).textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold)),
      const SizedBox(height: 24),
      walletSummaryTile(
          l.modeLabel, name, walletOptionIcon(opt), walletOptionColor(opt)),
      const SizedBox(height: 12),
      walletSummaryTile(l.amountLabel, '${_amount.toStringAsFixed(0)} MAD',
          Icons.north_east, AppColors.red),
      if (_flow == _WithdrawFlow.bank) ...[
        const SizedBox(height: 12),
        walletSummaryTile(l.beneficiaryName, _benefCtrl.text,
            Icons.person_outline, const Color(0xFF4A90D9)),
        const SizedBox(height: 12),
        walletSummaryTile(
            l.rib, _ribCtrl.text, Icons.credit_card, const Color(0xFF4A90D9)),
      ],
      if (_flow == _WithdrawFlow.cashplus) ...[
        const SizedBox(height: 12),
        walletSummaryTile(
            l.cashplusPhoneLabel, _phoneCtrl.text, Icons.phone, AppColors.teal),
      ],
    ]);
  }

  Widget _buildResultStep(AppLocalizations l) {
    if (_resultUrl != null && _resultUrl!.isNotEmpty) {
      return WalletUrlResultCard(
        url: _resultUrl!,
        title: l.qrWithdrawTitle,
        subtitle: l.qrWithdrawSubtitle,
        onDone: () => context.pop(true),
      );
    }
    return WalletResultBanner(
      icon: Icons.check_circle,
      color: AppColors.teal,
      title: l.withdrawDoneTitle,
      subtitle: l.withdrawDoneSub,
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
              color: selected ? color : c.border, width: selected ? 1.5 : 1),
        ),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
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
