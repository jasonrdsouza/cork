# Cork
A minimalist personal static site generator.

[![pub package](https://img.shields.io/pub/v/cork_site?style=for-the-badge)](https://pub.dev/packages/cork_site)


This is an attempt to write the simplest possible static site generator that satisfies my own personal use cases and needs. It is not meant as a general purpose solution, and common site generation features which I don't use have been purposefully left out. *Use at your own risk*


## Features
As mentioned above, the feature set of Cork is very much tailored to my personal site needs, and so purportedly table-stakes features of competing static site generators may work differently or be entirely absent here. If you want a more friendly, generalized, or feature-rich static site generator, I suggest [Jekyll](https://jekyllrb.com/) or [Hugo](https://gohugo.io/), both of which I've used in the past and found excellent.

Warnings aside, Cork supports the following.

### Markdown and Mustache
Cork expects that pages of the site will be written in [Markdown](https://en.wikipedia.org/wiki/Markdown), and templated with [Mustache](https://mustache.github.io/). It also supports regular html pages, but the general idea is to define Mustache templates and reference them from content containing markdown files.

### YAML Front Matter
Speaking of references, Cork allows for YAML [front matter](https://jekyllrb.com/docs/front-matter/) to be specified at the beginning of every markdown file. This YAML content lets you set predefined variables (such as `template` to specify the mustache template to use for the page in question during site generation), as well as create custom variables which are accesible in the content of the post via standard "double mustache" syntax.

### Minimal Assumptions
In terms of site structure, Cork makes minimal assumptions. Other than putting the site in the `web/` directory, the only other requirement is that you put your templates in the `web/templates/` folder.

All the rest of the site's structure is up to you. Keep in mind that the folder layout you choose within `web/` will be mimiced in the generated site, meaning that putting a blog post in `web/post/post1.html` will result in a final url of `www.sitename.com/post/post1.html`.

*Note that depending on where you host your generated site, the humanized `www.sitename.com/post/post1` url will also work, but if not you can explicitly make it work by storing the post at `web/post/post1/index.html` instead.*

This means you're free to put other assets such as CSS, images, and javascript wherever you want within `web/`, and responsible for ensuring those locations line up with references to the assets in your templates and html files.

### Old School Themes
A result of the lack of assumptions is that there is no built-in support for themes like you get with a lot of other static site generators. Instead, you are responsible for adding whatever CSS, JS, and templates are necessary to achieve the look you want.

### Dart Scripting
In addition to regular JS support, Cork has native support for client-side scripting in [Dart](https://dart.dev/). Any [Dart Web scripts](https://dart.dev/web) you write will automatically get converted to javascript and be usable on your site. The example site has samples demonstrating using Dart in this way.

### Transclusion
Finally, Cork enables transclusion of files within Markdown content, similar to [Mustache's Partials](https://mustache.github.io/mustache.5.html#Partials). This is useful if you wish to include an entire file (such as a script, code, or data file) within the body of a post.


## Usage
Since this tool uses Dart, you first need to [install the Dart SDK](https://dart.dev/get-dart).

Once dart is installed, create a new folder for the site, and add a `pubspec.yaml` file like you would for any new Dart project:

```sh
~> mkdir my_site
~> cd my_site
~> touch pubspec.yaml
```

In that `pubspec.yaml` file, add Cork as a dependency, along with the necessary [build runners dependencies](https://dart.dev/tools/build_runner):

```
name: my_site
dependencies:
  cork_site: ^0.0.1
  build: any
dev_dependencies:
  build_runner: any
  build_web_compilers: any
```

Next, create a `web/` folder to hold your site's contents, and add some contents. See the `example/` folder for a sample site.

```sh
mkdir web
vim web/index.md

... add templates, css, markdown posts, etc
```

Finally, to generate your site, there are two options.

Start by fetching any missing dependencies.

```sh
pub get
```

Then, while working on your site, you can run a development server which live-reloads your changes

```sh
pub run build_runner serve
```

When you're ready to generate a finished release of the site, run

```sh
pub run build_runner build --release --output <OUTPUT_FOLDER_LOCATION>
```


## Example
See the [example](example/) folder for an example of a site build using Cork, as well as a sample layout.
