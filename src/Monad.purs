module VitePluginClassNameExtractor.Monad where

import Prelude

import Control.Monad.Reader (ReaderT, ask, runReaderT)
import Control.Monad.Reader.Class (class MonadAsk)
import CssClassNameExtractor.RIO as CssRIO
import Effect.Aff (Aff)
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Class (class MonadEffect)
import VitePluginClassNameExtractor.Data.ClassNameExtractorConfig (ClassNameExtractorConfig)

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

getConfig :: Plugin ClassNameExtractorConfig
getConfig = _.config <$> ask

runPlugin :: forall a. PluginEnv -> Plugin a -> Aff a
runPlugin env (Plugin m) = runReaderT m env

liftCssRIO :: forall a. CssRIO.RIO a -> Plugin a
liftCssRIO rio = do
  let cssEnv = {} 
  Plugin $ liftAff $ CssRIO.runRIO cssEnv rio
