import { Plugin, ViteDevServer } from 'vite'
import { handleWatch } from './output/VitePluginClassNameExtractor.Watch/index.js'
import { handleStart } from './output/VitePluginClassNameExtractor.Start/index.js'

export type Config = {
  rules: Record<string, { replacement: string }>
}

export function vitePluginCssClassNameExtractorForPureScript(config: Config): Plugin<Config> {
  let server: ViteDevServer;
  let command: 'build' | 'serve'

  return {
    name: "vite-plugin-css-class-name-extractor-for-purescript",
    apply: 'serve',
    configResolved(s) {
      command = s.command
    },
    configureServer(s) {
      server = s
    },
    async buildStart() {
      await handleStart(JSON.stringify(config))()
      if(command === 'serve') {
        const events = ["add", "addDir", "change", "unlink", "unlinkDir"]
        for (const e of events) {
          server.watcher.on(e, (entry) => {
            handleWatch(JSON.stringify(config))(entry)()
          })
        }
      }
    }
  }
}
