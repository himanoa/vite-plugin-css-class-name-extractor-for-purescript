module VitePluginClassNameExtractor.Test.Data.TransformRule where

import Prelude

import Data.Array (range)
import Data.Either (Either(..))
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)
import VitePluginClassNameExtractor.Data.Namespace (makeNamespace)
import VitePluginClassNameExtractor.Data.TransformRule (GlobPattern(..), TransformRule(..), TransformRuleReplacement(..), replaceNameWithCaptures, toNamespace)

spec :: Spec Unit
spec = do
  describe "toNamespace" do
    it "should be Namespace foo.Button.bar" do
      let rule = TransformRule { replacement: (TransformRuleReplacement "Foo.\\1.Bar") }
      (toNamespace rule (GlobPattern "*") "Button") `shouldEqual` Right (makeNamespace "Foo.Button.Bar")

  describe "replacePlaceHolder" do
    describe "when capture is empty" do
      it "should be foo.csv" do
        replaceNameWithCaptures [] "foo.csv" `shouldEqual` Right("foo.csv")

    describe "\\1.csv" do
      it "should be foo.csv" do
        replaceNameWithCaptures ["foo"] "\\1.csv" `shouldEqual` Right("foo.csv")

    describe "\\1\\1.csv" do
      it "should be foo.csv" do
        replaceNameWithCaptures ["foo"] "\\1\\1.csv" `shouldEqual` Right("foofoo.csv")

    describe "\\1\\2.csv" do
      it "should be foo.csv" do
        replaceNameWithCaptures ["foo", "bar"] "\\1\\2.csv" `shouldEqual` Right("foobar.csv")

    describe "\\10.csv" do
      it "should be foo.csv" do
        replaceNameWithCaptures (map show (range 1 11)) "\\10.csv" `shouldEqual` Right("10.csv")

    describe "capture is not found" do
      it "should be \\3.csv" do
        replaceNameWithCaptures ["foo", "bar"] "\\3.csv" `shouldEqual` Right("\\3.csv")

