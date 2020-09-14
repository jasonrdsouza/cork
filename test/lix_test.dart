import 'package:cork_site/src/lix.dart';
import 'package:test/test.dart';

void main() {
  test('Lix calculation works with provided arguments', () {
    var lix = Lix(words: 10, longWords: 2, periods: 2);
    expect(lix.readability, equals(25));
  });

  test('Lix calculation works as expected with sentences', () {
    expect(Lix.fromString('This is a test.').readability, equals(4));
    expect(Lix.fromString('This is a test. And this is another test sentence.').readability, equals(25));
  });

  test('Lix calculation fails gracefully with empty string', () {
    expect(Lix.fromString('').readability, equals(0));
  });
}
