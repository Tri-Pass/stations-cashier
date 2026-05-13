import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  const AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const delegate = _AppLocalizationsDelegate();
  static const supportedLocales = [Locale('fr'), Locale('ar')];

  bool get isAr => locale.languageCode == 'ar';

  String _t(String fr, String ar) => isAr ? ar : fr;

  // ── App ──────────────────────────────────────────────────────────────────
  String get appName => 'wetaxi.station';

  // ── Login ────────────────────────────────────────────────────────────────
  String get login => _t('Connexion', 'تسجيل الدخول');

  String get loginSubtitle => _t(
      'Connectez-vous à votre compte caissier', 'سجّل دخولك إلى حساب الصراف');

  String get phoneNumber => _t('Numéro de téléphone', 'رقم الهاتف');

  String get password => _t('Mot de passe', 'كلمة المرور');

  String get connect => _t('Se connecter', 'تسجيل الدخول');

  String get connectionError =>
      _t('Erreur de connexion au serveur', 'خطأ في الاتصال بالخادم');

  // ── Navigation (bottom bar) ───────────────────────────────────────────────
  String get navReserve => _t('Réserver', 'حجز');

  String get navLinkNfc => _t('NFC', 'NFC');

  // ── Booking ──────────────────────────────────────────────────────────────
  String get bookingTitle => _t('Réservation', 'الحجز');

  String get testPrint => _t('Test impression', 'اختبار الطباعة');

  String get sectionLines => _t('LIGNES', 'الخطوط');

  String get sectionPayment => _t('MODE DE PAIEMENT', 'طريقة الدفع');

  String get taxisInQueue => _t('TAXIS EN FILE', 'تاكسي في الطابور');

  String get selectLineHint => _t(
      'Sélectionnez une ligne\npour voir les taxis disponibles',
      'اختر خطاً لرؤية التاكسيات المتاحة');

  String get cash => _t('Cash', 'نقداً');

  String get nfc => 'NFC';

  String get firstBadge => _t('1er', 'الأول');

  String get noTaxiForLine =>
      _t('Aucun taxi disponible pour cette ligne', 'لا يوجد تاكسي لهذا الخط');

  String freeSeats(int n) =>
      _t('$n libre${n > 1 ? "s" : ""}', '$n شاغل${n > 1 ? "ة" : ""}');

  String get full => _t('Complet', 'مكتمل');

  String get bookingConfirmed =>
      _t('Réservation confirmée !', 'تم تأكيد الحجز!');

  String seatsBookedSuccess(int n) => _t(
      '$n place${n > 1 ? "s" : ""} réservée${n > 1 ? "s" : ""} avec succès',
      'تم حجز $n مقعد بنجاح');

  String get ok => _t('OK', 'حسناً');

  // ── NFC scan dialog (booking) ─────────────────────────────────────────────
  String get nfcReading => _t('Lecture en cours…', 'جاري القراءة...');

  String get nfcApproach =>
      _t('Approchez la carte NFC du passager', 'قرّب بطاقة NFC للراكب');

  String get cardRead => _t('Carte lue ✓', 'تمت قراءة البطاقة ✓');

  String get seats => _t('Places', 'مقاعد');

  String get amount => _t('Montant', 'المبلغ');

  String get currentBalance => _t('Solde actuel', 'الرصيد الحالي');

  String get balanceAfter => _t('Solde après', 'الرصيد بعد');

  String get insufficientBalance => _t('Solde insuffisant', 'رصيد غير كافٍ');

  String get confirmAndPrint => _t('Confirmer & Imprimer', 'تأكيد وطباعة');

  String get processing => _t('Traitement...', 'جاري المعالجة...');

  String get nfcProcessing => _t('Traitement en cours…', 'جاري المعالجة...');

  String get nfcError => _t('Erreur NFC', 'خطأ NFC');

  String get nfcBookingFailed =>
      _t('Échec de la réservation. Réessayez.', 'فشل الحجز. حاول مرة أخرى.');

  // ── NFC link page ─────────────────────────────────────────────────────────
  String get nfcLinkTitle => _t('NFC', 'NFC');

  String get nfcLinkModeTab => _t('Lier', 'ربط');

  String get nfcRechargeModeTab => _t('Recharger', 'شحن');

  String get nfcLinkSubtitle =>
      _t('Lier un passager à sa carte NFC', 'ربط راكب ببطاقته NFC');

  String get nfcLinkDesc => _t(
      'Scannez la carte NFC pour lier le passager à son compte',
      'امسح بطاقة NFC لربط الراكب بحسابه');

  String get nfcRechargeDesc => _t(
      'Approchez la carte NFC du passager\npour recharger son compte',
      'قرّب بطاقة NFC للراكب\nلشحن حسابه');

  String get scanNfcCard => _t('Scanner une carte NFC', 'مسح بطاقة NFC');

  String get nfcScanning => _t('Scan en cours…', 'جاري المسح...');

  String get nfcApproachDetect => _t(
      'Approchez la carte NFC du passager\npour la détecter',
      'قرّب بطاقة NFC للراكب للكشف عنها');

  String get cardDetected => _t('Carte détectée', 'تم اكتشاف البطاقة');

  String get nfcIdLabel => _t('IDENTIFIANT NFC', 'معرف NFC');

  String get passengerToLink => _t('PASSAGER À LIER', 'الراكب المراد ربطه');

  String get passengerPhoneHint =>
      _t('N° de téléphone du passager', 'رقم هاتف الراكب');

  String get passengerNameHint =>
      _t('Nom du passager', 'اسم الراكب');

  String get fieldNameRequired => _t('Nom requis', 'الاسم مطلوب');

  String get fieldPhoneRequired => _t('Téléphone requis', 'الهاتف مطلوب');

  String get linkPassenger => _t('Lier le passager', 'ربط الراكب');

  String get linkSuccess => _t('Passager lié avec succès', 'تم ربط الراكب بنجاح');

  String get retry => _t('Réessayer', 'إعادة المحاولة');

  String get scanAnother => _t('Scanner une autre carte', 'مسح بطاقة أخرى');

  String get nfcCardTab => _t('Carte NFC', 'بطاقة NFC');

  String get phoneTab => _t('Téléphone', 'هاتف');

  String get rechargeAmountLabel => _t('Montant (MAD)', 'المبلغ (درهم)');

  String get scanAndCharge => _t('Scanner & Charger', 'مسح وشحن');

  String get confirmAndCharge => _t('Confirmer & Recharger', 'تأكيد الشحن');

  String get rechargeSuccess => _t('Compte rechargé avec succès', 'تم شحن الحساب بنجاح');

  String get rechargePassenger => _t('Recharger', 'شحن');

  String get balanceLabel => _t('Solde', 'الرصيد');

  String get madSuffix => 'MAD';

  String get comingSoon => _t('Fonctionnalité à venir', 'ميزة قادمة');

  String get comingSoonDesc => _t(
      'La liaison de passagers sera disponible\ndans une prochaine mise à jour.',
      'سيتم توفير ربط الركاب في تحديث قادم.');

  // ── Driver NFC confirm ────────────────────────────────────────────────────
  String get driverProfile => _t('Profil chauffeur', 'ملف تعريف السائق');

  String get driverIdentified => _t('Chauffeur identifié', 'تم التعرف على السائق');

  String get taxiNumberLabel => _t('N° taxi', 'رقم التاكسي');

  String get driverLabel => _t('Chauffeur', 'السائق');

  String get destination => _t('Destination', 'الوجهة');

  String get seatsAvailable => _t('places disponibles', 'مقاعد متاحة');

  String get addToQueue => _t('Ajouter à la file', 'إضافة للطابور');

  String get lineRequired => _t('Veuillez sélectionner une ligne', 'يرجى اختيار الخط');

  String get alreadyInQueue => _t('Déjà dans la file d\'attente', 'موجود في الطابور');

  String get alreadyInQueueSub => _t('Ce chauffeur est déjà enregistré dans la file d\'attente', 'هذا السائق مسجل بالفعل في قائمة الانتظار');

  String get close => _t('Fermer', 'إغلاق');

  String get withdraw => _t('Retirer', 'سحب');
  String get transfer => _t('Transférer', 'تحويل');
  String get topUp    => _t('Recharger', 'شحن');

  // ── Wallet ────────────────────────────────────────────────────────────────
  String get confirm            => _t('Confirmer', 'تأكيد');

  // PIN sheet
  String get confirmOperation   => _t('Confirmer l\'opération', 'تأكيد العملية');
  String get enterPinToValidate => _t('Entrez votre code PIN pour valider', 'أدخل رمز PIN للتأكيد');
  String get pinIncorrect       => _t('Code PIN incorrect', 'رمز PIN غير صحيح');
  String get backToWallet       => _t('Retour au portefeuille', 'العودة للمحفظة');
  String get linkCopied         => _t('Lien copié', 'تم نسخ الرابط');

  // Transfer page
  String get transferAmountTitle  => _t('Montant du transfert', 'مبلغ التحويل');
  String get howMuchTransfer      => _t('Combien souhaitez-vous transférer ?', 'كم تريد أن تحوّل؟');
  String get otherAmount          => _t('Autre montant', 'مبلغ آخر');
  String get freeTransferNote     => _t('Les transferts sont gratuits', 'التحويلات مجانية');
  String get chooseRecipient      => _t('Choisir le destinataire', 'اختر المستلم');
  String get searchDriver         => _t('Rechercher un utilisateur', 'ابحث عن مستخدم');
  String get searchPlaceholder    => _t('Nom ou téléphone...', 'اسم أو هاتف...');
  String get noResults            => _t('Aucun résultat', 'لا توجد نتائج');
  String get confirmTransferTitle => _t('Confirmer le transfert', 'تأكيد التحويل');
  String get confirmTransferBtn   => _t('Confirmer', 'تأكيد');
  String get continueBtn          => _t('Continuer', 'متابعة');
  String get recipient            => _t('Destinataire', 'المستلم');
  String get amountLabel          => _t('Montant', 'المبلغ');
  String get fees                 => _t('Frais', 'الرسوم');
  String get free                 => _t('Gratuit', 'مجاناً');
  String get transferDoneTitle    => _t('Transfert envoyé !', 'تم إرسال التحويل!');
  String transferDoneSub(String amount, String name) =>
      _t('$amount MAD envoyés à $name', 'تم إرسال $amount درهم إلى $name');

  // TopUp page
  String get topUpWalletTitle   => _t('Recharger mon portefeuille', 'شحن محفظتي');
  String get chooseTopUpMethod  => _t('Choisir la méthode', 'اختر الطريقة');
  String get howToTopUp         => _t('Comment souhaitez-vous recharger ?', 'كيف تريد الشحن؟');
  String get topUpAmountTitle   => _t('Montant à recharger', 'المبلغ المراد شحنه');
  String get modeSubLabel       => _t('Via ', 'عبر ');
  String get modeLabel          => _t('Méthode', 'الطريقة');
  String get confirmTopUp       => _t('Confirmer la recharge', 'تأكيد الشحن');
  String get confirmTopUpBtn    => _t('Confirmer', 'تأكيد');
  String get topUpSentTitle     => _t('Demande envoyée !', 'تم إرسال الطلب!');
  String get topUpSentSubtitle  => _t('Votre demande de recharge a été soumise', 'تم تقديم طلب الشحن');
  String get qrTopUpTitle       => _t('Code QR généré', 'تم توليد رمز QR');
  String get qrTopUpSubtitle    => _t('Scannez ce code au guichet', 'امسح هذا الرمز عند الشباك');
  String get paymentLinkTitle   => _t('Lien de paiement', 'رابط الدفع');
  String get cardLinkSubtitle   => _t('Utilisez ce lien pour effectuer le paiement', 'استخدم هذا الرابط للدفع');

  // Withdraw page
  String get withdrawMethod       => _t('Méthode de retrait', 'طريقة السحب');
  String get howToWithdraw        => _t('Comment souhaitez-vous retirer ?', 'كيف تريد السحب؟');
  String get withdrawAmountTitle  => _t('Montant à retirer', 'المبلغ المراد سحبه');
  String get bankInfoTitle        => _t('Informations bancaires', 'معلومات بنكية');
  String get enterBankInfo        => _t('Entrez vos coordonnées bancaires', 'أدخل بياناتك البنكية');
  String get beneficiaryName      => _t('Nom du bénéficiaire', 'اسم المستفيد');
  String get rib                  => _t('RIB', 'رقم الحساب (RIB)');
  String get cashplusTitle        => _t('CashPlus', 'كاش بلاس');
  String get cashplusRecipient    => _t('Numéro du bénéficiaire', 'رقم المستفيد');
  String get cashplusPhoneLabel   => _t('Téléphone CashPlus', 'هاتف كاش بلاس');
  String get motif                => _t('Motif', 'السبب');
  String get motifHint            => _t('Optionnel', 'اختياري');
  String get confirmWithdrawTitle => _t('Confirmer le retrait', 'تأكيد السحب');
  String get confirmWithdrawBtn   => _t('Confirmer', 'تأكيد');
  String get qrWithdrawTitle      => _t('Code QR de retrait', 'رمز QR للسحب');
  String get qrWithdrawSubtitle   => _t('Présentez ce code au guichet', 'أرِ هذا الرمز عند الشباك');
  String get withdrawDoneTitle    => _t('Retrait en cours...', 'السحب قيد المعالجة...');
  String get withdrawDoneSub      => _t('Votre demande de retrait a été traitée', 'تم معالجة طلب السحب');

  String get lineLabel => _t('ligne', 'خط');

  String get tagNotRecognized =>
      _t('Tag NFC non reconnu', 'لم يتم التعرف على بطاقة NFC');

  // ── NFC confirm page ──────────────────────────────────────────────────────
  String get nfcDetected => _t('Profil passager', 'ملف تعريف الراكب');

  String get nfcIdentified => _t('Passager identifié', 'تم التعرف على الراكب');

  String get passengerLabel => _t('Passager', 'الراكب');

  String get balance => _t('Solde', 'الرصيد');

  String get recentTrips => _t('Courses récentes', 'الرحلات الأخيرة');

  String get selectLine => _t('Sélectionner la ligne', 'اختر الخط');

  String get addSeat => _t('Ajouter un passager', 'إضافة راكب');

  String get seatValidationTitle => _t('Places insuffisantes', 'مقاعد غير كافية');

  String seatValidationHasNext(int available) => _t(
      'Le premier taxi n\'a que $available place(s) disponible(s).\nVoulez-vous réserver avec le taxi suivant ?',
      'التاكسي الأول لديه $available مقعد(مقاعد) فقط.\nهل تريد الحجز مع التاكسي التالي؟');

  String seatValidationNoNext(int available) => _t(
      'Aucun taxi disponible n\'a assez de places ($available place(s) au maximum).',
      'لا يوجد تاكسي متاح يملك مقاعد كافية ($available مقعد كحد أقصى).');

  String get nextTaxi => _t('Taxi suivant', 'التاكسي التالي');

  String get firstTaxiAvailableTitle => _t('Premier taxi disponible', 'التاكسي الأول متاح');

  String firstTaxiAvailableMsg(int available, String plate) => _t(
      'Le taxi $plate (1er) a $available place(s) disponible(s).\nVoulez-vous quand même réserver ce taxi ?',
      'التاكسي $plate (الأول) لديه $available مقعد(مقاعد) متاحة.\nهل تريد الحجز مع هذا التاكسي على أي حال؟');

  String cannotReserveBeforeFirstFull(int position, int available, String plate) => _t(
      'Impossible de réserver depuis ce taxi. Le taxi n°$position ($plate) a encore $available place(s) disponible(s).',
      'لا يمكن الحجز من هذا التاكسي. التاكسي رقم $position ($plate) لا يزال لديه $available مقعد(مقاعد) متاحة.');

  String get continueAnyway => _t('Continuer', 'متابعة');

  // ── Connectivity ─────────────────────────────────────────────────────────
  String get noConnectionTitle =>
      _t('Pas de connexion internet', 'لا يوجد اتصال بالإنترنت');

  String get noConnectionBanner =>
      _t('Vérification de la connexion…', 'جارٍ التحقق من الاتصال…');

  String get connectionRestored => _t('Connexion rétablie', 'تم استعادة الاتصال');

  // ── Profile ───────────────────────────────────────────────────────────────
  String get profile => _t('Profil', 'الملف الشخصي');

  String get courtierRole => _t('Caissier de station', 'صراف محطة');

  String get information => _t('Informations', 'المعلومات');

  String get phone => _t('Téléphone', 'الهاتف');

  String get stationLabel => _t('Station', 'المحطة');

  String get agentId => _t('Identifiant agent', 'رقم الوكيل');

  String get logout => _t('Déconnexion', 'تسجيل الخروج');

  String get confirmLogoutTitle => _t('Déconnexion', 'تسجيل الخروج');

  String get confirmLogoutMsg =>
      _t('Voulez-vous vraiment vous déconnecter ?', 'هل تريد تسجيل الخروج؟');

  String get cancel => _t('Annuler', 'إلغاء');

  String get disconnect => _t('Déconnecter', 'خروج');

  // ── Cashouts ─────────────────────────────────────────────────────────────
  String get navCashouts => _t('Paiements', 'المدفوعات');

  String get cashoutsTitle => _t('Paiements chauffeurs', 'مدفوعات السائقين');

  String get totalCashouts => _t('Total à payer aux chauffeurs', 'إجمالي المستحق للسائقين');

  String get cashoutsListLabel => _t('DÉTAIL DES PAIEMENTS', 'تفاصيل المدفوعات');

  String get noPayments => _t('Aucun paiement', 'لا توجد مدفوعات');

  String get filterDate => _t('DATE', 'التاريخ');

  String get dateFrom => _t('Du', 'من');

  String get dateTo => _t('Au', 'إلى');

  String get today => _t('Aujourd\'hui', 'اليوم');

  String get allDates => _t('Toutes les dates', 'كل التواريخ');

  String get allMethods => _t('Tous', 'الكل');

  String get filtersLabel => _t('Filtres', 'الفلاتر');

  String get clearFilters => _t('Effacer', 'مسح');

  String get applyFilters => _t('Appliquer', 'تطبيق');

  String get filterTaxi => _t('N° taxi (plaque)', 'رقم التاكسي');

  String get filterDriverName => _t('Nom du chauffeur', 'اسم السائق');

  String get filterLine => _t('Ligne (ex: Rabat)', 'الخط (مثال: الرباط)');

  String get trips => _t('courses', 'رحلة');

  String get amountToPay => _t('Montant à payer', 'المبلغ المستحق');

  String get taxiFullTitle => _t('Taxi complet !', 'اكتمل التاكسي!');

  String get taxiFullSubtitle => _t(
      'Payez le montant suivant au chauffeur',
      'ادفع المبلغ التالي للسائق');

  String get cashSeatsLabel => _t('Places cash', 'مقاعد نقداً');

  String get nfcSeatsLabel => _t('Places NFC', 'مقاعد NFC');

  String get cashoutLoadError => _t(
      'Impossible de charger les données — réessayez',
      'تعذّر تحميل البيانات — أعد المحاولة');

  // ── Driver tickets ────────────────────────────────────────────────────────
  String get ticketsPageTitle  => _t('Tickets de course', 'تذاكر الرحلة');
  String get ticketsListLabel  => _t('LISTE DES TICKETS', 'قائمة التذاكر');
  String get cashout           => _t('Payer', 'دفع');
  String get cashoutAll        => _t('Tout payer', 'دفع الكل');
  String get confirmCashout    => _t('Confirmer', 'تأكيد');
  String get confirmCashoutTitle => _t('Confirmer le paiement', 'تأكيد الدفع');
  String get cashoutSuccess    => _t('Paiement effectué', 'تم الدفع بنجاح');
  String get unpaid            => _t('À payer', 'للدفع');
  String get paid              => _t('Payé', 'مدفوع');
  String get allTickets        => _t('Tous', 'الكل');
  String get noTickets         => _t('Aucun ticket pour ce chauffeur', 'لا توجد تذاكر لهذا السائق');
  String get totalCashToPay    => _t('À payer au chauffeur', 'للدفع للسائق');
  String get nfcAutoTransferred => _t('Transféré auto.', 'محوّل تلقائياً');

  String confirmCashoutMsg(String amount) => _t(
      'Payer $amount MAD au chauffeur pour ce ticket ?',
      'هل تريد دفع $amount درهم للسائق لهذه الرحلة؟');

  String confirmCashoutAllMsg(int count, String amount) => _t(
      'Payer $count ticket(s) au chauffeur pour un total de $amount MAD ?',
      'دفع $count رحلة للسائق بمجموع $amount درهم؟');

  // ── Settings ──────────────────────────────────────────────────────────────
  String get language => _t('Langue', 'اللغة');

  String get selectLanguage => _t('Choisir la langue', 'اختر اللغة');

  String get french => 'Français';

  String get arabic => 'العربية';

  String get settings => _t('Paramètres', 'الإعدادات');

  String get appearance => _t('Apparence', 'المظهر');

  String get themeMode => _t('Mode d\'affichage', 'وضع العرض');

  String get lightMode => _t('Mode clair', 'الوضع الفاتح');

  String get darkMode => _t('Mode sombre', 'الوضع الداكن');

  String get about => _t('À propos', 'حول');

  String get version => _t('Version', 'الإصدار');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['fr', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_) => false;
}
