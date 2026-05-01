import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return AppLocalizations(Localizations.localeOf(context));
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'home': 'Home',
      'practice': 'Practice',
      'past_papers': 'Past Papers',
      'profile': 'Profile',
      'hello_student': 'Hello, Student!',
      'ready_to_practice': 'Ready to practice today?',
      'start_mcq': 'Start MCQ Practice',
      'ai_tutor': 'AI Tutor',
      'recent_progress': 'Recent Progress',
      'tests': 'Tests',
      'correct': 'Correct',
      'streak': 'Streak',
      'days': 'days',
      'logout': 'Logout',
      'language': 'Language',
      'continue_learning': 'Continue Learning',
      'resume': 'Resume',
      'select_subject': 'Select a subject to begin',
    },
    'ur': {
      'home': 'ہوم',
      'practice': 'مشق',
      'past_papers': 'سابقہ پرچہ جات',
      'profile': 'پروفائل',
      'hello_student': 'ہیلو، طالب علم!',
      'ready_to_practice': 'کیا آپ آج مشق کے لیے تیار ہیں؟',
      'start_mcq': 'MCQ مشق شروع کریں',
      'ai_tutor': 'AI ٹیوٹر',
      'recent_progress': 'حالیہ پیشرفت',
      'tests': 'ٹیسٹ',
      'correct': 'درست',
      'streak': 'سلسلہ',
      'days': 'دن',
      'logout': 'لاگ آؤٹ',
      'language': 'زبان',
      'continue_learning': 'سیکھنا جاری رکھیں',
      'resume': 'دوبارہ شروع کریں',
      'select_subject': 'شروع کرنے کے لیے ایک مضمون منتخب کریں',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

extension LocalizationExtension on BuildContext {
  String l10n(String key) => AppLocalizations.of(this).translate(key);
}
