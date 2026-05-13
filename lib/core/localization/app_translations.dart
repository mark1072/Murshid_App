import 'package:get/get.dart';
import 'ar_EG.dart';
import 'en_US.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'ar_EG': arEG,
        'en_US': enUS,
      };
}
