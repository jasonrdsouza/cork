class AutomatedReadabilityIndex {
  int characters;
  int words;
  int sentences;

  int readability;

  AutomatedReadabilityIndex({this.characters, this.words, this.sentences}) {
    readability = calculate();
  }

  factory AutomatedReadabilityIndex.fromString(String text) {
    var punctuation = RegExp(r'[.:;!?]');

    var characters = text.replaceAll(RegExp(r'[.:;!?\s]'), '').length;
    var words = text.split(RegExp(r'\s+')).length;
    var sentences = text.split(punctuation).length;

    return AutomatedReadabilityIndex(
        characters: characters, words: words, sentences: sentences);
  }

  int calculate() {
    if (characters == 0 || words == 0 || sentences == 0) {
      return 0;
    }

    // From https://en.wikipedia.org/wiki/Automated_readability_index
    return (4.71 * (characters / words) + 0.5 * (words / sentences) - 21.43)
        .ceil();
  }

  String describe() {
    if (readability == 1) {
      return 'Kindergarten';
    } else if (readability == 2) {
      return '1st/2nd grade';
    } else if (readability == 3) {
      return '3rd grade';
    } else if (readability == 4) {
      return '4th grade';
    } else if (readability == 5) {
      return '5th grade';
    } else if (readability == 6) {
      return '6th grade';
    } else if (readability == 7) {
      return '7th grade';
    } else if (readability == 8) {
      return '8th grade';
    } else if (readability == 9) {
      return '9th grade';
    } else if (readability == 10) {
      return '10th grade';
    } else if (readability == 11) {
      return '11th grade';
    } else if (readability == 12) {
      return '12th grade';
    } else if (readability == 13) {
      return 'College student';
    } else if (readability == 14) {
      return 'Professor';
    } else {
      return 'Unknown';
    }
  }
}
