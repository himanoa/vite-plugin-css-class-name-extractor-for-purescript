import { defineConfig } from 'vite'
import { vitePluginCssClassNameExtractorForPureScript } from "../dist/index.mjs"

export default defineConfig(({ mode }) => {
  return {
    clearScreen: false,
    plugins: [
      vitePluginCssClassNameExtractorForPureScript({})
    ]
  }
})
