import 'dart:html';

main() {
  var sampleDiv = querySelector('#sample');

  var message = ParagraphElement()..text = 'Hello from dart!';
  sampleDiv.children.add(message);
}
