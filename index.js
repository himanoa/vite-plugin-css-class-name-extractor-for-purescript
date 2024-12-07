import { handleWatch } from './output/VitePluginClassNameExtractor.Watch/index.js'
import { handleStart } from './output/VitePluginClassNameExtractor.Start/index.js'

export function vitePluginCssClassNameExtractorForPureScript(config) {
  let server;

  return {
    name: "vite-plugin-css-class-name-extractor-for-purescript",
    apply: 'serve',
    configureServer(s) {
      server = s
    },
    async buildStart() {
      await handleStart(JSON.stringify(config))()
      const events = ["add", "addDir", "change", "unlink", "unlinkDir"]
      for (const e of events) {
        server.watcher.on(e, (entry) => {
          handleWatch(JSON.stringify(config))(entry)()
        })
      }
    }
  }
}
