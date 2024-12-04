module VitePluginClassNameExtractor.Data.Namespace (
  makeNamespace,
  Namespace,
  coerceNamespace
)  where

import Prelude

import Control.Alternative (guard)
import CssClassNameExtractor.Data.Output as CCNE
import Data.Maybe (Maybe(..), maybe)
import Data.String (toUpper)
import Data.String.CodeUnits (singleton, uncons)
import Data.Tuple.Nested ((/\))

newtype Namespace = Namespace CCNE.Namespace

mguard :: forall m. Eq m => Monoid m => m -> Maybe m 
mguard x = x <$ guard (x /= mempty)

instance Semigroup Namespace where
  append (Namespace(CCNE.Namespace a)) (Namespace (CCNE.Namespace b)) =
    case ((mguard a) /\ (mguard b)) of
      Just a' /\ Nothing -> a'
      Nothing /\ Just b' -> b'
      Just a' /\ Just b' -> a' <> "." <> b'
      Nothing /\ Nothing -> mempty
    # CCNE.Namespace # Namespace

instance Monoid Namespace where
  mempty = "" # CCNE.Namespace # Namespace

derive newtype instance Show Namespace
derive newtype instance Eq Namespace

makeNamespace :: String -> Namespace
makeNamespace a = Namespace $ CCNE.Namespace $ capitalizeName $ a

capitalizeName :: String -> String
capitalizeName name = maybe name (\{head, tail} -> (toUpper $ singleton head) <> tail ) (uncons name)

coerceNamespace :: Namespace -> CCNE.Namespace
coerceNamespace (Namespace ns) = ns
