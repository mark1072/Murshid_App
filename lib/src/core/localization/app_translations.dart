import 'package:get/get.dart';
import 'package:musrshid_app/src/core/localization/ar_EG.dart';
import 'package:musrshid_app/src/core/localization/en_US.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'ar_EG': arEG,
        'en_US': enUS,
      };
}
