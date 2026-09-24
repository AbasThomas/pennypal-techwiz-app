import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';

/// HugeIcons replacement for Flutter's [Icon] widget.
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.icon, {
    super.key,
    this.color,
    this.size,
    this.semanticLabel,
  });

  final List<List<dynamic>> icon;
  final Color? color;
  final double? size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => HugeIcon(
        icon: icon,
        color: color,
        size: size ?? IconTheme.of(context).size ?? 24,
      );
}

/// Semantic aliases providing HugeIcons throughout the app.
abstract final class AppIcons {
  // Navigation
  static const home = HugeIcons.strokeRoundedHome01;
  static const wallet = HugeIcons.strokeRoundedWallet01;
  static const chart = HugeIcons.strokeRoundedPieChart;
  static const book = HugeIcons.strokeRoundedBookOpen01;
  static const menu = HugeIcons.strokeRoundedMenu01;
  static const grid = HugeIcons.strokeRoundedDashboardSquare01;

  // Actions & Arrows
  static const add = HugeIcons.strokeRoundedAdd01;
  static const remove = HugeIcons.strokeRoundedMinusSign;
  static const arrowDown = HugeIcons.strokeRoundedArrowDown01;
  static const arrowUp = HugeIcons.strokeRoundedArrowUp01;
  static const arrowLeft = HugeIcons.strokeRoundedArrowLeft01;
  static const arrowRight = HugeIcons.strokeRoundedArrowRight01;
  static const arrowForward = HugeIcons.strokeRoundedArrowRight01;
  static const arrowBack = HugeIcons.strokeRoundedArrowLeft01;
  static const chevronDown = HugeIcons.strokeRoundedArrowDown01;
  static const chevronRight = HugeIcons.strokeRoundedArrowRight01;
  static const chevronLeft = HugeIcons.strokeRoundedArrowLeft01;
  static const chevronUp = HugeIcons.strokeRoundedArrowUp01;

  // Finance & Banking
  static const creditCard = HugeIcons.strokeRoundedCreditCard;
  static const bank = HugeIcons.strokeRoundedBank;
  static const invoice = HugeIcons.strokeRoundedInvoice01;
  static const piggyBank = HugeIcons.strokeRoundedPiggyBank;
  static const target = HugeIcons.strokeRoundedTarget02;
  static const shield = HugeIcons.strokeRoundedShield01;
  static const calculator = HugeIcons.strokeRoundedCalculator;
  static const trendingUp = HugeIcons.strokeRoundedTrendingUp;
  static const money = HugeIcons.strokeRoundedMoney01;
  static const coins = HugeIcons.strokeRoundedCoins01;
  static const receipt = HugeIcons.strokeRoundedReceipt;
  static const exchange = HugeIcons.strokeRoundedExchange01;
  static const transfer = HugeIcons.strokeRoundedTradeUp;

  // Categories
  static const food = HugeIcons.strokeRoundedRestaurant01;
  static const shoppingBag = HugeIcons.strokeRoundedShoppingBag01;
  static const shoppingCart = HugeIcons.strokeRoundedShoppingCart01;
  static const transport = HugeIcons.strokeRoundedCar01;
  static const house = HugeIcons.strokeRoundedHouse01;
  static const health = HugeIcons.strokeRoundedHealth;
  static const entertainment = HugeIcons.strokeRoundedPlaySquare;
  static const utilities = HugeIcons.strokeRoundedFlash;
  static const salary = HugeIcons.strokeRoundedMoney01;
  static const investment = HugeIcons.strokeRoundedChartBreakoutSquare;
  static const freelance = HugeIcons.strokeRoundedComputer;
  static const gift = HugeIcons.strokeRoundedGift;
  static const travel = HugeIcons.strokeRoundedAirplane01;
  static const education = HugeIcons.strokeRoundedMortarboard01;
  static const emergency = HugeIcons.strokeRoundedAmbulance;
  static const bills = HugeIcons.strokeRoundedInvoice02;
  static const fuel = HugeIcons.strokeRoundedFuelStation;
  static const wifi = HugeIcons.strokeRoundedWifi01;
  static const tax = HugeIcons.strokeRoundedTaxes;

  // Settings & System
  static const calendar = HugeIcons.strokeRoundedCalendar01;
  static const image = HugeIcons.strokeRoundedImage01;
  static const check = HugeIcons.strokeRoundedCheckmarkCircle01;
  static const close = HugeIcons.strokeRoundedCancel01;
  static const delete = HugeIcons.strokeRoundedDelete01;
  static const edit = HugeIcons.strokeRoundedEdit01;
  static const copy = HugeIcons.strokeRoundedCopy01;
  static const share = HugeIcons.strokeRoundedShare01;
  static const refresh = HugeIcons.strokeRoundedRefresh;
  static const search = HugeIcons.strokeRoundedSearch01;
  static const filter = HugeIcons.strokeRoundedFilter;
  static const settings = HugeIcons.strokeRoundedSettings01;
  static const lock = HugeIcons.strokeRoundedLockKey;
  static const user = HugeIcons.strokeRoundedUser;
  static const users = HugeIcons.strokeRoundedUsers;
  static const mail = HugeIcons.strokeRoundedMail01;
  static const view = HugeIcons.strokeRoundedView;
  static const viewOff = HugeIcons.strokeRoundedViewOff;
  static const notification = HugeIcons.strokeRoundedNotification01;
  static const robot = HugeIcons.strokeRoundedRobot01;
  static const chartBar = HugeIcons.strokeRoundedChartBarBig;
  static const star = HugeIcons.strokeRoundedStar;
  static const starOff = HugeIcons.strokeRoundedStarOff;
  static const support = HugeIcons.strokeRoundedCustomerSupport;
  static const logout = HugeIcons.strokeRoundedLogout01;
  static const info = HugeIcons.strokeRoundedAlertCircle;
  static const warning = HugeIcons.strokeRoundedAlert01;
  static const bulb = HugeIcons.strokeRoundedBulb;
  static const download = HugeIcons.strokeRoundedDownload01;
  static const upload = HugeIcons.strokeRoundedUpload01;
  static const lockCheck = HugeIcons.strokeRoundedLock;
  static const security = HugeIcons.strokeRoundedSecurityCheck;
  static const help = HugeIcons.strokeRoundedHelpCircle;
  static const question = HugeIcons.strokeRoundedHelpSquare;
  static const heart = HugeIcons.strokeRoundedHeartCheck;
  static const fallback = HugeIcons.strokeRoundedCircle;

  /// Map category name or emoji to a HugeIcon icon.
  static List<List<dynamic>> forCategory(String nameOrEmoji) {
    final s = nameOrEmoji.toLowerCase().trim();

    // Direct emoji or symbol translations
    if (s.contains('🍔') || s.contains('🍕') || s.contains('☕') || s.contains('🍽') || s.contains('🍜')) {
      return food;
    }
    if (s.contains('🚗') || s.contains('🚌') || s.contains('⛽') || s.contains('🚕') || s.contains('🚲')) {
      return transport;
    }
    if (s.contains('🏠') || s.contains('🏢') || s.contains('🏡')) {
      return house;
    }
    if (s.contains('💡') || s.contains('⚡') || s.contains('🔌') || s.contains('💧')) {
      return utilities;
    }
    if (s.contains('🛍') || s.contains('🛒') || s.contains('👗') || s.contains('👟')) {
      return shoppingBag;
    }
    if (s.contains('🏥') || s.contains('💊') || s.contains('🩺') || s.contains('⚕')) {
      return health;
    }
    if (s.contains('🍿') || s.contains('🎮') || s.contains('🎬') || s.contains('🎵')) {
      return entertainment;
    }
    if (s.contains('💼') || s.contains('💰') || s.contains('💵') || s.contains('💸')) {
      return salary;
    }
    if (s.contains('📈') || s.contains('📊') || s.contains('🚀')) {
      return investment;
    }
    if (s.contains('🎯') || s.contains('🛡') || s.contains('🔒') || s.contains('🏦')) {
      return piggyBank;
    }
    if (s.contains('✈') || s.contains('🌴') || s.contains('🏖') || s.contains('🗺')) {
      return travel;
    }
    if (s.contains('🎓') || s.contains('📚') || s.contains('✏')) {
      return education;
    }
    if (s.contains('🎁') || s.contains('🎉')) {
      return gift;
    }
    if (s.contains('🚨') || s.contains('🚑')) {
      return emergency;
    }

    // Text category matching
    if (s.contains('food') || s.contains('dining') || s.contains('grocery') || s.contains('groceries') || s.contains('restaurant') || s.contains('meal') || s.contains('snack')) {
      return food;
    }
    if (s.contains('transport') || s.contains('car') || s.contains('fuel') || s.contains('gas') || s.contains('uber') || s.contains('taxi') || s.contains('bus') || s.contains('commute')) {
      return transport;
    }
    if (s.contains('house') || s.contains('housing') || s.contains('rent') || s.contains('home') || s.contains('mortgage')) {
      return house;
    }
    if (s.contains('util') || s.contains('bill') || s.contains('electricity') || s.contains('water') || s.contains('power') || s.contains('internet') || s.contains('wifi')) {
      return utilities;
    }
    if (s.contains('health') || s.contains('med') || s.contains('doctor') || s.contains('pharmacy') || s.contains('hospital') || s.contains('fitness') || s.contains('gym')) {
      return health;
    }
    if (s.contains('entertain') || s.contains('movie') || s.contains('netflix') || s.contains('game') || s.contains('music') || s.contains('fun') || s.contains('subscription')) {
      return entertainment;
    }
    if (s.contains('shop') || s.contains('cloth') || s.contains('store') || s.contains('purchase') || s.contains('electronics')) {
      return shoppingBag;
    }
    if (s.contains('salary') || s.contains('paycheck') || s.contains('wage') || s.contains('income')) {
      return salary;
    }
    if (s.contains('invest') || s.contains('stock') || s.contains('crypto') || s.contains('dividend') || s.contains('trading')) {
      return investment;
    }
    if (s.contains('save') || s.contains('saving') || s.contains('deposit') || s.contains('vault') || s.contains('goal')) {
      return piggyBank;
    }
    if (s.contains('freelance') || s.contains('consult') || s.contains('client') || s.contains('gig') || s.contains('project')) {
      return freelance;
    }
    if (s.contains('gift') || s.contains('bonus') || s.contains('reward') || s.contains('cashback') || s.contains('allowance')) {
      return gift;
    }
    if (s.contains('travel') || s.contains('flight') || s.contains('hotel') || s.contains('vacation') || s.contains('trip') || s.contains('holiday')) {
      return travel;
    }
    if (s.contains('educat') || s.contains('course') || s.contains('tuition') || s.contains('school') || s.contains('book') || s.contains('learn')) {
      return education;
    }
    if (s.contains('emergenc') || s.contains('urgent') || s.contains('safety') || s.contains('fund')) {
      return emergency;
    }
    if (s.contains('debt') || s.contains('loan') || s.contains('credit') || s.contains('repay')) {
      return creditCard;
    }
    if (s.contains('bank') || s.contains('account') || s.contains('wire')) {
      return bank;
    }
    if (s.contains('split') || s.contains('group') || s.contains('friend')) {
      return users;
    }

    return wallet;
  }
}
