---
title: "Post with Tags"
tags: ['code', 'dartlang']
template: post.mustache
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
<code>
{{> lib/gists/fibonacci.dart}}
</code>
</pre>
