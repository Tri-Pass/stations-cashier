import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:cashier/core/constants/api_endpoints.dart';
import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/network/api_client.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/wallet/presentation/widgets/wallet_flow_shared.dart';

class _Candidate {
  final String userId;
  final String phone;
  final String fullName;
  const _Candidate(
      {required this.userId, required this.phone, required this.fullName});

  factory _Candidate.fromJson(Map<String, dynamic> j) => _Candidate(
        userId: (j['user_id'] as String?) ?? '',
        phone: (j['phone'] as String?) ?? '',
        fullName: (j['full_name'] as String?) ?? '',
      );
}

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  int _step = 0;
  double _amount = 0;
  final _amountCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  List<_Candidate> _candidates = [];
  _Candidate? _recipient;
  bool _searching = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _search(String q) async {
    setState(() {
      _searching = true;
      _candidates = [];
    });
    try {
      final res = await GetIt.instance<ApiClient>()
          .get(ApiEndpoints.walletCandidates(q));
      final list = (res['data'] as List?) ?? [];
      setState(() => _candidates = list
          .map((e) => _Candidate.fromJson(e as Map<String, dynamic>))
          .toList());
    } catch (_) {
      setState(() => _candidates = []);
    } finally {
      setState(() => _searching = false);
    }
  }

  Future<void> _submit(String pin) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await GetIt.instance<ApiClient>().post(ApiEndpoints.walletTransfer, {
        'amount': _amount.toInt(),
        'user_id': _recipient!.userId,
        'code_pin': pin,
      });
      setState(() => _step = 3);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  bool get _canProceed {
    if (_step == 0) return _amount > 0;
    if (_step == 1) return _recipient != null;
    return true;
  }

  Future<void> _next() async {
    if (_step == 2) {
      final pin = await showWalletPasswordSheet(context);
      if (pin != null && mounted) _submit(pin);
      return;
    }
    setState(() => _step++);
    if (_step == 1) _search('');
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
          onPressed: _step == 3 ? () => context.pop(true) : _back,
        ),
        title: Text(l.transfer,
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
                    onPressed: (_canProceed && !_loading) ? _next : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C7FDE),
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
                            _step == 2 ? l.confirmTransferBtn : l.continueBtn,
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
        return _buildAmountStep(l, c);
      case 1:
        return _buildRecipientStep(l, c);
      case 2:
        return _buildConfirmStep(l);
      case 3:
        return _buildResultStep(l);
      default:
        return const SizedBox();
    }
  }

  Widget _buildAmountStep(AppLocalizations l, AppColors c) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l.transferAmountTitle,
          style: TextStyle(
              color: c.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text(l.howMuchTransfer,
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
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF6C7FDE).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: const Color(0xFF6C7FDE).withValues(alpha: 0.3)),
        ),
        child: Row(children: [
          const Icon(Icons.info_outline, color: Color(0xFF6C7FDE), size: 16),
          const SizedBox(width: 8),
          Text(l.freeTransferNote,
              style: const TextStyle(color: Color(0xFF6C7FDE), fontSize: 13)),
        ]),
      ),
    ]);
  }

  Widget _buildRecipientStep(AppLocalizations l, AppColors c) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l.chooseRecipient,
          style: TextStyle(
              color: c.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text(l.searchDriver,
          style: TextStyle(color: c.textSecondary, fontSize: 14)),
      const SizedBox(height: 20),
      TextField(
        controller: _searchCtrl,
        style: TextStyle(color: c.textPrimary),
        onChanged: (q) {
          if (q.length >= 2 || q.isEmpty) _search(q);
        },
        decoration: InputDecoration(
          hintText: l.searchPlaceholder,
          hintStyle: TextStyle(color: c.textSecondary),
          filled: true,
          fillColor: c.inputBg,
          prefixIcon: Icon(Icons.search, color: c.textSecondary, size: 20),
          suffixIcon: _searching
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: AppColors.primary, strokeWidth: 2)))
              : null,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      const SizedBox(height: 16),
      if (_candidates.isEmpty && !_searching)
        Center(
            child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text(l.noResults, style: TextStyle(color: c.textSecondary)),
        ))
      else
        ..._candidates.map((c) => _CandidateCard(
              candidate: c,
              selected: _recipient?.userId == c.userId,
              onTap: () => setState(() => _recipient = c),
            )),
    ]);
  }

  Widget _buildConfirmStep(AppLocalizations l) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l.confirmTransferTitle,
          style: TextStyle(
              color: AppColors.of(context).textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold)),
      const SizedBox(height: 24),
      walletSummaryTile(l.recipient, _recipient!.fullName, Icons.person_outline,
          const Color(0xFF6C7FDE)),
      const SizedBox(height: 12),
      walletSummaryTile(l.phoneNumber, _recipient!.phone, Icons.phone,
          const Color(0xFF6C7FDE)),
      const SizedBox(height: 12),
      walletSummaryTile(l.amountLabel, '${_amount.toStringAsFixed(0)} MAD',
          Icons.send, const Color(0xFF6C7FDE)),
      const SizedBox(height: 12),
      walletSummaryTile(l.fees, l.free, Icons.info_outline, AppColors.teal),
    ]);
  }

  Widget _buildResultStep(AppLocalizations l) {
    return WalletResultBanner(
      icon: Icons.check_circle,
      color: const Color(0xFF6C7FDE),
      title: l.transferDoneTitle,
      subtitle: l.transferDoneSub(
          _amount.toStringAsFixed(0), _recipient?.fullName ?? ''),
      onDone: () => context.pop(true),
    );
  }
}

class _CandidateCard extends StatelessWidget {
  final _Candidate candidate;
  final bool selected;
  final VoidCallback onTap;
  const _CandidateCard(
      {required this.candidate, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF6C7FDE).withValues(alpha: 0.1)
              : c.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? const Color(0xFF6C7FDE) : c.border,
              width: selected ? 1.5 : 1),
        ),
        child: Row(children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF6C7FDE).withValues(alpha: 0.2),
            radius: 20,
            child: Text(
              candidate.fullName.isNotEmpty
                  ? candidate.fullName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                  color: Color(0xFF6C7FDE), fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(candidate.fullName,
                    style: TextStyle(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                Text(candidate.phone,
                    style: TextStyle(color: c.textSecondary, fontSize: 12)),
              ])),
          if (selected)
            const Icon(Icons.check_circle, color: Color(0xFF6C7FDE), size: 20),
        ]),
      ),
    );
  }
}
