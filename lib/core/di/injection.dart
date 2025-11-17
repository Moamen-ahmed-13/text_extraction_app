import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:text_extraction_app/core/utils/connectivity_service.dart';
import 'package:text_extraction_app/core/utils/logger_service.dart';
import 'package:text_extraction_app/data/services/database_helper.dart';
import 'package:text_extraction_app/data/services/firebase_auth_service.dart';
import 'package:text_extraction_app/data/services/firebase_firestore_service.dart';
import 'package:text_extraction_app/data/services/storage_service.dart';
import 'package:text_extraction_app/logic/cubits/auth/auth_cubit.dart';
import 'package:text_extraction_app/logic/cubits/history/history_cubit.dart';
import 'package:text_extraction_app/logic/cubits/profile/profile_cubit.dart';
import 'package:text_extraction_app/logic/cubits/text_extraction/text_extraction_cubit.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  if (getIt.isRegistered<FirebaseAuth>()) {
    return;
  }

  
  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());

  getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  getIt.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());

  await getIt<DatabaseHelper>().initDatabase();

  getIt.registerLazySingleton<FirebaseFirestoreService>(
    () => FirebaseFirestoreService(getIt<FirebaseFirestore>()),
  );

  getIt.registerLazySingleton<StorageService>(
    () => StorageService(getIt<SupabaseClient>()),
  );
  getIt.registerLazySingleton<FirebaseAuthService>(
    () => FirebaseAuthService(getIt<FirebaseAuth>()),
  );

  getIt.registerLazySingleton<AuthCubit>(
    () => AuthCubit(
      getIt<FirebaseAuthService>(),
      getIt<FirebaseFirestoreService>(),
      getIt<DatabaseHelper>(),
    ),
  );

  getIt.registerLazySingleton<TextExtractionCubit>(
    () => TextExtractionCubit(
      getIt<DatabaseHelper>(),
      getIt<FirebaseFirestoreService>(),
      getIt<StorageService>(),
      getIt<ConnectivityService>(),
    ),
  );

  getIt.registerLazySingleton<ProfileCubit>(
    () => ProfileCubit(
      getIt<FirebaseFirestoreService>(),
      getIt<StorageService>(),
    ),
  );

  getIt.registerLazySingleton<HistoryCubit>(
    () => HistoryCubit(getIt<DatabaseHelper>()),
  );
  LoggerService.info('✅ All dependencies registered successfully!');
}
