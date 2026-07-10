import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';

/// تعرض كل الأصوات العربية المتوفرة فعليا على جهاز المستخدم (تختلف من
/// هاتف لآخر)، وتسمح بتجربة كل صوت واختيار المفضّل. الاختيار يُحفظ
/// ويُطبّق تلقائيا في كل مرات القراءة القادمة.
class VoiceSettingsScreen extends StatefulWidget {
  const VoiceSettingsScreen({super.key});

  @override
  State<VoiceSettingsScreen> createState() => _VoiceSettingsScreenState();
}

class _VoiceSettingsScreenState extends State<VoiceSettingsScreen> {
  List<Map<String, String>> _voices = [];
  bool _loading = true;
  String? _selectedVoiceName;

  @override
  void initState() {
    super.initState();
    _loadVoices();
  }

  Future<void> _loadVoices() async {
    final voices = await AudioService.instance.getArabicVoices();
    if (!mounted) return;
    setState(() {
      _voices = voices;
      _loading = false;
    });
  }

  Future<void> _tryVoice(Map<String, String> voice) async {
    await AudioService.instance.setPreferredVoice(voice);
    setState(() => _selectedVoiceName = voice['name']);
    await AudioService.instance.speak('مرحبا، هذا مثال على هذا الصوت');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اختيار صوت القراءة')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _voices.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _voices.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final voice = _voices[i];
                      final selected = _selectedVoiceName == voice['name'];
                      return _voiceCard(voice, selected);
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.record_voice_over_outlined, size: 56, color: AppColors.inkFaint),
            const SizedBox(height: 16),
            Text(
              'لم يتم العثور على أصوات عربية إضافية على هذا الجهاز. سيستمر التطبيق باستعمال الصوت الافتراضي.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _voiceCard(Map<String, String> voice, bool selected) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: selected ? AppColors.sidiBlue.withOpacity(0.1) : AppColors.jasmineDim,
        border: Border.all(
          color: selected ? AppColors.sidiBlue : Colors.transparent,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            selected ? Icons.check_circle : Icons.record_voice_over_outlined,
            color: selected ? AppColors.zellige : AppColors.sidiBlue,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  voice['name'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  voice['locale'] ?? '',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _tryVoice(voice),
            child: const Text('تجربة واختيار'),
          ),
        ],
      ),
    );
  }
}
