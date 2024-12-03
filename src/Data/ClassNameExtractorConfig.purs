module VitePluginClassNameExtractor.Data.ClassNameExtractorConfig where

import Prelude

import Data.Generic.Rep (class Generic)
import Simple.JSON (class ReadForeign)
import VitePluginClassNameExtractor.Data.TransformRule (TransformRule)
import Foreign.Object as FO

newtype ClassNameExtractorConfig = ClassNameExtractorConfig  {
  projectPrefix :: String,
  srcDir :: String,
  rules:: FO.Object TransformRule
}

derive instance Generic ClassNameExtractorConfig _

derive newtype instance ReadForeign ClassNameExtractorConfig
