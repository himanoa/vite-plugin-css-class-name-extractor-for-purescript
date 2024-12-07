declare module '*/VitePluginClassNameExtractor.Watch/index.js' {
  export function handleWatch(config: string): () => Promise<void>;
}

declare module '*/VitePluginClassNameExtractor.Start/index.js' {
  export function handleStart(config: string): () => Promise<void>;
}
