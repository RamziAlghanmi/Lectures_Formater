import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lecture_formater/core/constants/app_theme.dart';
import 'package:lecture_formater/shared/widgets/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/datasources/document_local_datasource.dart';
import 'data/repositories/document_repository_impl.dart';
import 'presentation/providers/document_provider.dart';
import 'presentation/providers/editor_provider.dart';
import 'presentation/screens/editor_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  final localDataSource = DocumentLocalDataSourceImpl(prefs: prefs);

  final documentRepository = DocumentRepositoryImpl(
    localDataSource: localDataSource,
  );

  runApp(LectureStudioApp(documentRepository: documentRepository));
}

class LectureStudioApp extends StatelessWidget {
  final DocumentRepositoryImpl documentRepository;

  const LectureStudioApp({super.key, required this.documentRepository});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final provider = DocumentProvider(repository: documentRepository);
            // تهيئة المستند مرة واحدة عند إنشاء Provider
            provider.initializeDefaultOrCached();
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) => EditorProvider()),
      ],
      child: MaterialApp(
        title: 'Lecture PDF Studio',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(),
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) {
          return LoadingOverlay(child: child!);
        },
        home: EditorScreen(),
      ),
    );
  }
}
