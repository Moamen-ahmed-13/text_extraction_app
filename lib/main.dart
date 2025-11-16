import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sqflite/sqflite.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:text_extraction_app/core/theme/app_theme.dart';
import 'package:text_extraction_app/logic/cubits/auth/auth_cubit.dart';
import 'package:text_extraction_app/logic/cubits/auth/auth_state.dart';
import 'package:text_extraction_app/logic/cubits/history/history_cubit.dart';
import 'package:text_extraction_app/logic/cubits/profile/profile_cubit.dart';
import 'package:text_extraction_app/logic/cubits/text_extraction/text_extraction_cubit.dart';
import 'core/di/injection.dart';
import 'core/constants/app_constants.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'text_extractor.db');
  await deleteDatabase(path);
  print('✅ Old database deleted');
  try {
    print('🔥 Initializing Firebase...');
    await Firebase.initializeApp();
    print('✅ Firebase initialized successfully!');

    print('📦 Initializing Supabase...');
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
    print('✅ Supabase initialized successfully!');

    print('💉 Setting up Dependency Injection...');
    await configureDependencies();
    print('✅ Dependency Injection setup complete!');

    runApp(const MyApp());
  } catch (e) {
    print('❌ Error during initialization: $e');
    runApp(
      MaterialApp(
        home: Scaffold(body: Center(child: Text('Initialization Error: $e'))),
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
