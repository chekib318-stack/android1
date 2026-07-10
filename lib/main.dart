import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/progress_provider.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ArabiaEduApp());
}

class ArabiaEduApp extends StatelessWidget {
  const ArabiaEduApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProgressProvider()..load(),
      child: MaterialApp(
        title: 'تعليم اللغة العربية لأبناء الجالية التونسية بالخارج - القسم التحضيري',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // دعم الاتجاه من اليمين إلى اليسار، بانتظار إضافة حزمة intl
        // الكاملة لدعم تعدد لغات الواجهة في مرحلة لاحقة
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en'), Locale('fr')],
        localizationsDelegates: [
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        builder: (context, child) => Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
