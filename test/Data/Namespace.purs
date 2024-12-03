module VitePluginClassNameExtractor.Test.Data.Namespace where

import Prelude

import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)
import VitePluginClassNameExtractor.Data.Namespace (makeNamespace)

spec :: Spec Unit
spec = do
  describe "Semigroup" do
    describe "#append" do
      describe "when a and b is not empty" do
        it "should be 'foo.bar'" do
          ((makeNamespace "foo")  <> (makeNamespace "bar")) `shouldEqual` makeNamespace "foo.bar"
      describe "when a is empty" do
        it "should be 'bar'" do
          ((mempty)  <> (makeNamespace "bar")) `shouldEqual` makeNamespace "bar"
      describe "when b is empty" do
        it "should be 'foo'" do
          ((makeNamespace "foo")  <> (mempty)) `shouldEqual` makeNamespace "foo"

      describe "when a and b is empty" do
        it "should be ''" do
          ((mempty)  <> (mempty)) `shouldEqual` makeNamespace ""
