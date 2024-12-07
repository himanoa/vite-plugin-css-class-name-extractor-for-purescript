# ClassNameExtractor Vite Plugin

A Vite plugin that enables type-safe usage of CSS Modules in PureScript applications. It automatically generates PureScript APIs and JavaScript FFI code for accessing CSS Module selectors.

## Key Features

- Type-safe PureScript API generation for CSS Module selectors
- Automatic JavaScript FFI code generation
- Type-safe configuration support for PureScript

## Installation

```bash
npm install vite-plugin-css-class-name-extractor-for-purescript --save-dev
```

## Usage

Just add the plugin to your vite.config.ts:

```typescript
import { defineConfig } from 'vite'
import classNameExtractor from 'vite-plugin-css-class-name-extractor-for-purescript'

export default defineConfig({
  plugins: [
    classNameExtractor()
  ]
})
```

The default configuration includes the following rules:

```typescript
{
  rules: {
    "src/**/*.module.css": {
      replacement: "\\2.Styles"
    },
    "src/**/*.css": {
      replacement: "\\2.Styles"
    }
  }
}
```

To add custom rules, specify glob patterns and their transformation rules:

```typescript
export default defineConfig({
  plugins: [
    classNameExtractor({
      rules: {
        "src/features/*/components/*/styles.module.css": {
          replacement: "Features.\\1.Components.\\2.Styles"
        }
      }
    })
  ]
})
```

Path segments can be referenced in replacement patterns using `\\1`, `\\2`, etc. For example:
- `src/components/button/styles.module.css` becomes `Button.Styles`
- `src/pages/user/profile/styles.module.css` becomes `Profile.Styles`

## Generated Code

Given a CSS Module file (`Colors.module.css`):

```css
.wrapper { display: flex; }
.foo > .bar { display: flex; }
```

The plugin generates the following code.

### Generated PureScript Module

`Colors.Styles.purs`:
```purescript
module Colors.Styles (wrapper, foo, bar) where

foreign import _styles :: String -> String

wrapper :: String
wrapper = _styles "wrapper"

foo :: String
foo = _styles "foo"

bar :: String
bar = _styles "bar"
```

### Generated JavaScript FFI File

`Colors.Styles.js`:
```javascript
import s from "./Colors.module.css"
export const _styles = (name) => s[name]
```

The generated code provides:

- Type-safe CSS selector references
- Compile-time type checking
- IDE code completion support

## License

MIT
