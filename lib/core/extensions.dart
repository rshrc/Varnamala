// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// Project imports:
import 'package:words625/core/enums.dart';

// Project imports:

// Window size classes live in `core/responsive.dart`.

extension NullableStringExtensions<E> on String? {
  /// Returns `true` if this string is `null` or empty.
  bool get isNotOkay {
    return this?.isEmpty ?? true;
  }

  /// Returns `true` if this string is not `null` and not empty.
  bool get isOkay {
    return this?.isNotEmpty ?? false;
  }
}

/// To Check if request is success [HTTP]
extension HttpRequestStatus on http.Response {
  bool get ok => statusCode == 200 || statusCode == 204 || statusCode == 201;
}

extension ContextExtentions on BuildContext {
  double get height => MediaQuery.of(this).size.height;

  double get width => MediaQuery.of(this).size.width;

  // TODO: Need to be removed/replaced when AutoRoute is introduced
  Future<dynamic> push(
    Widget screen, {
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) async =>
      await Navigator.of(this).push(MaterialPageRoute(
        builder: (_) => screen,
        settings: settings,
        maintainState: maintainState,
        fullscreenDialog: fullscreenDialog,
      ));

  Future<dynamic> route(PageRouteInfo route) async {
    AutoRouter.of(this).push(route);
  }
}

extension TextThemeExtensions on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
}

extension ColorExtensions on BuildContext {
  Color get primaryColor => Theme.of(this).primaryColor;

  Color get secondaryHeaderColor => Theme.of(this).secondaryHeaderColor;

  Color get indicatorColor => Theme.of(this).indicatorColor;
}

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

extension RandomString on int {
  String get getRandomString => String.fromCharCodes(
        Iterable.generate(
            this, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))),
      );
}

extension DateTimeFormat on DateTime {
  String toYMD() {
    return "${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
  }

  String get toFTS => DateFormat('HH:mm:ss.SSS').format(this);

  String toAPIFormat() {
    return DateFormat('yyyy-MM-dd').format(this);
  }
}

extension StringExtension on String {
  String get toTitleCase {
    return split(RegExp('[_ ]'))
        .map((str) => str[0].toUpperCase() + str.substring(1).toLowerCase())
        .join(' ');
  }

  TimeOfDay get toTimeOfDay {
    // Split the string using the ':' delimiter
    final parts = split(':');

    // Parse the hours and minutes, ignoring seconds
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    // Return a TimeOfDay object
    return TimeOfDay(hour: hour, minute: minute);
  }

  String get imgUrl {
    final parts = split("?");

    return parts[0];
  }
}

extension DateTimeStringExtension on String {
  String get toHumanDateTime {
    try {
      DateTime dateTime = DateTime.parse(this);

      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      return "Invalid Date Time";
    }
  }

  String get toHumanDate {
    try {
      DateTime dateTime = DateTime.parse(this);

      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      return "Invalid Date";
    }
  }

  String get toDDMMYYYY {
    try {
      DateTime parsedDate = DateTime.parse(this);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return this;
    }
  }

  String? toYYYYMMDD() {
    try {
      DateTime parsedDate = DateTime.parse(this);

      return DateFormat('yyyy-MM-dd').format(parsedDate);
    } catch (e) {
      // Handle the error or return the original string
      return null;
    }
  }
}

/// Need to optimize this to use URI package to remove all query params
extension RemoveQueryParams on String {
  String removeSignature() {
    int indexOfQuestionMark = indexOf('?');
    if (indexOfQuestionMark == -1) {
      // If there is no question mark, return the original string
      return this;
    } else {
      // Return the substring before the question mark
      return substring(0, indexOfQuestionMark);
    }
  }
}

extension UrlPageExtractor on String? {
  int? get getPageNumber {
    // Check if the string is null
    if (this == null) {
      return null;
    }

    // Parsing the URL
    final Uri uri = Uri.parse(this!);

    // Getting the query parameters
    final Map<String, String> queryParams = uri.queryParameters;

    // Retrieving the 'page' parameter and converting it to an integer
    if (queryParams.containsKey('page')) {
      final String? pageValue = queryParams['page'];
      return int.tryParse(pageValue ?? '');
    }

    // Return null if 'page' parameter is not found
    return null;
  }
}

extension DateTimeExtension on DateTime {
  String humanizeEstimatedTime() {
    // Check if the hour is not zero
    if (hour != 0) {
      // Use DateFormat to format the time to "HH hours and mm minutes"
      return "$hour hours and $minute minutes";
    } else {
      // If hour is zero, just return the minutes
      return "$minute mins";
    }
  }

  String get toHumanDateTime {
    return DateFormat('dd MMM yyyy').format(this);
  }

  String toFormattedTime() {
    return DateFormat('hh:mm a').format(this);
  }
}

extension TimeOfDayExtension on TimeOfDay {
  String? formatToHHMMSS() {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, hour, minute);
    final format = DateFormat('HH:mm:ss');
    return format.format(dt);
  }
}

extension EnumType on String {
  TargetLanguage getEnumValue() {
    return TargetLanguage.values.firstWhere(
      (element) => element.name == this,
      orElse: () => TargetLanguage.kannada,
    );
  }
}
