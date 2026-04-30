import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';

class CashierPrinter {
  static Future<void> printTest() async {
    await SunmiPrinter.lineWrap(20);
    await SunmiPrinter.printText(
      ' wetaxi.station — test ',
      style: SunmiTextStyle(
        align: SunmiPrintAlign.CENTER,
        fontSize: 20,
        bold: true,
      ),
    );
    await SunmiPrinter.lineWrap(20);
    await SunmiPrinter.cutPaper();
  }

  static Future<bool> printBooking({
    required String stationName,
    required String lineName,
    required String taxiNumber,
    required int seatCount,
    required double totalPrice,
    required String paymentMethod,
  }) async {
    try {
      await _buildLogo();

      final timestamp = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
      await SunmiPrinter.printText(
        timestamp,
        style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 22),
      );
      await SunmiPrinter.lineWrap(10);
      await SunmiPrinter.printText(
        '═══════════════════════════════',
        style: SunmiTextStyle(align: SunmiPrintAlign.CENTER),
      );
      await SunmiPrinter.lineWrap(20);

      await SunmiPrinter.printText(
        'Station: $stationName',
        style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 25, bold: true),
      );
      await SunmiPrinter.lineWrap(15);
      await SunmiPrinter.printText(
        'Ligne: $lineName',
        style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 25),
      );
      await SunmiPrinter.lineWrap(15);
      await SunmiPrinter.printText(
        'Taxi: $taxiNumber',
        style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 25),
      );
      await SunmiPrinter.lineWrap(15);
      await SunmiPrinter.printText(
        'Places: $seatCount',
        style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 25),
      );
      await SunmiPrinter.lineWrap(20);

      await SunmiPrinter.printText(
        '═══════════════════════════════',
        style: SunmiTextStyle(align: SunmiPrintAlign.CENTER),
      );
      await SunmiPrinter.lineWrap(20);

      await SunmiPrinter.printText(
        'Total: ${totalPrice.toStringAsFixed(2)} MAD',
        style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 30, bold: true),
      );
      await SunmiPrinter.lineWrap(15);
      await SunmiPrinter.printText(
        'Paiement: $paymentMethod',
        style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 25),
      );
      await SunmiPrinter.lineWrap(20);

      await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
      await SunmiPrinter.printQRCode(
        'www.wetaxi.ma',
        style: SunmiQrcodeStyle(
          qrcodeSize: 8,
          errorLevel: SunmiQrcodeLevel.LEVEL_H,
        ),
      );
      await SunmiPrinter.lineWrap(20);
      await SunmiPrinter.printText(
        'Merci pour votre confiance',
        style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 20, bold: true),
      );
      await SunmiPrinter.lineWrap(20);
      await SunmiPrinter.cutPaper();
      return true;
    } catch (e) {
      log('CashierPrinter error: $e');
      return false;
    }
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