import 'package:equatable/equatable.dart';
import '../errors/failures.dart';
import 'result.dart';

/// Abstract base class for all domain UseCases following Clean Architecture.
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// NoParams helper class when a UseCase doesn't require parameters.
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}
