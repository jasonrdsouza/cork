class AutomatedReadabilityIndex {
  int characters;
  int words;
  int sentences;

  int readability;

  AutomatedReadabilityIndex({this.characters, this.words, this.sentences}) {
    readability = calculate();
  }

  factory AutomatedReadabilityIndex.fromString(String text) {
    return AutomatedReadabilityIndex(characters: 0, words: 0, sentences: 0);
  }

  int calculate() {
    return 0;
  }

  String describe() {
    return 'todo';
  }
}
