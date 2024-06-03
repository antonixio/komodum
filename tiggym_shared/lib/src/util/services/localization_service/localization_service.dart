import 'package:flutter_localization/flutter_localization.dart';

import '../../../data/localization/app_locale.dart';

class LocalizationService {
  static FlutterLocalization get localizationInstance => FlutterLocalization.instance;

  static Future<void> initialize(String languageCode) async {
    await localizationInstance.init(
      mapLocales: AppLocale.map.entries.map((e) => MapLocale(e.key.languageCode, e.value.texts)).toList(),
      initLanguageCode: languageCode,
    );
  }
}
