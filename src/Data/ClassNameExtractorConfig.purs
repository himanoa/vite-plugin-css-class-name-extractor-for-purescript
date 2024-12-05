module VitePluginClassNameExtractor.Data.ClassNameExtractorConfig where


import Data.Either (Either)
import Data.Generic.Rep (class Generic)
import Data.List.NonEmpty (NonEmptyList)
import Data.Tuple.Nested ((/\))
import Foreign (ForeignError)
import Foreign.Object as FO
import Simple.JSON (class ReadForeign, readJSON)
import VitePluginClassNameExtractor.Data.TransformRule (TransformRule(..), TransformRuleReplacement(..))

newtype ClassNameExtractorConfig = ClassNameExtractorConfig  {
  rules:: FO.Object TransformRule
}

derive instance Generic ClassNameExtractorConfig _

parseClassNameExtractorConfig :: String -> Either (NonEmptyList ForeignError) ClassNameExtractorConfig
parseClassNameExtractorConfig json = readJSON json

derive newtype instance ReadForeign ClassNameExtractorConfig

defaultConfig :: ClassNameExtractorConfig
defaultConfig = ClassNameExtractorConfig {
  rules: FO.fromFoldable [
    "src/**/*.module.css" /\ TransformRule { replacement: (TransformRuleReplacement "\\2.Styles") },
    "src/**/*.css" /\ TransformRule { replacement: (TransformRuleReplacement "\\2.Styles") }
  ]
}
