// import 'dart:convert';
import 'dart:developer';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/features/booking/domain/entities/booking_entity.dart';

class CashierPrinter {
  // 58mm paper @ 203 DPI = 384 dots print width
  static const double _imgW = 384.0;

  static Future<void> printTest() async {
    await SunmiPrinter.lineWrap(20);
    await SunmiPrinter.printText(
      ' wetaxi.station — test ',
      style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 20, bold: true),
    );
    await SunmiPrinter.lineWrap(20);
    await SunmiPrinter.cutPaper();
  }

  static Future<bool> printTicket({
    required TicketEntity ticket,
    required String stationName,
    required AppLocalizations l,
  }) async {
    try {
      await _buildLogo();

      final timestamp = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
      await SunmiPrinter.printText(
        timestamp,
        style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 22),
      );
      await _separator();

      await SunmiPrinter.printText(
        ticket.code,
        style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: _fs(24, 20, l), bold: true),
      );
      await _gap(l);

      await _printLine(_field(l.printStation, stationName), l, fontSize: _fs(28, 21, l), bold: true);
      await _gap(l);
      await _printLine(_field(l.printLine, ticket.destination), l, fontSize: _fs(28, 21, l));//'${ticket.origin} - ${ticket.destination}'
      await _gap(l);
      await _printLine(_field(l.printTaxi, ticket.plateNumber), l, fontSize: _fs(28, 21, l));
      await _gap(l);
      await _printLine(_field(l.printDriver, ticket.driverName), l, fontSize: _fs(28, 21, l));
      await _gap(l);
      await _printLine(_field(l.printSeats, '${ticket.seatNumber}'), l, fontSize: _fs(28, 21, l));
      await _gap(l);

      await _separator();
      await _gap(l);

      await _printLine(
        _field(l.printTotal, '${(ticket.price * ticket.seatNumber).toStringAsFixed(2)} MAD'),
        l, fontSize: _fs(34, 24, l), bold: true,
      );
      await _gap(l);
      await _printLine(
        _field(l.printPayment, ticket.paymentMethod == 'cash' ? l.printCash : l.nfc),
        l, fontSize: _fs(28, 21, l),
      );
      await _gap(l);

      //Todo: remove the QR code
      // QR code — use real qrData image from API if available
      // if (ticket.qrData != null && ticket.qrData!.contains('base64,')) {
      //   final base64Str = ticket.qrData!.split('base64,').last;
      //   final qrBytes = base64Decode(base64Str);
      //   await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
      //   await SunmiPrinter.printImage(qrBytes, align: SunmiPrintAlign.CENTER);
      // } else {
      //   await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
      //   await SunmiPrinter.printQRCode(
      //     ticket.code,
      //     style: SunmiQrcodeStyle(qrcodeSize: 8, errorLevel: SunmiQrcodeLevel.LEVEL_H),
      //   );
      // }

      await _printLine(l.printThankYou, l, fontSize: _fs(22, 18, l), bold: true, center: true);
      await SunmiPrinter.lineWrap(30);
      await SunmiPrinter.cutPaper();
      return true;
    } catch (e) {
      log('CashierPrinter error: $e');
      return false;
    }
  }

  // Legacy fallback — used if API call fails before ticket is received
  static Future<bool> printBooking({
    required String stationName,
    required String lineName,
    required String taxiNumber,
    required int seatCount,
    required double totalPrice,
    required String paymentMethod,
    required AppLocalizations l,
  }) async {
    try {
      await _buildLogo();
      final timestamp = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
      await SunmiPrinter.printText(timestamp,
          style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 22));
      await _separator();
      await _gap(l);
      await _printLine(_field(l.printStation, stationName), l, fontSize: _fs(28, 21, l), bold: true);
      await _gap(l);
      await _printLine(_field(l.printLine, lineName), l, fontSize: _fs(28, 21, l));
      await _gap(l);
      await _printLine(_field(l.printTaxi, taxiNumber), l, fontSize: _fs(28, 21, l));
      await _gap(l);
      await _printLine(_field(l.printSeats, '$seatCount'), l, fontSize: _fs(28, 21, l));
      await _gap(l);
      await _separator();
      await _gap(l);
      await _printLine(_field(l.printTotal, '${totalPrice.toStringAsFixed(2)} MAD'), l,
          fontSize: _fs(34, 24, l), bold: true);
      await _gap(l);
      await _printLine(_field(l.printPayment, paymentMethod), l, fontSize: _fs(28, 21, l));
      await _gap(l);
      //Todo: remove the QR code
      // await SunmiPrinter.printQRCode('www.wetaxi.ma',
      //     style: SunmiQrcodeStyle(qrcodeSize: 8, errorLevel: SunmiQrcodeLevel.LEVEL_H));
      await _printLine(l.printThankYou, l, fontSize: _fs(22, 18, l), bold: true, center: true);
      await SunmiPrinter.lineWrap(30);
      await SunmiPrinter.cutPaper();
      return true;
    } catch (e) {
      log('CashierPrinter error: $e');
      return false;
    }
  }

  static Future<bool> printRecharge({
    required String passengerName,
    required String passengerPhone,
    required double amount,
    required double balanceBefore,
    required double balanceAfter,
    required String method,
    required AppLocalizations l,
  }) async {
    try {
      await _buildLogo();

      final timestamp = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
      await SunmiPrinter.printText(
        timestamp,
        style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 22),
      );
      await _separator();

      await _printLine(l.printRechargeTitle, l, fontSize: _fs(28, 22, l), bold: true, center: true);
      await _gap(l);

      await _printLine(_field(l.printName, passengerName), l, fontSize: _fs(28, 21, l));
      await _gap(l);
      await _printLine(_field(l.printPhone, passengerPhone), l, fontSize: _fs(28, 21, l));
      await _gap(l);

      await _separator();
      await _gap(l);

      await _printLine(_field(l.printAmount, '+${amount.toStringAsFixed(2)} MAD'), l,
          fontSize: _fs(34, 24, l), bold: true);
      await _gap(l);
      await _printLine(
          _field(l.printBalanceBefore, '${balanceBefore.toStringAsFixed(2)} MAD'), l, fontSize: _fs(28, 21, l));
      await _gap(l);
      await _printLine(
          _field(l.printBalanceAfter, '${balanceAfter.toStringAsFixed(2)} MAD'), l,
          fontSize: _fs(28, 21, l), bold: true);
      await _gap(l);
      await _printLine(_field(l.printPayment, method), l, fontSize: _fs(28, 21, l));
      await _gap(l);

      await _printLine(l.printThankYou, l, fontSize: _fs(22, 18, l), bold: true, center: true);
      await SunmiPrinter.lineWrap(30);
      await SunmiPrinter.cutPaper();
      return true;
    } catch (e) {
      log('CashierPrinter.printRecharge error: $e');
      return false;
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static String _field(String label, String value) => '$label: $value';

  // FR gets bigger font, AR gets smaller font
  static int _fs(int fr, int ar, AppLocalizations l) => l.isAr ? ar : fr;

  // FR gets line spacing between items, AR prints tight
  static Future<void> _gap(AppLocalizations l) async {
    if (!l.isAr) await SunmiPrinter.lineWrap(10);
  }

  // Print one line of text.
  // For French: uses the printer's native text engine (fast, works perfectly).
  // For Arabic: renders the text to a PNG image using Flutter's dart:ui engine,
  // which correctly handles Arabic letter shaping and BiDi direction.
  static Future<void> _printLine(
    String text,
    AppLocalizations l, {
    int fontSize = 25,
    bool bold = false,
    bool center = false,
  }) async {
    if (!l.isAr) {
      await SunmiPrinter.printText(
        text,
        style: SunmiTextStyle(
          align: center ? SunmiPrintAlign.CENTER : SunmiPrintAlign.LEFT,
          fontSize: fontSize,
          bold: bold,
        ),
      );
      return;
    }

    // Arabic: render via dart:ui with proper RTL + letter shaping
    final textAlign = center ? ui.TextAlign.center : ui.TextAlign.right;
    final imgAlign = center ? SunmiPrintAlign.CENTER : SunmiPrintAlign.RIGHT;

    final pb = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textDirection: ui.TextDirection.rtl,
        textAlign: textAlign,
      ),
    )
      ..pushStyle(ui.TextStyle(
        fontSize: fontSize * 1.2,
        fontWeight: bold ? ui.FontWeight.bold : ui.FontWeight.normal,
        color: const ui.Color(0xFF000000),
      ))
      ..addText(text);

    final para = pb.build()..layout(const ui.ParagraphConstraints(width: _imgW));
    final imgH = para.height.ceil() + 4;

    final rec = ui.PictureRecorder();
    final canvas = ui.Canvas(rec);
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, _imgW, imgH.toDouble()),
      ui.Paint()..color = const ui.Color(0xFFFFFFFF),
    );
    canvas.drawParagraph(para, ui.Offset.zero);

    final img = await rec.endRecording().toImage(_imgW.toInt(), imgH);
    final bd = await img.toByteData(format: ui.ImageByteFormat.png);
    await SunmiPrinter.printImage(bd!.buffer.asUint8List(), align: imgAlign);
  }

  static Future<void> _separator() async {
    await SunmiPrinter.printText(
      '════════════════',
      style: SunmiTextStyle(align: SunmiPrintAlign.CENTER),
    );
  }

  static Future<void> _buildLogo() async {
    await SunmiPrinter.line();
    final bytes = await _readAssetBytes('assets/images/ticket_logo.jpg');
    await SunmiPrinter.printImage(bytes, align: SunmiPrintAlign.CENTER);
    await SunmiPrinter.lineWrap(10);
    await SunmiPrinter.printText(
      'www.wetaxi.ma',
      style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, bold: true),
    );
    await SunmiPrinter.lineWrap(10);
  }

  static Future<Uint8List> _readAssetBytes(String path) async {
    final data = await rootBundle.load(path);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
}
