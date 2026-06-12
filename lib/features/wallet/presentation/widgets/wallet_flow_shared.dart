import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:cashier/core/constants/api_endpoints.dart';
import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/network/api_client.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/core/widgets/app_notification.dart';

const walletAmountPresets = [100, 200, 300, 500];

// ─── Payment option (from GET /api/cashier/wallet/options?type=...) ───────────
// API returns: { req_type: "url"|"rib"|"cashplus", code: string, label: string }
class WalletOption {
  final String reqType;
  final String code;
  final String label;
  const WalletOption(
      {required this.reqType, required this.code, required this.label});

  factory WalletOption.fromJson(Map<String, dynamic> j) => WalletOption(
        reqType:
            (j['req_type'] as String?) ?? (j['reqType'] as String?) ?? 'url',
        code: (j['code'] as String?) ?? '',
        label: (j['label'] as String?) ?? '',
      );
}

IconData walletOptionIcon(WalletOption o) {
  final s = '${o.code} ${o.label}'.toLowerCase();
  if (s.contains('guichet') || s.contains('qr')) return Icons.qr_code_2;
  if (s.contains('bank') || s.contains('virement')) {
    return Icons.account_balance;
  }
  if (s.contains('card') || s.contains('cmi')) return Icons.credit_card;
  if (s.contains('cashplus') || s.contains('mobile')) {
    return Icons.phone_android;
  }
  return Icons.payments_outlined;
}

Color walletOptionColor(WalletOption o) {
  final s = '${o.code} ${o.label}'.toLowerCase();
  if (s.contains('guichet') || s.contains('qr')) return AppColors.primary;
  if (s.contains('bank') || s.contains('virement')) {
    return const Color(0xFF4A90D9);
  }
  if (s.contains('card') || s.contains('cmi')) return AppColors.teal;
  if (s.contains('cashplus') || s.contains('mobile')) return AppColors.teal;
  return AppColors.primary;
}

String walletOptionName(BuildContext context, WalletOption o) => o.label;

// ─── PIN confirmation sheet ────────────────────────────────────────────────────
// Returns the verified PIN string on success, null if cancelled or invalid.
Future<String?> showWalletPasswordSheet(BuildContext context) async {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _PasswordSheet(),
  );
}

class _PasswordSheet extends StatefulWidget {
  const _PasswordSheet();
  @override
  State<_PasswordSheet> createState() => _PasswordSheetState();
}

class _PasswordSheetState extends State<_PasswordSheet> {
  final _hiddenCtrl = TextEditingController();
  final _focusNode = FocusNode();
  String _pin = '';
  bool _loading = false;
  String? _error;

  static const _pinLength = 6;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _hiddenCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _verify(String pin) async {
    if (pin.length < _pinLength) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await GetIt.instance<ApiClient>().post(
        ApiEndpoints.walletCheckPin,
        {'code_pin': pin},
      );
      final valid = (res['data'] as Map?)?['valid'] == true;
      if (!valid) throw Exception('');
      if (mounted) Navigator.of(context).pop(pin);
    } catch (_) {
      if (mounted) {
        setState(() {
          _pin = '';
          _hiddenCtrl.clear();
          _error = AppLocalizations.of(context).pinIncorrect;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        _focusNode.requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = AppColors.of(context);
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
                color: c.border, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 24),
          const Icon(Icons.lock_outline, color: AppColors.primary, size: 40),
          const SizedBox(height: 16),
          Text(l.confirmOperation,
              style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(l.enterPinToValidate,
              textAlign: TextAlign.center,
              style: TextStyle(color: c.textSecondary, fontSize: 13)),
          const SizedBox(height: 32),
          SizedBox(
            height: 0,
            child: TextField(
              controller: _hiddenCtrl,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(_pinLength),
              ],
              onChanged: (v) {
                setState(() => _pin = v);
                if (v.length == _pinLength) _verify(v);
              },
              style: const TextStyle(fontSize: 0, color: Colors.transparent),
              cursorColor: Colors.transparent,
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
          GestureDetector(
            onTap: () => _focusNode.requestFocus(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pinLength, (i) {
                final filled = i < _pin.length;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 44,
                  height: 54,
                  decoration: BoxDecoration(
                    color: filled
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : c.inputBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: filled ? AppColors.primary : c.border,
                      width: filled ? 1.5 : 1,
                    ),
                  ),
                  child: Center(
                    child: filled
                        ? Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle),
                          )
                        : null,
                  ),
                );
              }),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            walletErrorBanner(_error!),
          ] else
            const SizedBox(height: 16),
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      color: AppColors.primary, strokeWidth: 2)),
            ),
        ]),
      ),
    );
  }
}

// ─── Step progress dots ────────────────────────────────────────────────────────
class WalletStepDots extends StatelessWidget {
  final int step;
  final int total;
  const WalletStepDots({super.key, required this.step, required this.total});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
            total,
            (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == step ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == step
                        ? AppColors.primary
                        : i < step
                            ? AppColors.primary.withValues(alpha: 0.4)
                            : c.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                )),
      ),
    );
  }
}

// ─── Amount preset chip ────────────────────────────────────────────────────────
class WalletPresetChip extends StatelessWidget {
  final int amount;
  final bool selected;
  final VoidCallback onTap;
  const WalletPresetChip(
      {super.key,
      required this.amount,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : c.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppColors.primary : c.border),
        ),
        child: Text(
          '$amount MAD',
          style: TextStyle(
            color: selected ? Colors.black : c.textPrimary,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// ─── Summary row tile ──────────────────────────────────────────────────────────
Widget walletSummaryTile(
    String label, String value, IconData icon, Color color) {
  return Builder(builder: (context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      child: Row(children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: c.textSecondary, fontSize: 12)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  color: c.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
        ])),
      ]),
    );
  });
}

// ─── Text input field ──────────────────────────────────────────────────────────
Widget walletInputField({
  required TextEditingController controller,
  required String hint,
  required IconData icon,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
  void Function(String)? onChanged,
}) {
  return Builder(builder: (context) {
    final c = AppColors.of(context);
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      style: TextStyle(color: c.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: c.textSecondary),
        filled: true,
        fillColor: c.inputBg,
        prefixIcon: Icon(icon, color: c.textSecondary, size: 20),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  });
}

// ─── Error banner ──────────────────────────────────────────────────────────────
Widget walletErrorBanner(String message) {
  return Container(
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: AppColors.red.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(children: [
      const Icon(Icons.error_outline, color: AppColors.red, size: 18),
      const SizedBox(width: 8),
      Expanded(
          child: Text(message,
              style: const TextStyle(color: AppColors.red, fontSize: 13))),
    ]),
  );
}

// ─── Success result banner ─────────────────────────────────────────────────────
class WalletResultBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onDone;
  const WalletResultBanner({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = AppColors.of(context);
    return Column(children: [
      const SizedBox(height: 40),
      Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 44),
      ),
      const SizedBox(height: 24),
      Text(title,
          style: TextStyle(
              color: c.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Text(subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(color: c.textSecondary, fontSize: 15, height: 1.5)),
      const SizedBox(height: 40),
      SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: onDone,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: Text(
            l.backToWallet,
            style: TextStyle(
              color: color == const Color(0xFF6C7FDE)
                  ? Colors.white
                  : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    ]);
  }
}

// ─── URL / QR result card ──────────────────────────────────────────────────────
class WalletUrlResultCard extends StatelessWidget {
  final String url;
  final String title;
  final String subtitle;
  final VoidCallback onDone;
  const WalletUrlResultCard({
    super.key,
    required this.url,
    required this.title,
    required this.subtitle,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = AppColors.of(context);
    return Column(children: [
      const SizedBox(height: 24),
      Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle),
        child: const Icon(Icons.qr_code_2, color: AppColors.primary, size: 40),
      ),
      const SizedBox(height: 20),
      Text(title,
          style: TextStyle(
              color: c.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text(subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(color: c.textSecondary, fontSize: 14, height: 1.5)),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.border),
        ),
        child: Row(children: [
          Expanded(
              child: Text(url,
                  style: TextStyle(color: c.textPrimary, fontSize: 12),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis)),
          IconButton(
            icon: const Icon(Icons.copy, color: AppColors.primary, size: 20),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              showAppSuccess(context, title: l.linkCopied);
            },
          ),
        ]),
      ),
      const SizedBox(height: 32),
      SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: onDone,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: Text(l.backToWallet,
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        ),
      ),
    ]);
  }
}
