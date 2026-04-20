module TransactionSpec (spec) where

import Test.Hspec (Spec, describe, it, shouldBe)
import Transaction (TxnEvent(..), transition)
import Types (TxnError(..), TxnState(..))

spec :: Spec
spec =
  describe "Transaction.transition" $ do
    it "moves Initiated to Authenticated" $ do
      transition Initiated MarkAuthenticated `shouldBe` Right Authenticated

    it "moves Authenticated to Settled" $ do
      transition Authenticated MarkSettled `shouldBe` Right Settled

    it "rejects transitions from Failed" $ do
      transition Failed MarkSettled `shouldBe` Left InvalidTransition
