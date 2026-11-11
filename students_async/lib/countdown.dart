Stream<int> countdown(int seconds) async* {
  for (int i = seconds; i >= 0; i--) {
    yield i;

    if (i > 0) {
      await Future.delayed(const Duration(seconds: 1));
    }
  }
}
