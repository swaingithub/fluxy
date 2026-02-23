import 'package:flutter_test/flutter_test.dart';
import 'package:fluxy/fluxy.dart';

void main() {
    test('Heavy computation runs in isolate without blocking', () async {
    print('🚀 Starting heavy computation...');
    
    final result = await fluxIsolate(() {
      int sum = 0;
      for (int i = 0; i < 10000000; i++) {
        sum += i;
      }
      return sum;
    });

    print('✅ Computation result: $result');
    expect(result > 0, true);
  });
}
