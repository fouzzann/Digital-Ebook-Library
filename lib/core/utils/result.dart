/// Functional programming `Either<L, R>` structure for explicit failure or success return types.
abstract class Either<L, R> {
  const Either();

  bool get isLeft;
  bool get isRight;

  L get left;
  R get right;

  T fold<T>(T Function(L l) ifLeft, T Function(R r) ifRight);
}

class Left<L, R> extends Either<L, R> {
  final L _value;
  const Left(this._value);

  @override
  bool get isLeft => true;

  @override
  bool get isRight => false;

  @override
  L get left => _value;

  @override
  R get right => throw StateError('Called right on Left value');

  @override
  T fold<T>(T Function(L l) ifLeft, T Function(R r) ifRight) => ifLeft(_value);
}

class Right<L, R> extends Either<L, R> {
  final R _value;
  const Right(this._value);

  @override
  bool get isLeft => false;

  @override
  bool get isRight => true;

  @override
  L get left => throw StateError('Called left on Right value');

  @override
  R get right => _value;

  @override
  T fold<T>(T Function(L l) ifLeft, T Function(R r) ifRight) => ifRight(_value);
}
