import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/onboarding_screen.dart';
import 'screens/root_screen.dart';
import 'screens/essay_screen.dart';
import 'screens/interview_screen.dart';
import 'services/essay_repository.dart';
import 'services/interview_repository.dart';
import 'services/ai_service.dart';
import 'services/history_repository.dart';
import 'blocs/history/history_cubit.dart';
import 'blocs/theme/theme_cubit.dart';
import 'blocs/grammar/grammar_bloc.dart';
// grammar bloc
import 'blocs/interview/interview_bloc.dart';
import 'blocs/interview/interview_event.dart';
// interview bloc

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final aiService = AIService();
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<EssayRepository>(
          create: (_) => EssayRepositoryImpl(aiService),
        ),
        RepositoryProvider<InterviewRepository>(
          create: (_) => InterviewRepositoryImpl(aiService),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<GrammarBloc>(
            create: (ctx) =>
                GrammarBloc(repository: ctx.read<EssayRepository>()),
          ),
          BlocProvider<InterviewBloc>(
            create: (ctx) =>
                InterviewBloc(repository: ctx.read<InterviewRepository>())
                  ..add(const InterviewStarted()),
          ),
          BlocProvider<HistoryCubit>(
            create: (_) => HistoryCubit(HistoryRepository()),
          ),
          BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'GradeFlow',
              themeMode: themeMode,
              theme: ThemeData(
                useMaterial3: true,
                colorSchemeSeed: Colors.blue,
                brightness: Brightness.light,
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                colorSchemeSeed: Colors.blue,
                brightness: Brightness.dark,
              ),
              routes: {
                '/onboarding': (_) => const OnboardingScreen(),
                '/root': (_) => const RootScreen(),
                '/essay': (_) => const EssayScreen(),
                '/interview': (_) => const InterviewScreen(),
              },
              home: FutureBuilder<bool>(
                future: HistoryRepository().getOnboarded(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final onboarded = snapshot.data ?? false;
                  return onboarded
                      ? const RootScreen()
                      : const OnboardingScreen();
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
