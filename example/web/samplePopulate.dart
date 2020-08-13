import 'dart:html';

main() {
  var sampleDiv = querySelector('#sample');

  var message = new ParagraphElement()..text = "Hello from dart!";
  sampleDiv.children.add(message);
}
