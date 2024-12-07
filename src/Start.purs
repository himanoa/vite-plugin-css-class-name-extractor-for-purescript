module VitePluginClassNameExtractor.Start where

import Prelude

import Control.Promise (Promise, fromAff)
import Data.Either (either)
import Effect (Effect)
import VitePluginClassNameExtractor.Data.ClassNameExtractorConfig (ClassNameExtractorConfig, defaultConfig, parseClassNameExtractorConfig)
import VitePluginClassNameExtractor.Monad (runPlugin)
import VitePluginClassNameExtractor.PreBuild (prebuild)
import VitePluginClassNameExtractor.Watch (ConfigJson)

-- | Move CSS files to the output directory before building to ensure build idempotency.
-- | This function is executed when Vite starts up
handleStart :: ConfigJson -> Effect (Promise Unit)
handleStart config = do
  either
    (\_ -> runPrebuild defaultConfig)
    runPrebuild
    (parseClassNameExtractorConfig config)


runPrebuild :: ClassNameExtractorConfig  -> Effect (Promise Unit)
runPrebuild config = fromAff do
  runPlugin {config: config} (prebuild)
  pure unit
