import 'package:flutter_test/flutter_test.dart';
import 'package:fluxy/fluxy.dart';

void main() {
  test('Signal reactive value update test', () {
    final count = flux(0);
    expect(count.value, 0);
    
    count.value++;
    expect(count.value, 1);
  });

  test('Computed signal test', () {
    final count = flux(1);
    final doubled = computed(() => count.value * 2);
    
    expect(doubled.value, 2);
    
    count.value = 5;
    expect(doubled.value, 10);
  });
}
