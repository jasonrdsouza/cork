import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:cork_site/src/ari.dart';
import 'package:cork_site/src/lix.dart';
import 'package:yaml/yaml.dart';

import 'extensions.dart';
import 'utils.dart';

Builder metadataBuilder(_) => MetadataBuilder();

class MetadataBuilder implements Builder {
  @override
  Future build(BuildStep buildStep) async {
    var inputId = buildStep.inputId;

    var metadataOutputId = inputId.changeExtension(Extensions.metadata);
    var contentsOutputId = inputId.changeExtension(Extensions.markdownContent);

    var contents = await buildStep.readAsString(inputId);
    var metadata = extractMetadata(contents);

    if (metadata == null) {
      return;
    } else {
      metadata.addPath(inputId.path);
      metadata.addReadingTime();
      metadata.addLixScore();
      metadata.addAutomatedReadabilityScore();
    }

    await Future.wait([
      buildStep.writeAsString(contentsOutputId, metadata.content),
      buildStep.writeAsString(metadataOutputId, json.encode(metadata.metadata)),
    ]);
  }

  @override
  Map<String, List<String>> get buildExtensions {
    return {
      Extensions.markdown: [
        Extensions.metadata,
        Extensions.markdownContent,
      ]
    };
  }
}

MetadataOutput? extractMetadata(String fileContents) {
  const separator = '---';
  var lines = fileContents.split('\n');
  if (!lines.first.startsWith(separator)) return null;

  int? closingMetadataSeparatorIdx;
  for (var i = 1; i < lines.length; i++) {
    if (lines[i].startsWith(separator)) {
      closingMetadataSeparatorIdx = i;
      continue;
    }
  }
  if (closingMetadataSeparatorIdx == null) return null;

  var yamlStr = lines.getRange(1, closingMetadataSeparatorIdx).join('\n');
  var yaml = loadYaml(yamlStr);
  if (yaml is! Map) {
    throw ('unexpected metadata');
  }

  var metadata = Map<String, dynamic>.from(yaml);
  var content =
      lines.getRange(closingMetadataSeparatorIdx + 1, lines.length).join('\n');
  return MetadataOutput(metadata, content);
}

class MetadataOutput {
  static const autogeneratedMetadataPrefix = 'CORK_';
  final Map<String, dynamic> metadata;
  final String content;
  MetadataOutput(this.metadata, this.content);

  void addPath(String filepath) {
    metadata['${autogeneratedMetadataPrefix}url'] = getHtmlPath(filepath);
  }

  void addReadingTime() {
    metadata['${autogeneratedMetadataPrefix}reading_time'] =
        calculateReadingTimeMinutes(content);
  }

  void addLixScore() {
    metadata['${autogeneratedMetadataPrefix}lix_readability_score'] =
        Lix.fromString(content).readability;
  }

  void addAutomatedReadabilityScore() {
    metadata['${autogeneratedMetadataPrefix}ari_readability_score'] =
        AutomatedReadabilityIndex.fromString(content).readability;
  }
}
