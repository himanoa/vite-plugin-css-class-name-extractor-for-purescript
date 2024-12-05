module VitePluginClassNameExtractor.Data.ClassNameExtractorConfig where

import Data.Generic.Rep (class Generic)
import Foreign.Object as FO
import Simple.JSON (class ReadForeign)
import VitePluginClassNameExtractor.Data.TransformRule (TransformRule)

newtype ClassNameExtractorConfig = ClassNameExtractorConfig  {
  rules:: FO.Object TransformRule
}

derive instance Generic ClassNameExtractorConfig _

derive newtype instance ReadForeign ClassNameExtractorConfig

defaultConfig :: ClassNameExtractorConfig
defaultConfig = ClassNameExtractorConfig {
  rules: FO.empty
}
