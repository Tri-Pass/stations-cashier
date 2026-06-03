import 'package:flutter/material.dart';
import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/theme/app_theme.dart';

class NfcLinkSection extends StatelessWidget {
  const NfcLinkSection({
    super.key,
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.scanning,
    required this.tagId,
    required this.linking,
    required this.pulseAnim,
    this.nameError,
    this.phoneError,
    required this.onStartScan,
    required this.onCancelScan,
    required this.onReset,
    required this.onLink,
  });

  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final bool scanning;
  final String? tagId;
  final bool linking;
  final Animation<double> pulseAnim;
  final String? nameError;
  final String? phoneError;
  final VoidCallback onStartScan;
  final VoidCallback onCancelScan;
  final VoidCallback onReset;
  final VoidCallback onLink;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInputCard(l, c),
              const SizedBox(height: 20),
              SizedBox(
                height: 250,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  child: tagId != null
                      ? _buildDetected(l, c)
                      : scanning
                          ? _buildScanning(l, c)
                          : _buildIdle(l, c),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        _buildActionButton(l, c),
        if (tagId != null) ...[
          const SizedBox(height: 10),
          TextButton(
            onPressed: onReset,
            child:
                Text(l.scanAnother, style: TextStyle(color: c.textSecondary)),
          ),
        ] else
          const SizedBox(height: 8),
      ],
    );
  }

  // ── Input card ────────────────────────────────────────────────────────────

  Widget _buildInputCard(AppLocalizations l, AppColors c) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.passengerToLink,
            style: TextStyle(
              color: c.textSecondary,
              fontSize: 10,
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _field(
            controller: nameCtrl,
            hint: l.passengerNameHint,
            icon: Icons.person_outline,
            type: TextInputType.name,
            enabled: !scanning,
            errorText: nameError,
            c: c,
          ),
          const SizedBox(height: 10),
          _field(
            controller: phoneCtrl,
            hint: l.passengerPhoneHint,
            icon: Icons.phone_outlined,
            type: TextInputType.phone,
            enabled: !scanning,
            errorText: phoneError,
            c: c,
          ),
        ],
      ),
    );
  }

  // ── NFC status states ─────────────────────────────────────────────────────

  Widget _buildIdle(AppLocalizations l, AppColors c) {
    return Column(
      key: const ValueKey('link-idle'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            shape: BoxShape.circle,
            border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.35), width: 2),
          ),
          child: const Icon(Icons.nfc, color: AppColors.primary, size: 54),
        ),
        const SizedBox(height: 20),
        Text(
          l.nfcLinkDesc,
          textAlign: TextAlign.center,
          style: TextStyle(color: c.textSecondary, fontSize: 13, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildScanning(AppLocalizations l, AppColors c) {
    return Column(
      key: const ValueKey('link-scanning'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScaleTransition(
          scale: pulseAnim,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 28,
                  spreadRadius: 6,
                ),
              ],
            ),
            child: const Icon(Icons.nfc, color: AppColors.primary, size: 60),
          ),
        ),
        const SizedBox(height: 20),
        Text(l.nfcScanning,
            style: TextStyle(
                color: c.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(l.nfcApproachDetect,
            textAlign: TextAlign.center,
            style:
                TextStyle(color: c.textSecondary, fontSize: 13, height: 1.5)),
      ],
    );
  }

  Widget _buildDetected(AppLocalizations l, AppColors c) {
    return Column(
      key: const ValueKey('link-detected'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.green.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.green, width: 2),
          ),
          child: const Icon(Icons.nfc, color: AppColors.green, size: 40),
        ),
        const SizedBox(height: 14),
        Text(l.cardDetected,
            style: TextStyle(
                color: c.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.green.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.nfcIdLabel,
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 10,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                  )),
              const SizedBox(height: 8),
              Text(tagId ?? '',
                  style: const TextStyle(
                    color: AppColors.green,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  )),
            ],
          ),
        ),
      ],
    );
  }

  // ── Action button ─────────────────────────────────────────────────────────

  Widget _buildActionButton(AppLocalizations l, AppColors c) {
    if (scanning) {
      return SizedBox(
        height: 52,
        child: OutlinedButton.icon(
          onPressed: onCancelScan,
          icon: const Icon(Icons.close, size: 18),
          label: Text(l.cancel,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          style: OutlinedButton.styleFrom(
            foregroundColor: c.textSecondary,
            side: BorderSide(color: c.border),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      );
    }

    if (tagId != null) {
      return SizedBox(
        height: 52,
        child: ElevatedButton.icon(
          onPressed: linking ? null : onLink,
          icon: linking
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.link, size: 20),
          label: Text(l.linkPassenger,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.green.withValues(alpha: 0.4),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
        ),
      );
    }

    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onStartScan,
        icon: const Icon(Icons.nfc, size: 22),
        label: Text(l.scanNfcCard,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.25),
          disabledForegroundColor: Colors.black38,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
      ),
    );
  }

  // ── Shared field builder ──────────────────────────────────────────────────

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required TextInputType type,
    required bool enabled,
    required AppColors c,
    String? errorText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      enabled: enabled,
      style: TextStyle(color: c.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: c.textSecondary, fontSize: 13),
        prefixIcon: Icon(icon,
            color: errorText != null ? AppColors.red : c.textSecondary,
            size: 20),
        errorText: errorText,
        errorStyle: const TextStyle(color: AppColors.red, fontSize: 11),
        filled: true,
        fillColor: errorText != null
            ? AppColors.red.withValues(alpha: 0.06)
            : c.inputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: errorText != null
              ? BorderSide(color: AppColors.red.withValues(alpha: 0.6))
              : BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
