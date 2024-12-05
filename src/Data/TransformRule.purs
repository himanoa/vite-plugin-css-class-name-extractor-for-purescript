module VitePluginClassNameExtractor.Data.TransformRule where

import Prelude

import Data.Either (Either(..), either)
import Data.FoldableWithIndex (foldlWithIndex)
import Data.Generic.Rep (class Generic)
import Data.Show.Generic (genericShow)
import Data.String.Regex as R
import Data.String.Regex.Flags (global)
import Node.Nanomatch (capture)
import Simple.JSON (class ReadForeign)
import VitePluginClassNameExtractor.Data.Namespace (Namespace, makeNamespace)

newtype TransformRuleReplacement = TransformRuleReplacement String

derive newtype instance ReadForeign TransformRuleReplacement

derive newtype instance Show TransformRuleReplacement
derive newtype instance Eq TransformRuleReplacement

-- ! Helper module namespace rule
newtype TransformRule = TransformRule {
  replacement :: TransformRuleReplacement
}


derive newtype instance ReadForeign TransformRule

derive newtype instance Show TransformRule
derive newtype instance Eq TransformRule

type ModuleName = String

newtype GlobPattern = GlobPattern String

derive newtype instance Show GlobPattern
derive newtype instance Eq GlobPattern

data PlaceHolderError = RegexCompileError { error:: String }

derive instance Generic PlaceHolderError _
instance Show PlaceHolderError where
  show = genericShow
derive instance Eq PlaceHolderError

replaceNameWithCaptures :: Array String -> String -> Either PlaceHolderError String
replaceNameWithCaptures captures name = do
  foldlWithIndex (replacePlaceHolder) (Right name) captures
  where
    replacePlaceHolder :: Int -> Either PlaceHolderError String -> String -> Either PlaceHolderError String
    replacePlaceHolder index acc value = 
      acc >>= \name' -> either
        (\error -> Left $ RegexCompileError { error })
        (\regex -> Right $ (R.replace regex value name'))
        (R.regex ("\\\\" <> (show (index + 1)) <> "(?![0-9])") global)


-- | Resolve the target namespace based on transform rule and module name
-- | ```purescript
-- | > let rule = TransformRule { prefix: Just "foo", suffix: Just "bar" }
-- | > toNamespace rule "Button" 
-- | Right $ Namespace foo.Button.bar
-- | ```
toNamespace :: TransformRule -> GlobPattern -> ModuleName -> Either PlaceHolderError Namespace
toNamespace (TransformRule { replacement }) (GlobPattern pattern) name = do
  let TransformRuleReplacement(rep) = replacement
  let captures = capture pattern name
  replacedName <- replaceNameWithCaptures captures rep
  Right $ makeNamespace replacedName
