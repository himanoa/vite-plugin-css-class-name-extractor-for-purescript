module VitePluginClassNameExtractor.Build where

import Prelude

import Control.Monad.Reader (class MonadAsk, ask)
import CssClassNameExtractor.Execute (execute)
import CssClassNameExtractor.FS (class MonadFS)
import Data.Foldable (find, for_)
import Data.Maybe (Maybe(..))
import Data.String (Pattern(..), replace)
import Data.String.Pattern (Replacement(..))
import Data.String.Utils (endsWith)
import Data.Tuple (Tuple, fst, snd)
import Effect.Class (class MonadEffect)
import Foreign.Object as FO
import Node.Minimatch (minimatch)
import Node.Path (FilePath, basename)
import VitePluginClassNameExtractor.Data.ClassNameExtractorConfig (ClassNameExtractorConfig(..))
import VitePluginClassNameExtractor.Data.Namespace (coerceNamespace)
import VitePluginClassNameExtractor.Data.TransformRule (TransformRule, toNamespace)
import VitePluginClassNameExtractor.Monad (PluginEnv)


build :: forall m. MonadFS m => MonadEffect m => (MonadAsk PluginEnv m) => FilePath -> m Unit
build filePath = do
  {config} <- ask
  whenM (pure $ isCssModule filePath) do
    processModule config
  where
    processModule :: ClassNameExtractorConfig -> m Unit
    processModule (ClassNameExtractorConfig { rules }) = 
      for_ (findMatchingRule rules) \rule -> do
        let moduleName = replace (Pattern ".module.css") (Replacement "") $ basename filePath
        let ns = toNamespace rule moduleName
        execute filePath $ coerceNamespace ns

    findMatchingRule :: FO.Object TransformRule -> Maybe TransformRule
    findMatchingRule rules = 
      case entries rules of
        [] -> Nothing
        r -> map snd $ find (\pair -> fst pair # minimatch filePath) r

isCssModule :: String -> Boolean 
isCssModule = endsWith ".module.css"

entries :: forall a. FO.Object a -> Array (Tuple String a)
entries = FO.toUnfoldable
