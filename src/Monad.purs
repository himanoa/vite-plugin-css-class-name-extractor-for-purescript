module VitePluginClassNameExtractor.Monad where

import Prelude

import Control.Monad.Cont (lift)
import Control.Monad.Error.Class (class MonadError, class MonadThrow)
import Control.Monad.Reader (ReaderT(..), ask, runReaderT)
import Control.Monad.Reader.Class (class MonadAsk)
import Control.Monad.State (StateT(..), runStateT)
import CssClassNameExtractor.FS (class MonadFS)
import CssClassNameExtractor.FS (isExists, readFile, writeFile) as CssRIO
import CssClassNameExtractor.RIO (RIO, runRIO) as CssRIO
import Data.Newtype (unwrap)
import Effect.Aff (Aff)
import Effect.Aff as Aff
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Class (class MonadEffect)
import VitePluginClassNameExtractor.Data.ClassNameExtractorConfig (ClassNameExtractorConfig)
import VitePluginClassNameExtractor.Data.TransformRule (PlaceHolderError, fromError, toError)

type PluginEnv = {
  config :: ClassNameExtractorConfig
}

class HasConfig where
  config :: ClassNameExtractorConfig

newtype Plugin a = Plugin (ReaderT PluginEnv Aff a)

derive newtype instance Functor Plugin
derive newtype instance Apply Plugin
derive newtype instance Applicative Plugin
derive newtype instance Bind Plugin
derive newtype instance Monad Plugin
derive newtype instance MonadEffect Plugin
derive newtype instance MonadAff Plugin

instance MonadAsk PluginEnv Plugin where
  ask = Plugin ask

instance MonadFS Plugin where
  readFile = liftCssRIO <<< CssRIO.readFile 
  writeFile path = liftCssRIO <<< CssRIO.writeFile path
  isExists = liftCssRIO <<< CssRIO.isExists 

instance MonadThrow PlaceHolderError Plugin where
  throwError e = Plugin $ lift $ Aff.throwError (toError e)

instance MonadError PlaceHolderError Plugin where
  catchError (Plugin m) h = Plugin $ ReaderT \env -> 
    Aff.catchError (runReaderT m env) \err -> 
      runReaderT ((\(Plugin m') -> m') (h (fromError err))) env

getConfig :: Plugin ClassNameExtractorConfig
getConfig = _.config <$> ask

runPlugin :: forall a. PluginEnv -> Plugin a -> Aff a
runPlugin env (Plugin m) = runReaderT m env

liftCssRIO :: forall a. CssRIO.RIO a -> Plugin a
liftCssRIO rio = do
  let cssEnv = {} 
  Plugin $ liftAff $ CssRIO.runRIO cssEnv rio

