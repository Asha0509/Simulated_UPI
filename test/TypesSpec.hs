module TypesSpec (spec) where

import Test.Hspec (Spec, describe, it, shouldBe)
import Types (Amount(..), TxnState(..), VPA(..))
import qualified Data.Text as T

spec :: Spec
spec =
  describe "Types" $ do
    it "wraps Amount and exposes integer payload" $ do
      unAmount (Amount 500) `shouldBe` 500

    it "supports TxnState equality checks" $ do
      Settled `shouldBe` Settled

    it "wraps VPA text" $ do
      unVPA (VPA (T.pack "alice@bank")) `shouldBe` T.pack "alice@bank"
