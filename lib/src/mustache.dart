import 'dart:convert';

import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:mustache_template/mustache.dart' as mustache;

import 'extensions.dart';

Builder mustacheBuilder(_) => MustacheBuilder();

class MustacheBuilder implements Builder {
  @override
  Future build(BuildStep buildStep) async {
    var inputId = buildStep.inputId;

    var htmlOutputId = inputId.changeExtension(Extensions.html);
    var jsonOutputId = inputId.changeExtension(Extensions.json);

    var contents = await buildStep.readAsString(inputId);
    var metadata = await _readMetadata(buildStep);
    var templateName = metadata['template'] ?? '';
    var templateStr = await _readTemplate(buildStep, templateName);

    var template = mustache.Template(templateStr, lenient: true);

    // Populate any mustache variables in the actual content, using the frontmatter metadata as input
    var contentTemplate = mustache.Template(contents, lenient: true);
    // Then, set the entire rendered content as a metadata variable called "content" to allow
    // it to be injected into the template used for this page
    metadata['content'] = contentTemplate.renderString(metadata);
    var htmlOutput = template.renderString(metadata);

    await Future.wait([
      buildStep.writeAsString(htmlOutputId, htmlOutput),
      buildStep.writeAsString(jsonOutputId, json.encode(metadata)),
    ]);
  }

  Future<Map<String, dynamic>> _readMetadata(BuildStep buildStep) async {
    var id = buildStep.inputId.changeExtension(Extensions.metadata);
    try {
      return _parseNonNull(await buildStep.readAsString(id));
    } on AssetNotFoundException {
      return <String, dynamic>{};
    }
  }

  static Map<String, dynamic> _parseNonNull(String metadata) {
    try {
      var m = json.decode(metadata);
      if (m == null) {
        return <String, dynamic>{};
      }
      return m;
    } on FormatException {
      return <String, dynamic>{};
    }
  }

  Future<String> _readTemplate(BuildStep buildStep, String fileName) async {
    var assets = await buildStep.findAssets(Glob('web/templates/*.mustache')).toList();
    for (var asset in assets) {
      var assetFileName = asset.path.split('/').last;
      if (assetFileName == fileName) {
        var assetStr = await buildStep.readAsString(AssetId(asset.package, asset.path));
        return assetStr;
      }
    }

    return '';
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        Extensions.htmlContent: [Extensions.html, Extensions.json],
      };
}
