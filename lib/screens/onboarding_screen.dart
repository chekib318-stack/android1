import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  String? _ageGroup;
  String? _motherTongue;

  static const _ageGroups = [
    ('4-7', 'الأطفال الصغار'),
    ('8-12', 'الأطفال'),
    ('13-17', 'اليافعون'),
    ('18+', 'الكبار'),
  ];

  static const _tongues = ['العربية', 'الفرنسية', 'الإنجليزية', 'أخرى'];

  void _next() {
    if (_step == 0) {
      if (_ageGroup == null) return;
      setState(() => _step++);
      return;
    }
    if (_step == 1) {
      if (_motherTongue == null) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Text(
                'مرحبًا بك في',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                'تعليم العربية — تحضيري 🌙',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppColors.sidiBlue,
                    ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: _step == 0 ? _ageStep() : _tongueStep(),
              ),
              ElevatedButton(
                onPressed:
                    (_step == 0 ? _ageGroup : _motherTongue) == null ? null : _next,
                child: Text(_step == 0 ? 'التالي' : 'ابدأ التعلم'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ageStep() {
    return Column(
      children: [
        Text('ما هي فئتك العمرية؟', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.separated(
            itemCount: _ageGroups.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final (value, label) = _ageGroups[i];
              final selected = _ageGroup == value;
              return _choiceCard(label, selected, () => setState(() => _ageGroup = value));
            },
          ),
        ),
      ],
    );
  }

  Widget _tongueStep() {
    return Column(
      children: [
        Text('ما هي لغتك الأم؟', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.separated(
            itemCount: _tongues.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final label = _tongues[i];
              final selected = _motherTongue == label;
              return _choiceCard(label, selected, () => setState(() => _motherTongue = label));
            },
          ),
        ),
      ],
    );
  }

  Widget _choiceCard(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: selected ? AppColors.sidiBlue.withOpacity(0.1) : AppColors.jasmineDim,
          border: Border.all(
            color: selected ? AppColors.sidiBlue : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }
}
