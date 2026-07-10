import 'package:speech_to_text/speech_to_text.dart' as stt;

/// خدمة تحويل الكلام المنطوق إلى نص، تُستعمل لسؤال التلميذ عن اسمه
/// صوتيا (بدل الكتابة). تعتمد على محرك التعرف على الكلام في نظام
/// التشغيل، وتحتاج صلاحية الميكروفون (تُطلب تلقائيا عند أول استعمال).
class SpeechService {
  SpeechService._internal();
  static final SpeechService instance = SpeechService._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _initialized = false;
  bool _available = false;

  Future<bool> _ensureInitialized() async {
    if (_initialized) return _available;
    _available = await _speech.initialize(
      onError: (_) {},
      onStatus: (_) {},
    );
    _initialized = true;
    return _available;
  }

  bool get isListening => _speech.isListening;

  /// يبدأ الاستماع للميكروفون. ينادي [onResult] مع كل نتيجة جزئية أثناء
  /// الكلام، ومع النتيجة النهائية (isFinal=true) عند التوقف.
  /// يرجع false إذا كانت الصلاحية مرفوضة أو الميكروفون غير متاح.
  Future<bool> listen({
    required void Function(String recognizedText, bool isFinal) onResult,
  }) async {
    final ok = await _ensureInitialized();
    if (!ok) return false;
    await _speech.listen(
      // نجرب لهجة عربية عامة؛ إذا لم تكن مثبتة على الجهاز سيستعمل
      // النظام أقرب لغة متاحة تلقائيا.
      localeId: 'ar-SA',
      onResult: (result) {
        onResult(result.recognizedWords, result.finalResult);
      },
    );
    return true;
  }

  Future<void> stop() => _speech.stop();
}
