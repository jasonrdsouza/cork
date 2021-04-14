import 'package:path/path.dart' as path;

// Converts a local filepath to its web equivalent
String getHtmlPath(String filepath) {
  // example: sample/path/to/file.ext
  var directoryParts =
      path.split(path.dirname(filepath)); // ['sample', 'path', 'to']
  var htmlFilename =
      path.basenameWithoutExtension(filepath) + '.html'; // file.html

  var htmlPathComponents = directoryParts.sublist(1);
  htmlPathComponents.add(htmlFilename); // ['path', 'to', 'file.html']
  return htmlPathComponents.join('/'); // path/to/file.html
}

// Calculates the amount of time it would take to read the given content
int calculateReadingTimeMinutes(String content) {
  const READER_WORDS_PER_MINUTE = 200;
  var contentWords = content.split(RegExp(r'\s+')).length;
  return (contentWords / READER_WORDS_PER_MINUTE).round() + 1;
}
