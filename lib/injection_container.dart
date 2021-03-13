// We have all of the individual pieces of the app architecture in place. Before
// we can utilize them by building a UI though, we have to connect them
// together. Since every class is decoupled from its dependencies by accepting
// them through the constructor, we somehow have to pass them in.

// We've been doing this all along in tests with the mocked classes. Now,
// however, comes the time to pass in real production classes using a SERVICE
// LOCATOR.

import 'package:clean_architecture_tdd/core/network/network_info.dart';
import 'package:clean_architecture_tdd/core/util/input_converter.dart';
import 'package:clean_architecture_tdd/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:clean_architecture_tdd/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_architecture_tdd/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:clean_architecture_tdd/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:clean_architecture_tdd/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_architecture_tdd/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:clean_architecture_tdd/features/number_trivia/presentation/bloc/bloc.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// The get_it package supports creating singletons and instance factories. Since
// we're not holding any state inside any of the classes, we're going to
// register everything as a ​singleton​, which means that only one instance of a
// class will be created per the app's lifetime. There will be only one
// exception to this rule - the NumberTriviaBloc which, following the "call
// flow", we're going to register first.

final sl = GetIt.instance;

// If your app has multiple features, you might want to create smaller
// injection_container files with 'init()' functions per every feature to keep
// things organized.
// You would then call these feature-specific init() functions from within the
// main one.

// The 'init()' function will be called immediately when the app starts from
// main.dart. It will be inside that function where all the classes and
// contracts will be registered and subseqently also injected using the
// singleton instace of 'GetIt' store inside 'sl'.

Future<void> init() async {
  //* Features - Number Trivia

  // Bloc
  sl.registerFactory(
    () => NumberTriviaBloc(
      concrete: sl.call(),
      random: sl(),
      inputConverter: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetConcreteNumberTrivia(sl()));
  sl.registerLazySingleton(() => GetRandomNumberTrivia(sl()));

  // Repository
  sl.registerLazySingleton<NumberTriviaRepository>(
    () => NumberTriviaRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<NumberTriviaRemoteDataSource>(
    () => NumberTriviaRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<NumberTriviaLocalDataSource>(
    () => NumberTriviaLocalDataSourceImpl(sharedPreferences: sl()),
  );

  //* Core
  sl.registerLazySingleton(() => InputConverter());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  //* External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => DataConnectionChecker());
}

// *REGISTERING A FACTORY:
// The registration process is very straightforward.  Just instantiate the class
// as usual and pass in sl() into every constructor parameter.
//
// Using type inference​, the call to sl() will determine which object it should
// pass as the given constructor argument. Of course, this is only possible when
// the type in question is also registered.
//
// Presentation logic holders (or classes requiring cleanup) such as Bloc
// shouldn't be registered as singletons. They are very close to the UI and if
// your app has multiple pages between which you navigate, you will probably
// gonna do some cleanup (like closing Streams of a Bloc) from the dispose()
// method of a StatefulWidget.
//
// Having a singleton for classes with this kind of a disposal would lead to
// trying to use a presentation logic holder (such as Bloc) with closed Streams,
// instead of creating a new instance with opened Streams whenever you'd try to
// get an object of that type from GetIt.

// *REGISTERING SINGLETONS:
// GetIt gives us two options when it comes to singletons. We can either
// 'registerSingleton' or 'registerLazySingleton'. The only difference between
// them is that a non-lazy singleton is always registered immediately after the
// app starts, while a lazy singleton is registered only when it's requested as
// a dependency for some other class.

// *REGISTERING A REPOSITORY:
// While InputConverter is a stand-alone class, both of the use cases require a
// NumberTriviaRepository. Notice that they depend on the ​contract​​ and not on
// the concrete implementation. However, we cannot instantiate a ​​​contract (which
// is an abstract class). Instead, we have to instantiate the implementation of
// the repository. This is possible by specifying a type parameter on the
// 'registerLazySingleton' method.
//
// This nicely demonstrates the usefulness of loose coupling. Depending on
// abstractions instead of implementations not only allows for testing (we were
// passing around ​mocks​ in tests all along!), but it also allows for painlessly
// swapping the NumberTriviaRepository's underlying implementation for a
// different one without any changes to the dependent classes.

// *REGISTERING EXTERNAL DEPENDENCIES:
// We've moved all the way down the call chain into the realm of 3rd party
// libraries. We need to register a http.Client, DataConnectionChecker and also
// SharedPreferences. The last one is a little tricky.
//
// Unlike all of the other classes, SharedPreferences cannot be simply
// instantiated with a regular constructor call. Instead, we have to call
// SharedPreferences.getInstance() which is an asynchronous method!
//
// We want to register a simple instance of SharedPreferences instead. For that,
// we need to await the call to getInstance() outside of the registration. This
// will require us to change the init() method signature to 'Future<void>'.
