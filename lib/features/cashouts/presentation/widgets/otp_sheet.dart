import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:cashier/core/constants/api_endpoints.dart';
import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/network/api_client.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/wallet/presentation/widgets/wallet_flow_shared.dart';

const _otpLength = 6;

/// Sends OTP to the driver. Returns true on success, false on error.
Future<bool> sendOtpToDriver(BuildContext context, String driverId) async {
  try {
    await GetIt.instance<ApiClient>()
        .post(ApiEndpoints.otpSend, {'userId': driverId});
    return true;
  } catch (e) {
    if (context.mounted) {
      final l = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l.otpSendError}: ${e.toString()}'),
          backgroundColor: AppColors.red,
        ),
      );
    }
    return false;
  }
}

/// Shows the OTP verification sheet (assumes OTP has already been sent).
/// Returns true if OTP was validated successfully.
Future<bool> showOtpVerifySheet(
    BuildContext context, String driverId) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _OtpSheet(driverId: driverId),
  );
  return result == true;
}

class _OtpSheet extends StatefulWidget {
  final String driverId;
  const _OtpSheet({required this.driverId});

  @override
  State<_OtpSheet> createState() => _OtpSheetState();
}

class _OtpSheetState extends State<_OtpSheet> {
  final _hiddenCtrl = TextEditingController();
  final _focusNode = FocusNode();
  String _otp = '';
  bool _loading = false;
  String? _error;

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

  Future<void> _validate(String otp) async {
    if (otp.length < _otpLength) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await GetIt.instance<ApiClient>().post(
        ApiEndpoints.otpVerify,
        {'userId': widget.driverId, 'otp': otp},
      );
      final valid = res is Map && res['valid'] == true;
      if (!valid) throw Exception('');
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _otp = '';
          _hiddenCtrl.clear();
          _error = AppLocalizations.of(context).otpIncorrect;
          _loading = false;
        });
        _focusNode.requestFocus();
      }
    } finally {
      if (mounted && _loading) setState(() => _loading = false);
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
          // Drag handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
                color: c.border, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 24),
          // Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.sms_outlined,
                color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            l.otpSheetTitle,
            style: TextStyle(
                color: c.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            l.otpSheetSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: c.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 32),
          // Hidden text field captures keyboard input
          SizedBox(
            height: 0,
            child: TextField(
              controller: _hiddenCtrl,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(_otpLength),
              ],
              onChanged: (v) {
                setState(() => _otp = v);
                if (v.length == _otpLength) _validate(v);
              },
              style:
                  const TextStyle(fontSize: 0, color: Colors.transparent),
              cursorColor: Colors.transparent,
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
          // OTP digit boxes
          GestureDetector(
            onTap: () => _focusNode.requestFocus(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_otpLength, (i) {
                final filled = i < _otp.length;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: 46,
                  height: 56,
                  decoration: BoxDecoration(
                    color: filled
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : c.inputBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: filled ? AppColors.primary : c.border,
                      width: filled ? 1.5 : 1,
                    ),
                  ),
                  child: Center(
                    child: filled
                        ? Text(
                            _otp[i],
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
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
                    color: AppColors.primary, strokeWidth: 2),
              ),
            ),
        ]),
      ),
    );
  }
}
