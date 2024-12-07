module VitePluginClassNameExtractor.Watch where

import Prelude

import Data.Either (either)
import Effect (Effect)
import Effect.Aff (launchAff_)
import Node.Path (FilePath)
import VitePluginClassNameExtractor.Build (build)
import VitePluginClassNameExtractor.Data.ClassNameExtractorConfig (ClassNameExtractorConfig, defaultConfig, parseClassNameExtractorConfig)
import VitePluginClassNameExtractor.Monad (runPlugin)

type ConfigJson = String
handleWatch :: ConfigJson -> FilePath -> Effect Unit
handleWatch config id = do
  either (\_ -> runBuild id defaultConfig) (runBuild id) (parseClassNameExtractorConfig config)

runBuild :: FilePath -> ClassNameExtractorConfig  -> Effect Unit
runBuild filePath config = do
  launchAff_ $ runPlugin {config: config} (build filePath)
