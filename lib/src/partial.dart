import 'package:build/build.dart';

import 'extensions.dart';

Builder partialBuilder(dynamic _) => PartialBuilder();

class PartialBuilder implements Builder {
  static final _includeRE = RegExp(r'{{>(\s*)(.*)}}(\s*)');

  @override
  Future build(BuildStep buildStep) async {
    var inputId = buildStep.inputId;
    var outputId = buildStep.inputId.changeExtension(Extensions.withPartials);

    var content = await buildStep.readAsString(inputId);
    final futures = <Future>[];
    final partials = <String, String>{};

    _includeRE.allMatches(content).forEach((match) {
      final path = match.group(2)!;

      var partialFuture = buildStep
          .readAsString(AssetId(inputId.package, path))
          .then((partial) async {
        partials[path] = partial;
      }).catchError((error) {
        print(error);
      });

      futures.add(partialFuture);
    });

    await Future.wait(futures);
    final newContent = content.replaceAllMapped(_includeRE, (match) {
      final path = match.group(2);
      return partials[path!]!;
    });

    await buildStep.writeAsString(outputId, newContent);
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        Extensions.markdownContent: [Extensions.withPartials],
      };
}
