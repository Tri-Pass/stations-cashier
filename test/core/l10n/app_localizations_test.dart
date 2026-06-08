import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const fr = AppLocalizations(Locale('fr'));
  const ar = AppLocalizations(Locale('ar'));

  // ── isAr / _t routing ────────────────────────────────────────────────────

  group('locale routing', () {
    test('fr locale is not Arabic', () => expect(fr.isAr, isFalse));
    test('ar locale is Arabic', () => expect(ar.isAr, isTrue));
  });

  // ── French getters (covers fr branch of every _t call) ───────────────────

  group('French getters return non-empty strings', () {
    test('appName', () => expect(fr.appName, isNotEmpty));
    test('login', () => expect(fr.login, isNotEmpty));
    test('loginSubtitle', () => expect(fr.loginSubtitle, isNotEmpty));
    test('phoneNumber', () => expect(fr.phoneNumber, isNotEmpty));
    test('password', () => expect(fr.password, isNotEmpty));
    test('connect', () => expect(fr.connect, isNotEmpty));
    test('connectionError', () => expect(fr.connectionError, isNotEmpty));
    test('navReserve', () => expect(fr.navReserve, isNotEmpty));
    test('navLinkNfc', () => expect(fr.navLinkNfc, isNotEmpty));
    test('bookingTitle', () => expect(fr.bookingTitle, isNotEmpty));
    test('testPrint', () => expect(fr.testPrint, isNotEmpty));
    test('sectionLines', () => expect(fr.sectionLines, isNotEmpty));
    test('sectionPayment', () => expect(fr.sectionPayment, isNotEmpty));
    test('taxisInQueue', () => expect(fr.taxisInQueue, isNotEmpty));
    test('selectLineHint', () => expect(fr.selectLineHint, isNotEmpty));
    test('cash', () => expect(fr.cash, isNotEmpty));
    test('nfc', () => expect(fr.nfc, isNotEmpty));
    test('firstBadge', () => expect(fr.firstBadge, isNotEmpty));
    test('noTaxiForLine', () => expect(fr.noTaxiForLine, isNotEmpty));
    test('full', () => expect(fr.full, isNotEmpty));
    test('bookingConfirmed', () => expect(fr.bookingConfirmed, isNotEmpty));
    test('ok', () => expect(fr.ok, isNotEmpty));
    test('nfcReading', () => expect(fr.nfcReading, isNotEmpty));
    test('nfcApproach', () => expect(fr.nfcApproach, isNotEmpty));
    test('cardRead', () => expect(fr.cardRead, isNotEmpty));
    test('seats', () => expect(fr.seats, isNotEmpty));
    test('amount', () => expect(fr.amount, isNotEmpty));
    test('currentBalance', () => expect(fr.currentBalance, isNotEmpty));
    test('balanceAfter', () => expect(fr.balanceAfter, isNotEmpty));
    test('insufficientBalance', () => expect(fr.insufficientBalance, isNotEmpty));
    test('confirmAndPrint', () => expect(fr.confirmAndPrint, isNotEmpty));
    test('processing', () => expect(fr.processing, isNotEmpty));
    test('nfcProcessing', () => expect(fr.nfcProcessing, isNotEmpty));
    test('nfcError', () => expect(fr.nfcError, isNotEmpty));
    test('nfcBookingFailed', () => expect(fr.nfcBookingFailed, isNotEmpty));
    test('nfcLinkTitle', () => expect(fr.nfcLinkTitle, isNotEmpty));
    test('nfcLinkModeTab', () => expect(fr.nfcLinkModeTab, isNotEmpty));
    test('nfcRechargeModeTab', () => expect(fr.nfcRechargeModeTab, isNotEmpty));
    test('nfcLinkSubtitle', () => expect(fr.nfcLinkSubtitle, isNotEmpty));
    test('nfcLinkDesc', () => expect(fr.nfcLinkDesc, isNotEmpty));
    test('nfcRechargeDesc', () => expect(fr.nfcRechargeDesc, isNotEmpty));
    test('scanNfcCard', () => expect(fr.scanNfcCard, isNotEmpty));
    test('nfcScanning', () => expect(fr.nfcScanning, isNotEmpty));
    test('nfcApproachDetect', () => expect(fr.nfcApproachDetect, isNotEmpty));
    test('cardDetected', () => expect(fr.cardDetected, isNotEmpty));
    test('nfcIdLabel', () => expect(fr.nfcIdLabel, isNotEmpty));
    test('passengerToLink', () => expect(fr.passengerToLink, isNotEmpty));
    test('passengerPhoneHint', () => expect(fr.passengerPhoneHint, isNotEmpty));
    test('passengerNameHint', () => expect(fr.passengerNameHint, isNotEmpty));
    test('fieldNameRequired', () => expect(fr.fieldNameRequired, isNotEmpty));
    test('fieldPhoneRequired', () => expect(fr.fieldPhoneRequired, isNotEmpty));
    test('linkPassenger', () => expect(fr.linkPassenger, isNotEmpty));
    test('linkSuccess', () => expect(fr.linkSuccess, isNotEmpty));
    test('retry', () => expect(fr.retry, isNotEmpty));
    test('scanAnother', () => expect(fr.scanAnother, isNotEmpty));
    test('nfcCardTab', () => expect(fr.nfcCardTab, isNotEmpty));
    test('phoneTab', () => expect(fr.phoneTab, isNotEmpty));
    test('rechargeAmountLabel', () => expect(fr.rechargeAmountLabel, isNotEmpty));
    test('scanAndCharge', () => expect(fr.scanAndCharge, isNotEmpty));
    test('confirmAndCharge', () => expect(fr.confirmAndCharge, isNotEmpty));
    test('rechargeSuccess', () => expect(fr.rechargeSuccess, isNotEmpty));
    test('rechargePassenger', () => expect(fr.rechargePassenger, isNotEmpty));
    test('balanceLabel', () => expect(fr.balanceLabel, isNotEmpty));
    test('madSuffix', () => expect(fr.madSuffix, isNotEmpty));
    test('comingSoon', () => expect(fr.comingSoon, isNotEmpty));
    test('comingSoonDesc', () => expect(fr.comingSoonDesc, isNotEmpty));
    test('driverProfile', () => expect(fr.driverProfile, isNotEmpty));
    test('driverIdentified', () => expect(fr.driverIdentified, isNotEmpty));
    test('taxiNumberLabel', () => expect(fr.taxiNumberLabel, isNotEmpty));
    test('driverLabel', () => expect(fr.driverLabel, isNotEmpty));
    test('destination', () => expect(fr.destination, isNotEmpty));
    test('seatsAvailable', () => expect(fr.seatsAvailable, isNotEmpty));
    test('addToQueue', () => expect(fr.addToQueue, isNotEmpty));
    test('lineRequired', () => expect(fr.lineRequired, isNotEmpty));
    test('alreadyInQueue', () => expect(fr.alreadyInQueue, isNotEmpty));
    test('alreadyInQueueSub', () => expect(fr.alreadyInQueueSub, isNotEmpty));
    test('close', () => expect(fr.close, isNotEmpty));
    test('withdraw', () => expect(fr.withdraw, isNotEmpty));
    test('transfer', () => expect(fr.transfer, isNotEmpty));
    test('topUp', () => expect(fr.topUp, isNotEmpty));
    test('confirm', () => expect(fr.confirm, isNotEmpty));
    test('confirmOperation', () => expect(fr.confirmOperation, isNotEmpty));
    test('enterPinToValidate', () => expect(fr.enterPinToValidate, isNotEmpty));
    test('pinIncorrect', () => expect(fr.pinIncorrect, isNotEmpty));
    test('backToWallet', () => expect(fr.backToWallet, isNotEmpty));
    test('linkCopied', () => expect(fr.linkCopied, isNotEmpty));
    test('transferAmountTitle', () => expect(fr.transferAmountTitle, isNotEmpty));
    test('howMuchTransfer', () => expect(fr.howMuchTransfer, isNotEmpty));
    test('otherAmount', () => expect(fr.otherAmount, isNotEmpty));
    test('freeTransferNote', () => expect(fr.freeTransferNote, isNotEmpty));
    test('chooseRecipient', () => expect(fr.chooseRecipient, isNotEmpty));
    test('searchDriver', () => expect(fr.searchDriver, isNotEmpty));
    test('searchPlaceholder', () => expect(fr.searchPlaceholder, isNotEmpty));
    test('noResults', () => expect(fr.noResults, isNotEmpty));
    test('confirmTransferTitle', () => expect(fr.confirmTransferTitle, isNotEmpty));
    test('confirmTransferBtn', () => expect(fr.confirmTransferBtn, isNotEmpty));
    test('continueBtn', () => expect(fr.continueBtn, isNotEmpty));
    test('recipient', () => expect(fr.recipient, isNotEmpty));
    test('amountLabel', () => expect(fr.amountLabel, isNotEmpty));
    test('fees', () => expect(fr.fees, isNotEmpty));
    test('free', () => expect(fr.free, isNotEmpty));
    test('transferDoneTitle', () => expect(fr.transferDoneTitle, isNotEmpty));
    test('topUpWalletTitle', () => expect(fr.topUpWalletTitle, isNotEmpty));
    test('chooseTopUpMethod', () => expect(fr.chooseTopUpMethod, isNotEmpty));
    test('howToTopUp', () => expect(fr.howToTopUp, isNotEmpty));
    test('topUpAmountTitle', () => expect(fr.topUpAmountTitle, isNotEmpty));
    test('modeSubLabel', () => expect(fr.modeSubLabel, isNotEmpty));
    test('modeLabel', () => expect(fr.modeLabel, isNotEmpty));
    test('confirmTopUp', () => expect(fr.confirmTopUp, isNotEmpty));
    test('confirmTopUpBtn', () => expect(fr.confirmTopUpBtn, isNotEmpty));
    test('topUpSentTitle', () => expect(fr.topUpSentTitle, isNotEmpty));
    test('topUpSentSubtitle', () => expect(fr.topUpSentSubtitle, isNotEmpty));
    test('qrTopUpTitle', () => expect(fr.qrTopUpTitle, isNotEmpty));
    test('qrTopUpSubtitle', () => expect(fr.qrTopUpSubtitle, isNotEmpty));
    test('paymentLinkTitle', () => expect(fr.paymentLinkTitle, isNotEmpty));
    test('cardLinkSubtitle', () => expect(fr.cardLinkSubtitle, isNotEmpty));
    test('withdrawMethod', () => expect(fr.withdrawMethod, isNotEmpty));
    test('howToWithdraw', () => expect(fr.howToWithdraw, isNotEmpty));
    test('withdrawAmountTitle', () => expect(fr.withdrawAmountTitle, isNotEmpty));
    test('bankInfoTitle', () => expect(fr.bankInfoTitle, isNotEmpty));
    test('enterBankInfo', () => expect(fr.enterBankInfo, isNotEmpty));
    test('beneficiaryName', () => expect(fr.beneficiaryName, isNotEmpty));
    test('rib', () => expect(fr.rib, isNotEmpty));
    test('cashplusTitle', () => expect(fr.cashplusTitle, isNotEmpty));
    test('cashplusRecipient', () => expect(fr.cashplusRecipient, isNotEmpty));
    test('cashplusPhoneLabel', () => expect(fr.cashplusPhoneLabel, isNotEmpty));
    test('motif', () => expect(fr.motif, isNotEmpty));
    test('motifHint', () => expect(fr.motifHint, isNotEmpty));
    test('confirmWithdrawTitle', () => expect(fr.confirmWithdrawTitle, isNotEmpty));
    test('confirmWithdrawBtn', () => expect(fr.confirmWithdrawBtn, isNotEmpty));
    test('qrWithdrawTitle', () => expect(fr.qrWithdrawTitle, isNotEmpty));
    test('qrWithdrawSubtitle', () => expect(fr.qrWithdrawSubtitle, isNotEmpty));
    test('withdrawDoneTitle', () => expect(fr.withdrawDoneTitle, isNotEmpty));
    test('withdrawDoneSub', () => expect(fr.withdrawDoneSub, isNotEmpty));
    test('lineLabel', () => expect(fr.lineLabel, isNotEmpty));
    test('tagNotRecognized', () => expect(fr.tagNotRecognized, isNotEmpty));
    test('nfcDetected', () => expect(fr.nfcDetected, isNotEmpty));
    test('nfcIdentified', () => expect(fr.nfcIdentified, isNotEmpty));
    test('passengerLabel', () => expect(fr.passengerLabel, isNotEmpty));
    test('balance', () => expect(fr.balance, isNotEmpty));
    test('recentTrips', () => expect(fr.recentTrips, isNotEmpty));
    test('selectLine', () => expect(fr.selectLine, isNotEmpty));
    test('addSeat', () => expect(fr.addSeat, isNotEmpty));
    test('seatValidationTitle', () => expect(fr.seatValidationTitle, isNotEmpty));
    test('nextTaxi', () => expect(fr.nextTaxi, isNotEmpty));
    test('firstTaxiAvailableTitle', () => expect(fr.firstTaxiAvailableTitle, isNotEmpty));
    test('continueAnyway', () => expect(fr.continueAnyway, isNotEmpty));
    test('noConnectionTitle', () => expect(fr.noConnectionTitle, isNotEmpty));
    test('noConnectionBanner', () => expect(fr.noConnectionBanner, isNotEmpty));
    test('connectionRestored', () => expect(fr.connectionRestored, isNotEmpty));
    test('profile', () => expect(fr.profile, isNotEmpty));
    test('courtierRole', () => expect(fr.courtierRole, isNotEmpty));
    test('information', () => expect(fr.information, isNotEmpty));
    test('phone', () => expect(fr.phone, isNotEmpty));
    test('stationLabel', () => expect(fr.stationLabel, isNotEmpty));
    test('agentId', () => expect(fr.agentId, isNotEmpty));
    test('logout', () => expect(fr.logout, isNotEmpty));
    test('confirmLogoutTitle', () => expect(fr.confirmLogoutTitle, isNotEmpty));
    test('confirmLogoutMsg', () => expect(fr.confirmLogoutMsg, isNotEmpty));
    test('cancel', () => expect(fr.cancel, isNotEmpty));
    test('disconnect', () => expect(fr.disconnect, isNotEmpty));
    test('kioskMode', () => expect(fr.kioskMode, isNotEmpty));
    test('kioskModeActivate', () => expect(fr.kioskModeActivate, isNotEmpty));
    test('kioskModeDeactivate', () => expect(fr.kioskModeDeactivate, isNotEmpty));
    test('navCashouts', () => expect(fr.navCashouts, isNotEmpty));
    test('cashoutsTitle', () => expect(fr.cashoutsTitle, isNotEmpty));
    test('totalCashouts', () => expect(fr.totalCashouts, isNotEmpty));
    test('cashoutsListLabel', () => expect(fr.cashoutsListLabel, isNotEmpty));
    test('noPayments', () => expect(fr.noPayments, isNotEmpty));
    test('filterDate', () => expect(fr.filterDate, isNotEmpty));
    test('dateFrom', () => expect(fr.dateFrom, isNotEmpty));
    test('dateTo', () => expect(fr.dateTo, isNotEmpty));
    test('today', () => expect(fr.today, isNotEmpty));
    test('allDates', () => expect(fr.allDates, isNotEmpty));
    test('allMethods', () => expect(fr.allMethods, isNotEmpty));
    test('filtersLabel', () => expect(fr.filtersLabel, isNotEmpty));
    test('clearFilters', () => expect(fr.clearFilters, isNotEmpty));
    test('applyFilters', () => expect(fr.applyFilters, isNotEmpty));
    test('filterTaxi', () => expect(fr.filterTaxi, isNotEmpty));
    test('filterDriverName', () => expect(fr.filterDriverName, isNotEmpty));
    test('filterLine', () => expect(fr.filterLine, isNotEmpty));
    test('trips', () => expect(fr.trips, isNotEmpty));
    test('amountToPay', () => expect(fr.amountToPay, isNotEmpty));
    test('taxiFullTitle', () => expect(fr.taxiFullTitle, isNotEmpty));
    test('taxiFullSubtitle', () => expect(fr.taxiFullSubtitle, isNotEmpty));
    test('cashSeatsLabel', () => expect(fr.cashSeatsLabel, isNotEmpty));
    test('nfcSeatsLabel', () => expect(fr.nfcSeatsLabel, isNotEmpty));
    test('cashoutLoadError', () => expect(fr.cashoutLoadError, isNotEmpty));
    test('ticketsPageTitle', () => expect(fr.ticketsPageTitle, isNotEmpty));
    test('ticketsListLabel', () => expect(fr.ticketsListLabel, isNotEmpty));
    test('cashout', () => expect(fr.cashout, isNotEmpty));
    test('cashoutAll', () => expect(fr.cashoutAll, isNotEmpty));
    test('confirmCashout', () => expect(fr.confirmCashout, isNotEmpty));
    test('confirmCashoutTitle', () => expect(fr.confirmCashoutTitle, isNotEmpty));
    test('cashoutSuccess', () => expect(fr.cashoutSuccess, isNotEmpty));
    test('unpaid', () => expect(fr.unpaid, isNotEmpty));
    test('paid', () => expect(fr.paid, isNotEmpty));
    test('allTickets', () => expect(fr.allTickets, isNotEmpty));
    test('noTickets', () => expect(fr.noTickets, isNotEmpty));
    test('totalCashToPay', () => expect(fr.totalCashToPay, isNotEmpty));
    test('nfcAutoTransferred', () => expect(fr.nfcAutoTransferred, isNotEmpty));
    test('printStation', () => expect(fr.printStation, isNotEmpty));
    test('printLine', () => expect(fr.printLine, isNotEmpty));
    test('printTaxi', () => expect(fr.printTaxi, isNotEmpty));
    test('printDriver', () => expect(fr.printDriver, isNotEmpty));
    test('printSeats', () => expect(fr.printSeats, isNotEmpty));
    test('printTotal', () => expect(fr.printTotal, isNotEmpty));
    test('printPayment', () => expect(fr.printPayment, isNotEmpty));
    test('printCash', () => expect(fr.printCash, isNotEmpty));
    test('printThankYou', () => expect(fr.printThankYou, isNotEmpty));
    test('printRechargeTitle', () => expect(fr.printRechargeTitle, isNotEmpty));
    test('printName', () => expect(fr.printName, isNotEmpty));
    test('printPhone', () => expect(fr.printPhone, isNotEmpty));
    test('printAmount', () => expect(fr.printAmount, isNotEmpty));
    test('printBalanceBefore', () => expect(fr.printBalanceBefore, isNotEmpty));
    test('printBalanceAfter', () => expect(fr.printBalanceAfter, isNotEmpty));
    test('language', () => expect(fr.language, isNotEmpty));
    test('selectLanguage', () => expect(fr.selectLanguage, isNotEmpty));
    test('french', () => expect(fr.french, isNotEmpty));
    test('arabic', () => expect(fr.arabic, isNotEmpty));
    test('settings', () => expect(fr.settings, isNotEmpty));
    test('appearance', () => expect(fr.appearance, isNotEmpty));
    test('themeMode', () => expect(fr.themeMode, isNotEmpty));
    test('lightMode', () => expect(fr.lightMode, isNotEmpty));
    test('darkMode', () => expect(fr.darkMode, isNotEmpty));
    test('about', () => expect(fr.about, isNotEmpty));
    test('version', () => expect(fr.version, isNotEmpty));
  });

  // ── Arabic getters (covers ar branch of _t) ──────────────────────────────

  group('Arabic getters return non-empty strings', () {
    test('login ar', () => expect(ar.login, isNotEmpty));
    test('loginSubtitle ar', () => expect(ar.loginSubtitle, isNotEmpty));
    test('phoneNumber ar', () => expect(ar.phoneNumber, isNotEmpty));
    test('password ar', () => expect(ar.password, isNotEmpty));
    test('connect ar', () => expect(ar.connect, isNotEmpty));
    test('connectionError ar', () => expect(ar.connectionError, isNotEmpty));
    test('navReserve ar', () => expect(ar.navReserve, isNotEmpty));
    test('bookingTitle ar', () => expect(ar.bookingTitle, isNotEmpty));
    test('cash ar', () => expect(ar.cash, isNotEmpty));
    test('full ar', () => expect(ar.full, isNotEmpty));
    test('bookingConfirmed ar', () => expect(ar.bookingConfirmed, isNotEmpty));
    test('ok ar', () => expect(ar.ok, isNotEmpty));
    test('nfcApproach ar', () => expect(ar.nfcApproach, isNotEmpty));
    test('seats ar', () => expect(ar.seats, isNotEmpty));
    test('insufficientBalance ar', () => expect(ar.insufficientBalance, isNotEmpty));
    test('nfcError ar', () => expect(ar.nfcError, isNotEmpty));
    test('linkPassenger ar', () => expect(ar.linkPassenger, isNotEmpty));
    test('linkSuccess ar', () => expect(ar.linkSuccess, isNotEmpty));
    test('retry ar', () => expect(ar.retry, isNotEmpty));
    test('comingSoon ar', () => expect(ar.comingSoon, isNotEmpty));
    test('driverProfile ar', () => expect(ar.driverProfile, isNotEmpty));
    test('destination ar', () => expect(ar.destination, isNotEmpty));
    test('addToQueue ar', () => expect(ar.addToQueue, isNotEmpty));
    test('alreadyInQueue ar', () => expect(ar.alreadyInQueue, isNotEmpty));
    test('close ar', () => expect(ar.close, isNotEmpty));
    test('withdraw ar', () => expect(ar.withdraw, isNotEmpty));
    test('transfer ar', () => expect(ar.transfer, isNotEmpty));
    test('topUp ar', () => expect(ar.topUp, isNotEmpty));
    test('confirm ar', () => expect(ar.confirm, isNotEmpty));
    test('noResults ar', () => expect(ar.noResults, isNotEmpty));
    test('free ar', () => expect(ar.free, isNotEmpty));
    test('transferDoneTitle ar', () => expect(ar.transferDoneTitle, isNotEmpty));
    test('topUpSentTitle ar', () => expect(ar.topUpSentTitle, isNotEmpty));
    test('withdrawDoneTitle ar', () => expect(ar.withdrawDoneTitle, isNotEmpty));
    test('profile ar', () => expect(ar.profile, isNotEmpty));
    test('logout ar', () => expect(ar.logout, isNotEmpty));
    test('disconnect ar', () => expect(ar.disconnect, isNotEmpty));
    test('kioskMode ar', () => expect(ar.kioskMode, isNotEmpty));
    test('kioskModeActivate ar', () => expect(ar.kioskModeActivate, isNotEmpty));
    test('kioskModeDeactivate ar', () => expect(ar.kioskModeDeactivate, isNotEmpty));
    test('noPayments ar', () => expect(ar.noPayments, isNotEmpty));
    test('taxiFullTitle ar', () => expect(ar.taxiFullTitle, isNotEmpty));
    test('cashout ar', () => expect(ar.cashout, isNotEmpty));
    test('cashoutSuccess ar', () => expect(ar.cashoutSuccess, isNotEmpty));
    test('unpaid ar', () => expect(ar.unpaid, isNotEmpty));
    test('paid ar', () => expect(ar.paid, isNotEmpty));
    test('noTickets ar', () => expect(ar.noTickets, isNotEmpty));
    test('printThankYou ar', () => expect(ar.printThankYou, isNotEmpty));
    test('language ar', () => expect(ar.language, isNotEmpty));
    test('settings ar', () => expect(ar.settings, isNotEmpty));
    test('appearance ar', () => expect(ar.appearance, isNotEmpty));
    test('lightMode ar', () => expect(ar.lightMode, isNotEmpty));
    test('darkMode ar', () => expect(ar.darkMode, isNotEmpty));
    test('about ar', () => expect(ar.about, isNotEmpty));
    test('version ar', () => expect(ar.version, isNotEmpty));
  });

  // ── Method getters with parameters ───────────────────────────────────────

  group('parameterised methods (fr)', () {
    test('freeSeats singular', () => expect(fr.freeSeats(1), contains('1')));
    test('freeSeats plural', () => expect(fr.freeSeats(3), contains('3')));
    test('seatsBookedSuccess singular', () => expect(fr.seatsBookedSuccess(1), contains('1')));
    test('seatsBookedSuccess plural', () => expect(fr.seatsBookedSuccess(3), contains('3')));
    test('seatValidationHasNext', () => expect(fr.seatValidationHasNext(2), contains('2')));
    test('seatValidationNoNext', () => expect(fr.seatValidationNoNext(2), contains('2')));
    test('firstTaxiAvailableMsg', () => expect(fr.firstTaxiAvailableMsg(3, 'ABC-123'), contains('ABC-123')));
    test('cannotReserveBeforeFirstFull', () => expect(fr.cannotReserveBeforeFirstFull(2, 2, 'ABC-123'), contains('ABC-123')));
    test('transferDoneSub', () => expect(fr.transferDoneSub('100', 'Ahmed'), contains('Ahmed')));
    test('confirmCashoutMsg', () => expect(fr.confirmCashoutMsg('50'), contains('50')));
    test('confirmCashoutAllMsg', () => expect(fr.confirmCashoutAllMsg(3, '150'), contains('150')));
  });

  group('parameterised methods (ar)', () {
    test('freeSeats singular ar', () => expect(ar.freeSeats(1), contains('1')));
    test('freeSeats plural ar', () => expect(ar.freeSeats(2), contains('2')));
    test('seatsBookedSuccess ar', () => expect(ar.seatsBookedSuccess(2), contains('2')));
    test('seatValidationHasNext ar', () => expect(ar.seatValidationHasNext(3), contains('3')));
    test('seatValidationNoNext ar', () => expect(ar.seatValidationNoNext(1), contains('1')));
    test('firstTaxiAvailableMsg ar', () => expect(ar.firstTaxiAvailableMsg(2, 'XYZ'), contains('XYZ')));
    test('cannotReserveBeforeFirstFull ar', () => expect(ar.cannotReserveBeforeFirstFull(1, 3, 'XYZ'), contains('XYZ')));
    test('transferDoneSub ar', () => expect(ar.transferDoneSub('200', 'محمد'), contains('محمد')));
    test('confirmCashoutMsg ar', () => expect(ar.confirmCashoutMsg('75'), contains('75')));
    test('confirmCashoutAllMsg ar', () => expect(ar.confirmCashoutAllMsg(5, '200'), contains('200')));
  });

  // ── Delegate ─────────────────────────────────────────────────────────────

  group('AppLocalizations delegate', () {
    test('isSupported returns true for fr', () {
      expect(AppLocalizations.delegate.isSupported(const Locale('fr')), isTrue);
    });

    test('isSupported returns true for ar', () {
      expect(AppLocalizations.delegate.isSupported(const Locale('ar')), isTrue);
    });

    test('isSupported returns false for en', () {
      expect(
          AppLocalizations.delegate.isSupported(const Locale('en')), isFalse);
    });

    test('shouldReload returns false', () {
      expect(AppLocalizations.delegate.shouldReload(AppLocalizations.delegate),
          isFalse);
    });

    test('load returns AppLocalizations instance', () async {
      final l = await AppLocalizations.delegate.load(const Locale('fr'));
      expect(l, isA<AppLocalizations>());
      expect(l.isAr, isFalse);
    });

    test('load returns Arabic AppLocalizations', () async {
      final l = await AppLocalizations.delegate.load(const Locale('ar'));
      expect(l.isAr, isTrue);
    });

    test('supportedLocales contains fr and ar', () {
      expect(AppLocalizations.supportedLocales,
          containsAll([const Locale('fr'), const Locale('ar')]));
    });
  });
}
