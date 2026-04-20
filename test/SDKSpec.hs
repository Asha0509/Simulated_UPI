module SDKSpec (spec) where

import SDK (authenticate, initiate, settle)
import Test.Hspec (Spec, describe, it, shouldBe)
import Types (Amount(..), MPIN(..), Receipt(..), TxnError(..), TxnState(..), VPA(..))
import qualified Data.Text as T

spec :: Spec
spec =
  describe "SDK flow" $ do
    it "runs initiate -> authenticate -> settle successfully" $ do
      initResult <- initiate (VPA (T.pack "merchant@bank")) (Amount 250)
      case initResult of
        Left err -> err `shouldBe` InvalidAmount
        Right txnId -> do
          authResult <- authenticate txnId (MPIN (T.pack "1234"))
          authResult `shouldBe` Right txnId
          settleResult <- settle txnId
          case settleResult of
            Left _ -> False `shouldBe` True
            Right receipt -> receiptFinalState receipt `shouldBe` Settled

    it "fails authentication with wrong MPIN" $ do
      initResult <- initiate (VPA (T.pack "merchant2@bank")) (Amount 100)
      case initResult of
        Left _ -> False `shouldBe` True
        Right txnId -> do
          authResult <- authenticate txnId (MPIN (T.pack "9999"))
          authResult `shouldBe` Left AuthenticationFailed
module SDKSpec (spec) where

import SDK (authenticate, initiate, settle)
import Test.Hspec (Spec, describe, it, shouldBe)
import Types (Amount(..), MPIN(..), Receipt(..), TxnError(..), TxnState(..), VPA(..))
import qualified Data.Text as T

spec :: Spec
spec =
  describe "SDK flow" $ do
    it "runs initiate -> authenticate -> settle successfully" $ do
      initResult <- initiate (VPA (T.pack "merchant@bank")) (Amount 250)
      case initResult of
        Left err -> err `shouldBe` InvalidAmount
        Right txnId -> do
          authResult <- authenticate txnId (MPIN (T.pack "1234"))
          authResult `shouldBe` Right txnId
          settleResult <- settle txnId
          case settleResult of
            Left _ -> False `shouldBe` True
            Right receipt -> receiptFinalState receipt `shouldBe` Settled

    it "fails authentication with wrong MPIN" $ do
      initResult <- initiate (VPA (T.pack "merchant2@bank")) (Amount 100)
      case initResult of
        Left _ -> False `shouldBe` True
        Right txnId -> do
          authResult <- authenticate txnId (MPIN (T.pack "9999"))
          authResult `shouldBe` Left AuthenticationFailed
