---
title: "Post with Tags"
tags: ['code', 'dartlang']
template: post.mustache
rss: true
date: "2025-01-10"
description: "A demo post showing how to add embed code snippets and transclude files in dart"
---

This is an example post with embedded code snippets:

For example, this snippet is directly embedded within the markdown
```dart
void main() {
  print('hello world');
}
```

And this one is transcluded from a file:
<pre>
<code class="language-dart">
{{> lib/fibonacci.dart}}
</code>
</pre>
