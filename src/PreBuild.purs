module VitePluginClassNameExtractor.PreBuild where

import Prelude

import Control.Monad.Error.Class (class MonadError, class MonadThrow, throwError)
import Control.Monad.Reader (class MonadAsk, ask)
import CssClassNameExtractor.DistributeCss (distributeCss)
import CssClassNameExtractor.FS (class MonadFS)
import Data.Array (find)
import Data.Either (either)
import Data.Foldable (for_)
import Data.Maybe (Maybe(..))
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Console (log, warn)
import Foreign.Object (keys)
import Foreign.Object as FO
import Node.Glob.Basic (expandGlobsCwd)
import Node.Nanomatch (isMatch)
import Node.Path (relative)
import Node.Process (cwd)
import VitePluginClassNameExtractor.Data.ClassNameExtractorConfig (ClassNameExtractorConfig(..))
import VitePluginClassNameExtractor.Data.Namespace (coerceNamespace)
import VitePluginClassNameExtractor.Data.TransformRule (GlobPattern(..), PlaceHolderError, toNamespace)
import VitePluginClassNameExtractor.Monad (PluginEnv)

-- | Move CSS files to the output directory before building to ensure build idempotency.
-- | This function is executed when Vite build start
prebuild :: forall m.
  MonadFS m =>
  MonadAff m =>
  MonadEffect m =>
  (MonadAsk PluginEnv m) =>
  MonadThrow PlaceHolderError m =>
  MonadError PlaceHolderError m =>
  m Unit
prebuild = do
  {config} <- ask
  current <- liftEffect $ cwd
  let (ClassNameExtractorConfig {rules}) = config
  let patterns = keys rules
  liftEffect $ log $ show patterns
  for_ (patterns) \(pattern') -> do
    files <- liftAff $ expandGlobsCwd [pattern']
    for_ (files) \(filePath) -> do
      let path = relative current filePath
      let pattern = find (\pat -> isMatch path pat) patterns
      case pattern of
        Just pat -> do
          for_ (FO.lookup pat rules) \rule -> do
            let eitherNs = toNamespace rule (GlobPattern pat) path
            ns <- either (\err -> throwError err) (\n -> pure (coerceNamespace n)) eitherNs
            distributeCss path ns
            liftEffect $ log $ "Distributed from: " <> path
        Nothing -> liftEffect $ warn $ "Can't match rules: " <> filePath
