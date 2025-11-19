import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sqflite/sqflite.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:text_extraction_app/core/theme/app_theme.dart';
import 'package:text_extraction_app/core/utils/logger_service.dart';
import 'package:text_extraction_app/logic/cubits/auth/auth_cubit.dart';
import 'package:text_extraction_app/logic/cubits/auth/auth_state.dart';
import 'package:text_extraction_app/logic/cubits/history/history_cubit.dart';
import 'package:text_extraction_app/logic/cubits/profile/profile_cubit.dart';
import 'package:text_extraction_app/logic/cubits/text_extraction/text_extraction_cubit.dart';
import 'core/di/injection.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    try {
        await dotenv.load(fileName: ".env");
      } catch (e) {
        LoggerService.warning('⚠️Warning: .env file not found. Using default configuration.');
      }
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'text_extractor.db');
      await deleteDatabase(path);
      LoggerService.info('✅ Old database deleted successfully');
    } catch (e) {
      LoggerService.warning('⚠️  Database deletion skipped', e);
    }
    LoggerService.info('🔥 Initializing Firebase...');
    await Firebase.initializeApp();
    LoggerService.info('✅ Firebase initialized successfully!');

    LoggerService.info('📦 Initializing Supabase...');
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? " ",
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? " ",
    );
    LoggerService.info('✅ Supabase initialized successfully!');

    LoggerService.info('💉 Setting up Dependency Injection...');
    await configureDependencies();
    LoggerService.info('✅ Dependency Injection setup complete!');

    runApp(const MyApp());
  } catch (e, stackTrace) {
    LoggerService.error('❌ Error during initialization', e, stackTrace);
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Initialization Error',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    e.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthCubit>()..checkAuthStatus()),
        BlocProvider(create: (_) => getIt<ProfileCubit>()),
        BlocProvider(create: (_) => getIt<TextExtractionCubit>()),
        BlocProvider(create: (_) => getIt<HistoryCubit>()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthenState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is AuthAuthenticated) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}