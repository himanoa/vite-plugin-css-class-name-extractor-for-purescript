# vite-plugin-css-class-name-extractor-for-purescript

## 0.0.3

### Patch Changes

- e9f33ab: Remove unnecessary conditional running of the plugin

  This commit removes the apply: 'serve' configuration from the plugin to allow it to
  run in all Vite environments, not just development. This change was needed because
  CSS class name extraction is required for both development and production builds.