module VitePluginClassNameExtractor.Test.Data.TransformRule where

import Prelude

import Data.Maybe (Maybe(..))
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)
import VitePluginClassNameExtractor.Data.Namespace (makeNamespace)
import VitePluginClassNameExtractor.Data.TransformRule (TransformRule(..), toNamespace)

spec :: Spec Unit
spec = do
  describe "toNamespace" do
    it "should be Namespace foo.Button.bar" do
      let rule = TransformRule { prefix: Just "foo", suffix: Just "bar" }
      (toNamespace rule "Button") `shouldEqual` makeNamespace "foo.Button.bar"
