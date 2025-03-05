import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poopapp/core/utils/database_helper.dart';
import 'package:poopapp/features/poop_tracking/data/datasources/child_local_datasource.dart';
import 'package:poopapp/features/poop_tracking/data/datasources/poop_local_datasource.dart';
import 'package:poopapp/features/poop_tracking/data/repositories/child_repository_impl.dart';
import 'package:poopapp/features/poop_tracking/data/repositories/poop_repository_impl.dart';
import 'package:poopapp/features/poop_tracking/domain/repositories/child_repository.dart';
import 'package:poopapp/features/poop_tracking/domain/repositories/poop_repository.dart';
import 'package:poopapp/features/poop_tracking/domain/usecases/child_usecases.dart';
import 'package:poopapp/features/poop_tracking/domain/usecases/poop_usecases.dart';
import 'package:poopapp/features/poop_tracking/presentation/bloc/child_bloc.dart';
import 'package:poopapp/features/poop_tracking/presentation/bloc/poop_bloc.dart';

final GetIt locator = GetIt.instance;

Future<void> initDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  locator.registerSingleton<SharedPreferences>(sharedPreferences);
  
  // Database
  locator.registerSingleton<DatabaseHelper>(DatabaseHelper());
  
  // Data sources
  locator.registerSingleton<ChildLocalDataSource>(
    ChildLocalDataSourceImpl(
      databaseHelper: locator(),
      sharedPreferences: locator(),
    ),
  );
  
  locator.registerSingleton<PoopLocalDataSource>(
    PoopLocalDataSourceImpl(
      databaseHelper: locator(),
    ),
  );
  
  // Repositories
  locator.registerSingleton<ChildRepository>(
    ChildRepositoryImpl(
      localDataSource: locator(),
    ),
  );
  
  locator.registerSingleton<PoopRepository>(
    PoopRepositoryImpl(
      localDataSource: locator(),
    ),
  );
  
  // Use cases - Child
  locator.registerFactory(() => GetAllChildrenUseCase(locator()));
  locator.registerFactory(() => GetChildByIdUseCase(locator()));
  locator.registerFactory(() => AddChildUseCase(locator()));
  locator.registerFactory(() => UpdateChildUseCase(locator()));
  locator.registerFactory(() => DeleteChildUseCase(locator()));
  locator.registerFactory(() => GetCurrentChildUseCase(locator()));
  locator.registerFactory(() => SetCurrentChildUseCase(locator()));
  
  // Use cases - Poop
  locator.registerFactory(() => GetAllPoopEntriesUseCase(locator()));
  locator.registerFactory(() => GetPoopEntriesByDateRangeUseCase(locator()));
  locator.registerFactory(() => GetPoopEntryByIdUseCase(locator()));
  locator.registerFactory(() => AddPoopEntryUseCase(locator()));
  locator.registerFactory(() => UpdatePoopEntryUseCase(locator()));
  locator.registerFactory(() => DeletePoopEntryUseCase(locator()));
  locator.registerFactory(() => GetPoopEntriesGroupedByDayUseCase(locator()));
  locator.registerFactory(() => GetPoopCountByDateRangeUseCase(locator()));
  
  // BLoCs
  locator.registerLazySingleton(() => ChildBloc(
    getAllChildren: locator(),
    getChildById: locator(),
    addChild: locator(),
    updateChild: locator(),
    deleteChild: locator(),
    getCurrentChild: locator(),
    setCurrentChild: locator(),
  ));
  
  locator.registerLazySingleton(() => PoopBloc(
    getAllPoopEntries: locator(),
    getPoopEntriesByDateRange: locator(),
    getPoopEntryById: locator(),
    addPoopEntry: locator(),
    updatePoopEntry: locator(),
    deletePoopEntry: locator(),
    getPoopEntriesGroupedByDay: locator(),
    getPoopCountByDateRange: locator(),
  ));
} 