module VitePluginClassNameExtractor.Build where

import Prelude

import Control.Monad.Error.Class (class MonadThrow)
import Control.Monad.Reader (class MonadAsk, ask)
import CssClassNameExtractor.Execute (execute)
import CssClassNameExtractor.FS (class MonadFS)
import Data.Either (either)
import Data.Foldable (find, for_)
import Data.Maybe (Maybe(..))
import Data.String.Utils (endsWith)
import Data.Tuple (Tuple(..), fst, snd)
import Data.Tuple.Nested (type (/\), (/\))
import Effect.Aff (throwError)
import Effect.Class (class MonadEffect)
import Foreign.Object as FO
import Node.Nanomatch (isMatch)
import Node.Path (FilePath)
import VitePluginClassNameExtractor.Data.ClassNameExtractorConfig (ClassNameExtractorConfig(..))
import VitePluginClassNameExtractor.Data.Namespace (coerceNamespace)
import VitePluginClassNameExtractor.Data.TransformRule (GlobPattern(..), PlaceHolderError, TransformRule, toNamespace)
import VitePluginClassNameExtractor.Monad (PluginEnv)


build :: forall m. MonadFS m => MonadEffect m => (MonadAsk PluginEnv m) => MonadThrow PlaceHolderError m =>  FilePath -> m Unit
build filePath = do
  {config} <- ask
  whenM (pure $ isCssModule filePath) do
    processModule config
  where
    processModule :: ClassNameExtractorConfig -> m Unit
    processModule (ClassNameExtractorConfig { rules }) = 
      for_ (findMatchingRule rules) \(Tuple (GlobPattern pattern) rule) -> do
        let eitherNs = toNamespace rule (GlobPattern pattern) filePath

        ns <- either (\err -> throwError err) (\n -> pure (coerceNamespace n)) eitherNs
        execute filePath ns

    findMatchingRule :: FO.Object TransformRule -> Maybe (GlobPattern /\ TransformRule)
    findMatchingRule rules = 
      case entries rules of
        [] -> Nothing
        (r) -> map (\n -> (GlobPattern (fst n)) /\ snd n) $ find (\pair -> fst pair # isMatch filePath) r

isCssModule :: String -> Boolean 
isCssModule = endsWith ".module.css"

entries :: forall a. FO.Object a -> Array (Tuple String a)
entries = FO.toUnfoldable
