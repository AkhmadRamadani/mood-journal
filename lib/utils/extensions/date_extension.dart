import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Ekstensi untuk format tanggal
/// Docs: https://api.flutter.dev/flutter/intl/DateFormat-class.html
extension DateExtension on DateTime {
  static final String local = 'locale'.tr;

  DateTime copyWith({
    int? tahun,
    int? bulan,
    int? hari,
    int? jam,
    int? menit,
    int? detik,
  }) {
    tahun ??= year;
    bulan ??= month;
    hari ??= day;
    jam ??= hour;
    menit ??= minute;
    detik ??= second;

    return DateTime(tahun, bulan, hari, jam, menit, detik);
  }

  /// Ke dalam format tanggal
  String toDateString() => DateFormat(
        'y-M-d',
      ).format(this);

  /// Ke dalam format tanggal
  String toDMYTipe() => DateFormat(
        'd-M-y',
      ).format(this);

  String toDateStringLong() => DateFormat(
        'yyyy-MM-dd',
      ).format(this);

  String toDateStringLongNoDay() => DateFormat(
        'yyyy-MM',
      ).format(this);

  /// Ke dalam format tanggal waktu
  String toDateTimeString() => DateFormat(
        'y-M-d HH:mm:ss',
      ).format(this);

  /// Ke dalam format waktu
  String toTimeString() => DateFormat(
        'HH:mm',
      ).format(this);

  /// Ke dalam format waktu
  String toTimeAString() => DateFormat(
        'HH:mm a',
      ).format(this);

  /// Ke dalam format tanggal baca
  String toHumanDate() => DateFormat(
        'EEEE, d MMMM y',
      ).format(this);

  /// Ke dalam format tanggal baca pendek
  String toHumanDateShort() => DateFormat(
        'E, d MMM y',
      ).format(this);

  /// Ke dalam format tanggal baca waktu
  String toHumanDateTime() {
    try {
      return DateFormat(
        'EEEE, d MMMM y HH:mm',
      ).format(this);
    } catch (e) {
      return '';
    }
  }

  String toHumanDateTimeWithoutHour() {
    try {
      return DateFormat(
        'EEEE, d MMMM y',
      ).format(this);
    } catch (e) {
      return '';
    }
  }

  /// Ke dalam format tanggal baca waktu pendek
  String toHumanDateTimeShort() => DateFormat(
        'E, d MMM y HH:mm',
      ).format(this);

  /// Ke dalam format tanggal baca waktu pendek
  String toHumanMonthDate() {
    try {
      return DateFormat(
        'dd MMM yyy',
      ).format(this);
    } catch (e) {
      return '';
    }
  }

  String toHumanShortMonthDate() => DateFormat(
        'd MMM yyy',
      ).format(this);

  String toHumanShortMonthWithDay() => DateFormat(
        'EE, d MMM yyy',
      ).format(this);

  String toHumanShortDay() => DateFormat(
        'EE',
      ).format(this);

  String toHumanMonthShortNoYearDate() => DateFormat(
        'd MMM',
      ).format(this);

  /// Ke dalam format tahun bulan baca waktu pendek
  String toHumanBulanDate() => DateFormat(
        'MMMM yyy',
      ).format(this);

  String toHumanBulanShortDate() => DateFormat(
        'MMM yyy',
      ).format(this);

  /// Ke dalam format tahun bulan baca waktu pendek
  String toHumanDay() => DateFormat(
        'd',
      ).format(this);

  /// Ke dalam format tahun bulan baca waktu pendek
  String toHumanBulan() => DateFormat(
        'MMMM',
      ).format(this);

  /// Ke dalam format time baca waktu pendek
  String toHumanTime() => DateFormat(
        'HH:mm',
      ).format(this);

  /// Ke dalam format tanggal baca waktu pendek
  String toHumanDateTimeShortWithoutYear() => DateFormat(
        'E, d MMM HH:mm',
      ).format(this);

  String toTimeInCheckClock() {
    try {
      return DateFormat(
        'HH:mm:ss',
      ).format(this);
    } catch (e) {
      return '--:--:--';
    }
  }
}
