extension DateStringExtension on String {
  String toDateFormatted() {
    var day = DateTime.parse(this).day;

    var month = DateTime.parse(this).month;
    var year = DateTime.parse(this).year;
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/${year}';
  }
}

// extension DateStringExtension on String {
//   /// Converts an ISO date string to a formatted date string in GMT+3 timezone.
//   String formatToDate() {
//     try {
//       final context = navigatorKey.currentContext;
//       String localeCode = "en"; // Safe default

//       if (context != null) {
//         localeCode = LocalizationHelper.getCurrentLocale(context).languageCode;
//       }

//       // Parse the original date string
//       DateTime parsedDate = DateTime.parse(this);

//       // Convert to UTC and then add 3 hours for GMT+3
//       DateTime gmtPlus3Date = parsedDate.toUtc().add(Duration(hours: 3));

//       // Format the date
//       String formattedDate = DateFormat(
//         "d-M-y / h:mm a",
//         localeCode,
//       ).format(gmtPlus3Date);
//       return formattedDate;
//     } catch (e) {
//       // Handle parsing errors or invalid strings
//       return 'Invalid date string';
//     }
//     //   try {
//     //   DateTime parsedDate = DateTime.parse(this);
//     //   return DateFormat("MMMM d, yyyy 'at' h:mm a").format(parsedDate);
//     // } catch (e) {
//     //   return this; // Return original string if parsing fails
//     // }
//   }

//   String formatToDateMonth() {
//     try {
//       // 1. Get the current language code safely ("ar", "en", etc.)
//       final context = navigatorKey.currentContext;
//       String localeCode = "en"; // Safe default

//       if (context != null) {
//         localeCode = LocalizationHelper.getCurrentLocale(context).languageCode;
//       }

//       // 2. Parse the original date string
//       DateTime parsedDate = DateTime.parse(this);

//       // 3. Convert to UTC and then add 3 hours for GMT+3
//       DateTime gmtPlus3Date = parsedDate.toUtc().add(const Duration(hours: 3));

//       // 4. FIXED: Pass the localeCode directly into DateFormat
//       // For Arabic, this will automatically use Arabic month names and numerals!
//       String formattedDate = DateFormat(
//         "d, MMM, y",
//         localeCode,
//       ).format(gmtPlus3Date);

//       return formattedDate;
//     } catch (e) {
//       // Handle parsing errors or invalid strings
//       return 'Invalid date string';
//     }
//   }

//   String formatToDateMonthNumber() {
//     try {
//       // 1. Get the current language code safely ("ar", "en", etc.)
//       final context = navigatorKey.currentContext;
//       String localeCode = "en"; // Safe default

//       if (context != null) {
//         localeCode = LocalizationHelper.getCurrentLocale(context).languageCode;
//       }

//       // 2. Parse the original date string
//       DateTime parsedDate = DateTime.parse(this);

//       // 3. Convert to UTC and then add 3 hours for GMT+3
//       DateTime gmtPlus3Date = parsedDate.toUtc().add(const Duration(hours: 3));

//       // 4. FIXED: Pass the localeCode directly into DateFormat
//       // For Arabic, this will automatically use Arabic month names and numerals!
//       String formattedDate = DateFormat(
//         "d-M-y",
//         localeCode,
//       ).format(gmtPlus3Date);

//       return formattedDate;
//     } catch (e) {
//       // Handle parsing errors or invalid strings
//       return 'Invalid date string';
//     }
//   }

//   String formatToTime() {
//     bool isArabic =
//         LocalizationHelper.getCurrentLocale(
//           navigatorKey.currentContext!,
//         ).languageCode ==
//         "ar";
//     try {
//       // Parse the original date string
//       DateTime parsedDate = DateTime.parse(this);

//       // Convert to UTC and then add 3 hours for GMT+3
//       DateTime gmtPlus3Date = parsedDate.toUtc().add(Duration(hours: 3));

//       // Format the date (12-hour system)
//       String formattedDate = DateFormat('hh:mm a').format(gmtPlus3Date);

//       if (isArabic) {
//         // Replace AM/PM with Arabic equivalents
//         formattedDate = formattedDate
//             .replaceAll('AM', 'ص')
//             .replaceAll('PM', 'م');
//       }

//       return formattedDate;
//     } catch (e) {
//       // Handle parsing errors or invalid strings
//       return 'Invalid date string';
//     }
//   }
// }

// extension DateFormatter on String {
//   String formatToFullDateTime() {
//     // 1. Determine Locale
//     final String languageCode = LocalizationHelper.getCurrentLocale(
//       navigatorKey.currentContext!,
//     ).languageCode;

//     bool isArabic = languageCode == "ar";

//     try {
//       // 2. Parse and Adjust Timezone (GMT+3)
//       DateTime parsedDate = DateTime.parse(
//         this,
//       ).toUtc().add(const Duration(hours: 3));

//       // 3. Define the Format Pattern
//       // 'MMM' = Short Month, 'dd' = Day, 'hh:mm a' = 12h Time
//       // Arabic pattern usually puts the day before the month
//       String pattern = isArabic ? 'dd MMM، hh:mm a' : 'MMM dd, hh:mm a';

//       // 4. Format using the Intl package with the correct locale
//       String formatted = DateFormat(pattern, languageCode).format(parsedDate);

//       // 5. Manual fix for Arabic AM/PM if the system locale doesn't map them to ص/م automatically
//       if (isArabic) {
//         formatted = formatted.replaceAll('AM', 'ص').replaceAll('PM', 'م');
//       }

//       return formatted;
//     } catch (e) {
//       return 'Invalid Date';
//     }
//   }
// }
