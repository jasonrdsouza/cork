import 'package:web/web.dart';

void main() {
  var sampleDiv = document.querySelector('#sample');

  var message = HTMLParagraphElement()..innerText = 'Hello from dart!';
  sampleDiv?.appendChild(message);
}
