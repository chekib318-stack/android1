import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// خدمة تشغيل الصوت. تعتمد إستراتيجية بأولويتين:
///   1) ملف صوتي حقيقي موحّد (نفس الملف على كل الهواتف) من assets/audio/،
///      إن وُجد للتمرين المطلوب — هذا يحل مشكلة اختلاف صوت TTS بين الأجهزة.
///   2) وإلا: صوت الهاتف الافتراضي (TTS، عربية فصحى) كبديل احتياطي فوري،
///      حتى يبقى التطبيق يشتغل بصوت من اليوم الأول قبل توفر التسجيلات.
///
/// لإضافة الأصوات الموحدة: ضع ملفات MP3 مسمّاة بمعرّف التمرين
/// (مثال: assets/audio/ex_001.mp3) — التطبيق يكتشفها تلقائيا بلا أي
/// تعديل إضافي على الكود. راجع assets/audio/README.md للتفاصيل.
///
/// ملاحظة أداء مهمة: التحقق من وجود ملف يتم مرة واحدة فقط عند بدء
/// التطبيق (عبر فهرس الأصول AssetManifest.json)، وليس بمحاولة تحميل
/// الملف في كل استدعاء — هذا يفادي أي بطء ملحوظ في القراءة، خاصة عندما
/// لا توجد بعد ملفات صوتية حقيقية (الحالة الافتراضية حاليا).
class AudioService {
  AudioService._internal() {
    _init();
  }

  static final AudioService instance = AudioService._internal();
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _player = AudioPlayer();
  bool _ready = false;
  Set<String> _availableAssets = {};

  static const double _defaultPitch = 1.0;
  static const double _defaultRate = 0.42;
  static const _keyVoiceName = 'tts_voice_name';
  static const _keyVoiceLocale = 'tts_voice_locale';

  Future<void> _init() async {
    await _tts.setLanguage('ar'); // عربية فصحى فقط، بدون أي محاولة للهجات محلية
    await _tts.setSpeechRate(_defaultRate); // أبطأ قليلا لملاءمة المتعلمين الصغار
    await _tts.setPitch(_defaultPitch);
    await _tts.awaitSpeakCompletion(true); // ينتظر speak() حتى ينتهي النطق فعليا
    await _loadAssetManifest();
    await _applySavedVoiceIfAny();
    _ready = true;
  }

  /// يحمّل فهرس كل ملفات الأصول مرة واحدة فقط عند بدء التطبيق، ليصير
  /// التحقق من وجود ملف صوتي معين عملية فورية (بحث في Set) بدل عملية
  /// تحميل فعلية مكلفة في كل مرة.
  Future<void> _loadAssetManifest() async {
    try {
      final manifestStr = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifest = json.decode(manifestStr);
      _availableAssets = manifest.keys.toSet();
    } catch (_) {
      _availableAssets = {};
    }
  }

  Future<void> _applySavedVoiceIfAny() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(_keyVoiceName);
      final locale = prefs.getString(_keyVoiceLocale);
      if (name != null && locale != null) {
        await _tts.setVoice({'name': name, 'locale': locale});
      }
    } catch (_) {
      // إن فشل تطبيق الصوت المحفوظ (مثلا الصوت لم يعد متوفرا)، نكمل بالصوت الافتراضي
    }
  }

  bool _assetExists(String assetPath) => _availableAssets.contains(assetPath);

  /// يشغّل تأثيرا صوتيا حقيقيا (نباح، صهيل، بوق سيارة...) إن وُجد ملفه في
  /// assets/sounds/، بلا أي خطأ أو تأخير إذا لم يوجد بعد (تجاهل صامت).
  Future<void> playSoundEffect(String? effectName) async {
    if (effectName == null || effectName.isEmpty) return;
    if (!_ready) await _init();
    final assetPath = 'assets/sounds/$effectName.mp3';
    if (!_assetExists(assetPath)) return;
    try {
      await _player.play(AssetSource('sounds/$effectName.mp3'));
    } catch (_) {
      // تجاهل صامت إن فشل التشغيل
    }
  }

  /// النقطة الموحّدة لنطق تمرين محدد: تجرب أولا الملف الصوتي الحقيقي
  /// المطابق لمعرّف التمرين، وإن لم يوجد ترجع تلقائيا لـTTS العادي.
  Future<void> speakForExercise(String exerciseId, String fallbackText) async {
    if (!_ready) await _init();
    final assetPath = 'assets/audio/$exerciseId.mp3';
    if (_assetExists(assetPath)) {
      try {
        await _player.stop();
        await _player.play(AssetSource('audio/$exerciseId.mp3'));
        return;
      } catch (_) {
        // فشل التشغيل رغم وجود الملف (تلف مثلا) → نكمل للبديل الاحتياطي أدناه
      }
    }
    await speak(fallbackText);
  }

  /// ينطق نصا عربيا عبر TTS مباشرة (بدون البحث عن ملف صوتي). آمن الاستدعاء
  /// حتى قبل اكتمال التهيئة (سينتظر تلقائيا).
  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    if (!_ready) await _init();
    await _tts.stop();
    await _tts.speak(text);
  }

  /// يرجع قائمة كل الأصوات العربية المتوفرة فعليا على جهاز المستخدم
  /// (تختلف من هاتف لآخر حسب محرك TTS المثبت). كل عنصر فيه 'name' و 'locale'.
  Future<List<Map<String, String>>> getArabicVoices() async {
    try {
      final voices = await _tts.getVoices;
      final result = <Map<String, String>>[];
      if (voices is List) {
        for (final v in voices) {
          if (v is Map) {
            final locale = (v['locale'] ?? '').toString();
            final name = (v['name'] ?? '').toString();
            if (locale.toLowerCase().startsWith('ar') && name.isNotEmpty) {
              result.add({'name': name, 'locale': locale});
            }
          }
        }
      }
      return result;
    } catch (_) {
      return [];
    }
  }

  /// يطبّق صوتا محددا ويحفظ الاختيار ليُستعمل تلقائيا في المرات القادمة.
  /// ملاحظة: هذا يبقى خاصا بجهاز واحد؛ للصوت الموحّد عبر كل الهواتف
  /// استعمل ملفات assets/audio/ بدل هذا الخيار.
  Future<void> setPreferredVoice(Map<String, String> voice) async {
    try {
      await _tts.setVoice({'name': voice['name']!, 'locale': voice['locale']!});
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyVoiceName, voice['name']!);
      await prefs.setString(_keyVoiceLocale, voice['locale']!);
    } catch (_) {
      // نتجاهل بصمت إن فشل التطبيق (صوت غير مدعوم مثلا)
    }
  }

  /// تعليق تحفيزي عند الإجابة الصحيحة، بنبرة مرحة أعلى قليلا من المعتاد.
  /// [phrase] الجملة المراد نطقها (تُختار عشوائيا من عدة جمل في الواجهة).
  Future<void> speakCorrect(String phrase) async {
    if (!_ready) await _init();
    await _tts.stop();
    await _tts.setPitch(1.15);
    await _tts.speak(phrase);
    await _tts.setPitch(_defaultPitch);
  }

  /// تعليق عند الإجابة الخاطئة، بنبرة أهدأ وأبطأ قليلا (نغمة حزينة لطيفة)
  /// دون أن تكون محبطة للمتعلم الصغير.
  Future<void> speakWrong() async {
    if (!_ready) await _init();
    final assetPath = 'assets/audio/wrong.mp3';
    if (_assetExists(assetPath)) {
      try {
        await _player.stop();
        await _player.play(AssetSource('audio/wrong.mp3'));
        return;
      } catch (_) {}
    }
    await _tts.stop();
    await _tts.setPitch(0.82);
    await _tts.setSpeechRate(0.36);
    await _tts.speak('خطأ، حاول مرة أخرى');
    await _tts.setPitch(_defaultPitch);
    await _tts.setSpeechRate(_defaultRate);
  }

  Future<void> stop() async {
    await _tts.stop();
    await _player.stop();
  }
}
