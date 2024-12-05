module VitePluginClassNameExtractor.Build where

import Prelude

import Control.Monad.Error.Class (class MonadError, class MonadThrow)
import Control.Monad.Reader (class MonadAsk, ask)
import CssClassNameExtractor.Execute (execute)
import CssClassNameExtractor.FS (class MonadFS)
import Data.Either (either)
import Data.Foldable (find, for_)
import Data.Maybe (Maybe(..))
import Data.String.Utils (endsWith)
import Data.Tuple (Tuple(..), fst, snd)
import Data.Tuple.Nested (type (/\), (/\))
import Effect.Aff (catchError, throwError)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Console (log)
import Effect.Console as Console
import Foreign.Object as FO
import Node.Nanomatch (isMatch)
import Node.Path (FilePath, relative)
import Node.Process (cwd)
import VitePluginClassNameExtractor.Data.ClassNameExtractorConfig (ClassNameExtractorConfig(..))
import VitePluginClassNameExtractor.Data.Namespace (coerceNamespace)
import VitePluginClassNameExtractor.Data.TransformRule (GlobPattern(..), PlaceHolderError, TransformRule, toNamespace)
import VitePluginClassNameExtractor.Monad (PluginEnv)


build :: forall m. MonadFS m => MonadEffect m => (MonadAsk PluginEnv m) => MonadThrow PlaceHolderError m => MonadError PlaceHolderError m =>  FilePath -> m Unit
build filePath = do
  {config} <- ask
  current <- liftEffect cwd
  let filePath' = relative current filePath
  whenM (pure $ isCssModule filePath') do
    liftEffect $ log ("Build start: " <> filePath')
    (processModule filePath' config) `catchError` \err ->  liftEffect $ Console.error (show err)
    pure unit
  where
    processModule :: FilePath -> ClassNameExtractorConfig -> m Unit
    processModule fp (ClassNameExtractorConfig { rules }) = do
      liftEffect $ log (show rules)
      for_ (findMatchingRule fp rules) \(Tuple (GlobPattern pattern) rule) -> do
        let eitherNs = toNamespace rule (GlobPattern pattern) fp

        ns <- either (\err -> throwError err) (\n -> pure (coerceNamespace n)) eitherNs
        execute fp ns

    findMatchingRule :: FilePath -> FO.Object TransformRule -> Maybe (GlobPattern /\ TransformRule)
    findMatchingRule fp' rules = 
      case entries rules of
        [] -> Nothing
        (r) -> map (\n -> (GlobPattern (fst n)) /\ snd n) $ find (\pair -> fst pair # isMatch fp') r

isCssModule :: String -> Boolean 
isCssModule = endsWith ".module.css"

entries :: forall a. FO.Object a -> Array (Tuple String a)
entries = FO.toUnfoldable
