module Conferer.Provider.JSONSpec where

import Data.Aeson.QQ.Simple
import Data.Aeson
import Test.Hspec

import Conferer

spec = do
  describe "json provider" $ do
    it "getting an existing path returns the right value" $ do
      c <- emptyConfig
           & addProvider (mkJsonProvider' [aesonQQ| {"postgres": {"url": "some url", "ssl": true}} |])
      res <- getKey "postgres.url" c
      res `shouldBe` Right "some url"

    it "getting an non existing path returns nothing" $ do
      c <- emptyConfig
           & addProvider (mkJsonProvider' [aesonQQ| {"postgres": {"url": "some url", "ssl": true}} |])
      res <- getKey "some.path" c
      res `shouldBe` Left "Key 'some.path' was not found"

    describe "with an array" $ do
      it "getting a path with number gets the right value" $ do
        c <- emptyConfig
             & addProvider (mkJsonProvider'
                          [aesonQQ| {"key": ["value"]} |])
        res <- getKey "key.0" c
        res `shouldBe` Right "value"

    describe "with an object" $ do
      it "getting an existing path returns nothing" $ do
        c <- emptyConfig
           & addProvider (mkJsonProvider'
            [aesonQQ| {"key": { "path": "value"}} |])
        res <- getKey "key" c
        res `shouldBe` Left "Key 'key' was not found"

    describe "with an int" $ do
      let c =
            mkJsonProvider'
      it "getting an existing path returns the right value" $ do
        c <- emptyConfig
           & addProvider (mkJsonProvider' [aesonQQ| {"key": 1} |])
        res <- getKey "key" c
        res `shouldBe` Right "1"

    describe "with a float" $ do
      let c =
            mkJsonProvider'
      it "getting an existing path returns the right value" $ do
        c <- emptyConfig
           & addProvider (mkJsonProvider' [aesonQQ| {"key": 1.2} |])
        res <- getKey "key" c
        res `shouldBe` Right "1.2"

    describe "with a boolean" $ do
      let c =
            mkJsonProvider'
      it "getting an existing path returns the right value" $ do
        c <- emptyConfig
           & addProvider (mkJsonProvider' [aesonQQ| {"key": false} |])
        res <- getKey "key" c
        res `shouldBe` Right "false"