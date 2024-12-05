import { defineConfig } from 'vite'
import { vitePluginCssClassNameExtractorForPureScript } from "../index.js"

export default defineConfig(({ mode }) => {
  return {
    clearScreen: false,
    plugins: [
      vitePluginCssClassNameExtractorForPureScript({})
    ]
  }
})
