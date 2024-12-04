module VitePluginClassNameExtractor.Test.Build where

import Prelude

import Control.Monad.Error.Class (throwError)
import Control.Monad.Reader (class MonadAsk, ReaderT, runReaderT)
import Control.Monad.State (class MonadState, StateT, get, modify_, runStateT)
import CssClassNameExtractor.Data.Output (FileBody(..), coerceFileBody)
import CssClassNameExtractor.FS (class MonadFS)
import Data.Map (Map)
import Data.Map as Map
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple)
import Data.Tuple.Nested ((/\))
import Effect.Aff (Aff, error)
import Effect.Aff.Class (liftAff)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Console (log)
import Foreign.Object as FO
import Node.Path (FilePath)
import Test.Spec (Spec, describe, it)
import VitePluginClassNameExtractor.Build (build)
import VitePluginClassNameExtractor.Data.ClassNameExtractorConfig (ClassNameExtractorConfig(..))
import VitePluginClassNameExtractor.Data.TransformRule (TransformRule(..))
import VitePluginClassNameExtractor.Monad (PluginEnv)

type FileSystem = Map FilePath FileBody


derive newtype instance functorTestM :: Functor TestM
derive newtype instance applyTestM :: Apply TestM
derive newtype instance applicativeTestM :: Applicative TestM
derive newtype instance bindTestM :: Bind TestM
derive newtype instance monadTestM :: Monad TestM
derive newtype instance monadEffectTestM :: MonadEffect TestM
derive newtype instance monadAskTestM :: MonadAsk PluginEnv TestM
derive newtype instance monadStateTestM :: MonadState FileSystem TestM

instance monadFSTestM :: MonadFS TestM where
  readFile path = do
    fs <- get
    case Map.lookup path fs of
      Just content -> pure (coerceFileBody content)
      Nothing -> liftEffect $ throwError $ error $ "File not found: " <> path

  writeFile path content = do
    modify_ $ Map.insert path content

  isExists _ = pure true

newtype TestM a = TestM (StateT FileSystem ((ReaderT PluginEnv Aff)) a)

runTest :: forall a. ClassNameExtractorConfig -> FileSystem -> TestM a -> Aff (Tuple a FileSystem)
runTest config init (TestM m) = do
  runReaderT (runStateT m init) { config }

spec :: Spec Unit
spec = do
  describe "Build" do
    it "should be writed file" do
      let config = ClassNameExtractorConfig {
        projectPrefix: "Project",
        srcDir : "src",
        rules: FO.fromFoldable [ "foo.module.css" /\ TransformRule { prefix: Just "Components", suffix: Just "Style" } ]
      }
      result <- liftAff $  runTest config (Map.fromFoldable [
        "foo.module.css" /\ FileBody ".foo { display; flex; }"
        ]) (build "foo.module.css")
      liftEffect $ log (show result)
      pure unit
