# vite-plugin-css-class-name-extractor-for-purescript

## 0.0.5

### Patch Changes

- b5d3ed3: Update class-name-extractor

## 0.0.4

### Patch Changes

- c916710: Fix a bug where expandGlobsCwd does not work with multiple patterns

  Process patterns individually to avoid interference between patterns
  when matching files. This ensures correct rule application and
  namespace generation for each pattern.

## 0.0.3

### Patch Changes

- e9f33ab: Remove unnecessary conditional running of the plugin

  This commit removes the apply: 'serve' configuration from the plugin to allow it to
  run in all Vite environments, not just development. This change was needed because
  CSS class name extraction is required for both development and production builds.
