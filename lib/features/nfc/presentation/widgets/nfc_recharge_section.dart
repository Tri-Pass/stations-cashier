import 'package:flutter/material.dart';
import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/passengers/domain/entities/passenger_entity.dart';

enum RechargeInput { nfc, phone }

enum RechargeState { idle, scanning, fetching, ready }

class NfcRechargeSection extends StatelessWidget {
  const NfcRechargeSection({
    super.key,
    required this.input,
    required this.rechargeState,
    required this.amountCtrl,
    required this.phoneCtrl,
    required this.passenger,
    required this.recharging,
    required this.pulseAnim,
    required this.onInputChanged,
    required this.onScan,
    required this.onCancel,
    required this.onConfirm,
  });

  final RechargeInput input;
  final RechargeState rechargeState;
  final TextEditingController amountCtrl;
  final TextEditingController phoneCtrl;
  final PassengerEntity? passenger;
  final bool recharging;
  final Animation<double> pulseAnim;
  final ValueChanged<RechargeInput> onInputChanged;
  final VoidCallback onScan;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  bool get _hasAmount {
    final v = double.tryParse(amountCtrl.text.trim());
    return v != null && v > 0;
  }

  bool get _phoneReady => phoneCtrl.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInputTabs(l, c),
        const SizedBox(height: 16),
        _buildAmountField(l, c),
        const SizedBox(height: 16),
        if (input == RechargeInput.phone) ...[
          _buildPhoneField(l, c),
          const SizedBox(height: 16),
        ],
        if (input == RechargeInput.nfc)
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              child: _buildNfcStatusArea(l, c),
            ),
          )
        else
          const Spacer(),
        const SizedBox(height: 16),
        _buildActionButton(l, c),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Input method sub-tabs ─────────────────────────────────────────────────

  Widget _buildInputTabs(AppLocalizations l, AppColors c) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          _NfcSubTab(
            label: l.nfcCardTab,
            icon: Icons.nfc,
            active: input == RechargeInput.nfc,
            onTap: () => onInputChanged(RechargeInput.nfc),
          ),
          _NfcSubTab(
            label: l.phoneTab,
            icon: Icons.phone_outlined,
            active: input == RechargeInput.phone,
            onTap: () => onInputChanged(RechargeInput.phone),
          ),
        ],
      ),
    );
  }

  // ── Amount field ──────────────────────────────────────────────────────────

  Widget _buildAmountField(AppLocalizations l, AppColors c) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.rechargeAmountLabel,
            style: TextStyle(
              color: c.textSecondary,
              fontSize: 10,
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: amountCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            enabled: rechargeState == RechargeState.idle ||
                rechargeState == RechargeState.ready,
            style: TextStyle(
                color: c.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(
                  color: c.textSecondary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
              suffixText: 'MAD',
              suffixStyle: TextStyle(
                  color: c.textSecondary, fontSize: 14),
              filled: true,
              fillColor: c.inputBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ── Phone field (phone mode only) ─────────────────────────────────────────

  Widget _buildPhoneField(AppLocalizations l, AppColors c) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.passengerPhoneHint.toUpperCase(),
            style: TextStyle(
              color: c.textSecondary,
              fontSize: 10,
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
            style: TextStyle(
                color: c.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: '06XXXXXXXX',
              hintStyle: TextStyle(
                  color: c.textSecondary, fontSize: 18),
              prefixIcon: const Icon(Icons.phone_outlined,
                  color: AppColors.primary, size: 20),
              filled: true,
              fillColor: c.inputBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ── NFC status area ───────────────────────────────────────────────────────

  Widget _buildNfcStatusArea(AppLocalizations l, AppColors c) {
    switch (rechargeState) {
      case RechargeState.scanning:
        return _buildScanning(l, c);
      case RechargeState.fetching:
        return _buildFetching();
      case RechargeState.ready:
        return _buildPassengerCard(l, c);
      case RechargeState.idle:
        return _buildNfcIdle(l, c);
    }
  }

  Widget _buildNfcIdle(AppLocalizations l, AppColors c) {
    return Center(
      key: const ValueKey('r-idle'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.35), width: 2),
            ),
            child: const Icon(Icons.nfc, color: AppColors.primary, size: 48),
          ),
          const SizedBox(height: 16),
          Text(
            l.nfcRechargeDesc,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: c.textSecondary, fontSize: 13, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildScanning(AppLocalizations l, AppColors c) {
    return Center(
      key: const ValueKey('r-scanning'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: pulseAnim,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 28,
                    spreadRadius: 6,
                  ),
                ],
              ),
              child: const Icon(Icons.nfc, color: AppColors.primary, size: 56),
            ),
          ),
          const SizedBox(height: 18),
          Text(l.nfcScanning,
              style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(l.nfcApproachDetect,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: c.textSecondary, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildFetching() {
    return const Column(
      key: ValueKey('r-fetching'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: AppColors.primary),
      ],
    );
  }

  Widget _buildPassengerCard(AppLocalizations l, AppColors c) {
    final p = passenger;
    if (p == null) return const SizedBox.shrink();
    final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
    return SingleChildScrollView(
      key: const ValueKey('r-ready'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person,
                      color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name,
                          style: TextStyle(
                              color: c.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(p.phone,
                          style: TextStyle(
                              color: c.textSecondary,
                              fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Divider(color: c.border, height: 1),
            const SizedBox(height: 14),
            _balanceRow(l.currentBalance,
                '${p.balance.toStringAsFixed(2)} MAD', c.textPrimary, c),
            const SizedBox(height: 8),
            _balanceRow(l.rechargeAmountLabel,
                '+${amount.toStringAsFixed(2)} MAD', AppColors.primary, c),
            const SizedBox(height: 8),
            _balanceRow(l.balanceAfter,
                '${(p.balance + amount).toStringAsFixed(2)} MAD',
                AppColors.green, c),
          ],
        ),
      ),
    );
  }

  Widget _balanceRow(String label, String value, Color valueColor, AppColors c) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: c.textSecondary, fontSize: 12)),
        Text(value,
            style: TextStyle(
                color: valueColor,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ── Action button ─────────────────────────────────────────────────────────

  Widget _buildActionButton(AppLocalizations l, AppColors c) {
    if (rechargeState == RechargeState.scanning ||
        rechargeState == RechargeState.fetching) {
      return SizedBox(
        height: 52,
        child: OutlinedButton.icon(
          onPressed: onCancel,
          icon: const Icon(Icons.close, size: 18),
          label: Text(l.cancel,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15)),
          style: OutlinedButton.styleFrom(
            foregroundColor: c.textSecondary,
            side: BorderSide(color: c.border),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
      );
    }

    if (rechargeState == RechargeState.ready ||
        input == RechargeInput.phone) {
      final canConfirm =
          _hasAmount && (input == RechargeInput.nfc || _phoneReady) && !recharging;
      return SizedBox(
        height: 52,
        child: ElevatedButton.icon(
          onPressed: canConfirm ? onConfirm : null,
          icon: recharging
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.black))
              : const Icon(Icons.bolt_rounded, size: 20),
          label: Text(l.confirmAndCharge,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.black,
            disabledBackgroundColor:
                AppColors.primary.withValues(alpha: 0.3),
            disabledForegroundColor: Colors.black38,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
        ),
      );
    }

    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onScan,
        icon: const Icon(Icons.nfc, size: 22),
        label: Text(l.scanAndCharge,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          disabledBackgroundColor:
              AppColors.primary.withValues(alpha: 0.3),
          disabledForegroundColor: Colors.black38,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
      ),
    );
  }
}

// ── Sub-tab ────────────────────────────────────────────────────────────────────

class _NfcSubTab extends StatelessWidget {
  const _NfcSubTab({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18,
                  color: active ? Colors.black : c.textSecondary),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: active ? Colors.black : c.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
