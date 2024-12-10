---
"vite-plugin-css-class-name-extractor-for-purescript": patch
---

Fix a bug where expandGlobsCwd does not work with multiple patterns

Process patterns individually to avoid interference between patterns
when matching files. This ensures correct rule application and
namespace generation for each pattern.
