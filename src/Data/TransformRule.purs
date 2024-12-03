module VitePluginClassNameExtractor.Data.TransformRule where

import Data.Maybe (Maybe, maybe)
import Data.Monoid (mempty, (<>))
import VitePluginClassNameExtractor.Data.Namespace (Namespace, makeNamespace)

-- ! Helper module namespace rule
data TransformRule = TransformRule {
  prefix :: Maybe String,
  suffix :: Maybe String
}

type ModuleName = String

-- | Resolve the target namespace based on transform rule and module name
-- | ```purescript
-- | > let rule = TransformRule { prefix: Just "foo", suffix: Just "bar" }
-- | > toNamespace rule "Button" 
-- | Namespace foo.Button.bar
-- | ```
toNamespace :: TransformRule -> ModuleName -> Namespace
toNamespace (TransformRule { prefix, suffix }) name = prefix' <> (makeNamespace name) <> suffix'
  where
    prefix' = maybe mempty makeNamespace prefix
    suffix' = maybe mempty makeNamespace suffix
