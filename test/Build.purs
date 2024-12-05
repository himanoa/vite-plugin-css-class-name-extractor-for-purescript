module VitePluginClassNameExtractor.Test.Build where

import Prelude

import Control.Monad.Cont.Trans (lift)
import Control.Monad.Error.Class (class MonadError, class MonadThrow, catchError)
import Control.Monad.Reader (class MonadAsk, ReaderT, runReaderT)
import Control.Monad.State (class MonadState, StateT(..), get, modify_, runStateT)
import CssClassNameExtractor.Data.Output (FileBody(..), coerceFileBody)
import CssClassNameExtractor.FS (class MonadFS)
import Data.Map (Map)
import Data.Map as Map
import Data.Maybe (Maybe(..))
import Data.Newtype (unwrap)
import Data.Tuple (Tuple(..))
import Data.Tuple.Nested ((/\))
import Effect.Aff (Aff, Error, error, message)
import Effect.Aff as Aff
import Effect.Aff.Class (liftAff)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Console (log)
import Foreign.Object as FO
import Node.Path (FilePath)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldNotEqual)
import VitePluginClassNameExtractor.Build (build)
import VitePluginClassNameExtractor.Data.ClassNameExtractorConfig (ClassNameExtractorConfig(..))
import VitePluginClassNameExtractor.Data.TransformRule (PlaceHolderError(..), TransformRule(..), TransformRuleReplacement(..), fromError, toError)
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

newtype TestM a = TestM (StateT FileSystem (((ReaderT PluginEnv Aff))) a)

instance monadFSTestM :: MonadFS TestM where
  readFile path = do
    fs <- get
    case Map.lookup path fs of
      Just content -> pure (coerceFileBody content)
      Nothing -> liftEffect $ Aff.throwError $ error $ "File not found: " <> path

  writeFile path content = do
    modify_ $ Map.insert path content

  isExists _ = pure true

instance MonadThrow PlaceHolderError TestM where
  throwError e = TestM $ lift $ lift $ Aff.throwError (toError e)


instance MonadError PlaceHolderError TestM where
  catchError (TestM m) h = TestM $ StateT \s -> 
    Aff.catchError 
      (runStateT m s) 
      (\err -> let TestM m' = h (fromError err) in runStateT m' s)

runTest :: forall a. ClassNameExtractorConfig -> FileSystem -> TestM a -> Aff (Tuple a FileSystem)
runTest config init (TestM m) = do
  runReaderT (runStateT m init) { config }

spec :: Spec Unit
spec = do
  describe "Build" do
    it "should be writed file" do
      let config = ClassNameExtractorConfig {
        rules: FO.fromFoldable [ "foo.module.css" /\ TransformRule { replacement: (TransformRuleReplacement "foo") } ]
      }
      (Tuple _ result) <- liftAff $  runTest config (Map.fromFoldable [
        "foo.module.css" /\ FileBody ".foo { display; flex; }"
        ]) (build "foo.module.css")

      liftEffect $ log $ show result
      result `shouldNotEqual` Map.empty

    describe "when nested directory" do
      it "should be writed file" do
        let config = ClassNameExtractorConfig {
          rules: FO.fromFoldable [ "src/*/*.css" /\ TransformRule { replacement: (TransformRuleReplacement "\\1") } ]
        }
        (Tuple _ result) <- liftAff $  runTest config (Map.fromFoldable [
          "src/Foo/styles.module.css" /\ FileBody ".foo { display; flex; }"
          ]) (build "src/Foo/styles.module.css")
        liftEffect $ log $ show result
        result `shouldNotEqual` Map.empty
