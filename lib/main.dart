import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
import 'package:poopapp/core/constants/app_constants.dart';
import 'package:poopapp/core/di/dependency_injection.dart';
import 'package:poopapp/core/theme/app_theme.dart';
import 'package:poopapp/features/poop_tracking/presentation/bloc/child_bloc.dart';
import 'package:poopapp/features/poop_tracking/presentation/bloc/poop_bloc.dart';
import 'package:poopapp/features/poop_tracking/presentation/screens/home_screen.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database
  final databasePath = await getDatabasesPath();
  final path = join(databasePath, 'poop_app.db');
  
  // Delete the database for development if needed
  // await deleteDatabase(path);

  // Open the database
  final database = await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      // Create child table
      await db.execute(
        '''
        CREATE TABLE IF NOT EXISTS children (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          birth_date INTEGER,
          avatar_path TEXT,
          gender INTEGER NOT NULL DEFAULT 0,
          is_selected INTEGER NOT NULL DEFAULT 0
        )
        ''',
      );

      // Create poop entries table
      await db.execute(
        '''
        CREATE TABLE IF NOT EXISTS poop_entries (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          child_id INTEGER NOT NULL,
          date_time INTEGER NOT NULL,
          consistency INTEGER NOT NULL,
          color INTEGER NOT NULL,
          has_blood INTEGER NOT NULL DEFAULT 0,
          has_mucus INTEGER NOT NULL DEFAULT 0,
          feeling INTEGER,
          notes TEXT,
          FOREIGN KEY (child_id) REFERENCES children (id) ON DELETE CASCADE
        )
        ''',
      );
    },
  );

  // Initialize dependency injection
  await setupDependencies(database);

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ChildBloc>(
          create: (context) => getIt<ChildBloc>(),
        ),
        BlocProvider<PoopBloc>(
          create: (context) => getIt<PoopBloc>(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
      ),
    );
  }
}
