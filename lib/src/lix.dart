// Originally from https://github.com/dart-lang/samples/blob/master/null_safety/calculate_lix/lib/lix.dart

class Lix {
  int words; // number of words in general
  int longWords; // number of words with more than 6 characters
  int periods; // number of periods
  int readability; // the calculated LIX readability index

  Lix({this.words, this.longWords, this.periods}) {
    readability = calculate();
  }

  factory Lix.fromString(String text) {
    // Count periods: . : ; ! ?
    var periods = (RegExp(r'[.:;!?]').allMatches(text).length);

    // Count words
    var allWords = text.replaceAll(RegExp(r'[.:;!?]'), '').split(RegExp(r'\W+'));
    var words = allWords.length;
    var longWords = allWords.where((w) => w.length > 6).length;

    return Lix(words: words, longWords: longWords, periods: periods);
  }

  int calculate() {
    if (words == 0 || periods == 0) {
      return 0; // Unknown score
    }

    final sentenceLength = words / periods;
    final wordLength = (longWords * 100) / words;
    return (sentenceLength + wordLength).round();
  }

  String describe() {
    if (readability > 0 && readability < 20) {
      return 'very easy';
    } else if (readability < 30) {
      return 'easy';
    } else if (readability < 40) {
      return 'a little hard';
    } else if (readability < 50) {
      return 'hard';
    } else if (readability < 60) {
      return 'very hard';
    } else {
      return 'unknown';
    }
  }
}
