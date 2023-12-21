### Building

Fetch dependencies:

```
dart pub get
```

Run dev server:

```
dart pub run build_runner serve
```

Lint and Analyze:

```
dart fix --dry-run
dart analyze
```

Format:

```
dart format .
```

Test:

```
dart test --chain-stack-traces
```

Before pushing code:

```
dart format . && dart analyze && dart test --chain-stack-traces
```

Publish to Pub

```
dart pub publish
```
