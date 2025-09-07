import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:dart_rss/dart_rss.dart';
import 'package:glob/glob.dart';
import 'package:yaml/yaml.dart';

Builder rssBuilder(BuilderOptions options) => RssBuilder();

class RssBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
        'pubspec.yaml': ['web/rss.xml'],
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    if (buildStep.inputId.path != 'pubspec.yaml') {
      log.info('RSS: Skipping non-pubspec file: ${buildStep.inputId.path}');
      return;
    }

    print('RSS: Starting RSS generation...');

    try {
      final config = await _loadRssConfig(buildStep);
      if (config == null) {
        print('RSS: No rss.yaml config found');
        return;
      }

      print('RSS: Config loaded successfully');

      final posts = await _findRssPosts(buildStep);
      print('RSS: Found ${posts.length} RSS-enabled posts');

      if (posts.isEmpty) {
        print('RSS: No posts with RSS enabled found');
        return;
      }

      await _generateRssFeed(buildStep, config, posts);
      print('RSS: Generated RSS feed with ${posts.length} posts');
    } catch (e, stackTrace) {
      print('RSS: RSS generation failed: $e\n$stackTrace');
    }
  }

  Future<RssConfig?> _loadRssConfig(BuildStep buildStep) async {
    // Read RSS config from pubspec.yaml
    print('RSS DEBUG: Reading RSS config from pubspec.yaml');

    try {
      final pubspecContent = await buildStep.readAsString(buildStep.inputId);
      final yaml = loadYaml(pubspecContent) as Map;

      final rssConfig = yaml['cork_rss'] as Map?;
      if (rssConfig == null) {
        print('RSS DEBUG: No cork_rss section found in pubspec.yaml');
        return null;
      }

      print('RSS DEBUG: Found cork_rss config in pubspec.yaml');
      // Recursively convert YamlMap to Map<String, dynamic>
      final configMap = _yamlToMap(rssConfig);
      return RssConfig.fromMap(configMap);
    } catch (e) {
      print('RSS DEBUG: Error reading pubspec.yaml: $e');
      return null;
    }
  }

  // Helper method to recursively convert YAML structures to regular Maps
  Map<String, dynamic> _yamlToMap(dynamic yaml) {
    if (yaml is Map) {
      return Map<String, dynamic>.fromEntries(
        yaml.entries.map((entry) => MapEntry(
              entry.key.toString(),
              entry.value is Map ? _yamlToMap(entry.value) : entry.value,
            )),
      );
    }
    return yaml as Map<String, dynamic>;
  }

  Future<List<RssPost>> _findRssPosts(BuildStep buildStep) async {
    final posts = <RssPost>[];
    int totalMetadataFiles = 0;

    print('RSS DEBUG: Starting to find RSS posts...');

    await for (final input in buildStep.findAssets(Glob('**.metadata'))) {
      totalMetadataFiles++;
      print('RSS DEBUG: Processing metadata file: ${input.path}');

      try {
        final metadataJson = await buildStep.readAsString(input);
        final metadata = json.decode(metadataJson) as Map<String, dynamic>;

        if (metadata['rss'] == true) {
          // Validate that RSS-enabled posts have a date field
          if (metadata['date'] == null) {
            log.warning(
                'RSS post "${metadata['title'] ?? 'Untitled'}" has rss: true but no date field. Skipping.');
            continue;
          }

          final post = RssPost.fromMetadata(metadata);
          posts.add(post);
        }
      } catch (e) {
        log.warning('Failed to process metadata file ${input.path}: $e');
      }
    }

    posts.sort((a, b) => b.pubDate.compareTo(a.pubDate));
    return posts;
  }

  Future<void> _generateRssFeed(
    BuildStep buildStep,
    RssConfig config,
    List<RssPost> posts,
  ) async {
    final limitedPosts =
        config.maxItems != null ? posts.take(config.maxItems!).toList() : posts;

    final rss = RssFeed(
      title: config.title,
      description: config.description,
      link: config.baseUrl,
      language: config.language,
      copyright: config.copyright,
      managingEditor: config.author?.email,
      webMaster: config.author?.email,
      lastBuildDate: _formatDate(DateTime.now()),
      generator: 'Cork Static Site Generator',
      items: limitedPosts
          .map((post) => RssItem(
                title: post.title,
                description: post.description,
                link:
                    '${config.baseUrl.replaceAll(RegExp(r'/$'), '')}${post.url}',
                guid: post.guid,
                pubDate: _formatDate(post.pubDate),
                author: post.author ?? config.author?.email,
                categories: post.categories
                    .map((cat) => RssCategory(null, cat))
                    .toList(),
              ))
          .toList(),
    );

    final rssXml = rss.toXmlDocument().toString();
    final outputId = AssetId(buildStep.inputId.package, 'web/rss.xml');

    await buildStep.writeAsString(outputId, rssXml);
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    final weekday = weekdays[date.weekday - 1];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final second = date.second.toString().padLeft(2, '0');

    return '$weekday, $day $month $year $hour:$minute:$second GMT';
  }
}

class RssConfig {
  final String title;
  final String description;
  final String baseUrl;
  final String? language;
  final String? copyright;
  final RssAuthor? author;
  final int? maxItems;

  RssConfig({
    required this.title,
    required this.description,
    required this.baseUrl,
    this.language,
    this.copyright,
    this.author,
    this.maxItems,
  });

  factory RssConfig.fromMap(Map<String, dynamic> map) {
    return RssConfig(
      title: map['title'] as String,
      description: map['description'] as String,
      baseUrl: map['base_url'] as String,
      language: map['language'] as String?,
      copyright: map['copyright'] as String?,
      author: map['author'] != null
          ? RssAuthor.fromMap(map['author'] as Map<String, dynamic>)
          : null,
      maxItems: map['max_items'] as int?,
    );
  }
}

class RssAuthor {
  final String? name;
  final String? email;

  RssAuthor({this.name, this.email});

  factory RssAuthor.fromMap(Map<String, dynamic> map) {
    return RssAuthor(
      name: map['name'] as String?,
      email: map['email'] as String?,
    );
  }
}

class RssPost {
  final String title;
  final String description;
  final String url;
  final DateTime pubDate;
  final String guid;
  final String? author;
  final List<String> categories;

  RssPost({
    required this.title,
    required this.description,
    required this.url,
    required this.pubDate,
    required this.guid,
    this.author,
    this.categories = const [],
  });

  factory RssPost.fromMetadata(Map<String, dynamic> metadata) {
    final tags = metadata['tags'] as List<dynamic>? ?? [];
    final categories = tags.map((tag) => tag.toString()).toList();

    final title = metadata['title'] as String? ?? 'Untitled';
    final description = metadata['description'] as String? ?? title;
    final url = metadata['CORK_url'] as String? ?? '/';

    DateTime pubDate = DateTime.now();
    if (metadata['date'] != null) {
      try {
        pubDate = DateTime.parse(metadata['date'] as String);
      } catch (e) {
        print('Failed to parse date from metadata: ${metadata['date']}');
      }
    }

    final guid = url;

    return RssPost(
      title: title,
      description: description,
      url: url,
      pubDate: pubDate,
      guid: guid,
      author: metadata['author'] as String?,
      categories: categories,
    );
  }
}
