module VitePluginClassNameExtractor.Watch where

import Prelude

import Effect (Effect)
import Effect.Console (log)
import Node.Path (FilePath)

handleWatch :: FilePath -> Effect Unit
handleWatch id = do
  log id
