import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  // this is how Equatable works:
  Failure([List properties = const <dynamic>[]]) : super(properties);
}

// General Failures
class ServerFailure extends Failure {}

class CacheFailure extends Failure {}
