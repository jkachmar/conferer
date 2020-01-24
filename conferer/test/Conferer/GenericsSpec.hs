{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE TypeApplications #-}
module Conferer.GenericsSpec where

import Test.Hspec

import Conferer
import Conferer.Types (UpdateFromConfig, DefaultConfig, configDef)

import GHC.Generics

data Thing = Thing
  { thingA :: Int
  , thingB :: Int
  } deriving (Generic, Show, Eq)

instance UpdateFromConfig Thing
instance DefaultConfig Thing where
  configDef = Thing 0 0
instance FetchFromConfig Thing

data Bigger = Bigger
  { biggerThing :: Thing
  , biggerB :: Int
  } deriving (Generic, Show, Eq)

instance UpdateFromConfig Bigger
instance DefaultConfig Bigger where
  configDef = Bigger configDef 1
instance FetchFromConfig Bigger

spec :: Spec
spec = do
  describe "Generics" $ do
    context "with a simple record" $ do
      context "when no keys are set" $ do
        it "returns the default" $ do
          c <- emptyConfig
                & addProvider (mkMapProvider [ ])

          res <- fetch @Thing "somekey" c
          res `shouldBe` Just Thing { thingA = 0, thingB = 0 }
      context "when all keys are set" $ do
        it "return the keys set" $ do
          c <- emptyConfig
                & addProvider (mkMapProvider 
                  [ ("somekey.a", "1")
                  , ("somekey.b", "2")
                  ])

          res <- fetch @Thing "somekey" c
          res `shouldBe` Just Thing { thingA = 1, thingB = 2 }

      context "when some keys are set" $ do
        it "uses the default and returns the keys set" $ do
          c <- emptyConfig
                & addProvider (mkMapProvider 
                  [ ("somekey.b", "2")
                  ])

          res <- fetch @Thing "somekey" c
          res `shouldBe` Just Thing { thingA = 0, thingB = 2 }

    context "with a nested record" $ do
      context "when none of the keys are set" $ do
        it "returns the default of both records" $ do
          c <- emptyConfig
                & addProvider (mkMapProvider 
                  [ ])

          res <- fetch @Bigger "somekey" c
          res `shouldBe` Just Bigger { biggerThing = Thing { thingA = 0, thingB = 0 }, biggerB = 1}

      context "when some keys of the top record are set" $ do
        it "returns the default for the inner record" $ do
          c <- emptyConfig
                & addProvider (mkMapProvider 
                  [ ("somekey.b", "30")
                  ])

          res <- fetch @Bigger "somekey" c
          res `shouldBe` Just Bigger { biggerThing = Thing { thingA = 0, thingB = 0 }, biggerB = 30}

      context "when some keys of the inner record are set" $ do
        it "returns the inner record updated" $ do
          c <- emptyConfig
                & addProvider (mkMapProvider 
                  [ ("somekey.thing.a", "30")
                  ])

          res <- fetch @Bigger "somekey" c
          res `shouldBe` Just Bigger { biggerThing = Thing { thingA = 30, thingB = 0 }, biggerB = 1}

      context "when every key is set" $ do
        it "returns everything with the right values" $ do
          c <- emptyConfig
                & addProvider (mkMapProvider 
                  [ ("somekey.thing.a", "10")
                  , ("somekey.thing.b", "20")
                  , ("somekey.b", "30")
                  ])

          res <- fetch @Bigger "somekey" c
          res `shouldBe` Just Bigger { biggerThing = Thing { thingA = 10, thingB = 20 }, biggerB = 30}
