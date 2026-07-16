import 'dart:math';

abstract interface class RandomSource {
  int nextInt(int max);
}

class DartRandomSource implements RandomSource {
  DartRandomSource([Random? random]) : _random = random ?? Random.secure();
  final Random _random;
  @override
  int nextInt(int max) => _random.nextInt(max);
}
