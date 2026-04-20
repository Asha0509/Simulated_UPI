module UPISpec (spec) where

import Test.Hspec (Spec, describe, it, shouldBe)
import Types (Amount(..), MPIN(..), TxnError(..), VPA(..))
import UPI (authenticateMPIN, debitCreditPair, validateMPIN, validateVPA)
import qualified Data.Text as T

spec :: Spec
spec =
  describe "UPI helpers" $ do
    it "validates a proper VPA" $ do
      validateVPA (VPA (T.pack "alice@bank")) `shouldBe` Right (VPA (T.pack "alice@bank"))

    it "rejects malformed VPA" $ do
      validateVPA (VPA (T.pack "alicebank")) `shouldBe` Left InvalidVPA

    it "accepts a valid MPIN" $ do
      validateMPIN (MPIN (T.pack "1234")) `shouldBe` Right (MPIN (T.pack "1234"))

    it "rejects wrong MPIN against stored MPIN" $ do
      authenticateMPIN (MPIN (T.pack "1111")) (MPIN (T.pack "1234")) `shouldBe` Left AuthenticationFailed

    it "pairs debit and credit legs for positive amount" $ do
      case debitCreditPair (VPA (T.pack "payer@bank")) (VPA (T.pack "payee@bank")) (Amount 100) of
        Left _ -> False `shouldBe` True
        Right _ -> True `shouldBe` True
module UPISpec (spec) where

import Test.Hspec (Spec, describe, it, shouldBe)
import Types (Amount(..), MPIN(..), TxnError(..), VPA(..))
import UPI (authenticateMPIN, debitCreditPair, validateMPIN, validateVPA)
import qualified Data.Text as T

spec :: Spec
spec =
  describe "UPI helpers" $ do
    it "validates a proper VPA" $ do
      validateVPA (VPA (T.pack "alice@bank")) `shouldBe` Right (VPA (T.pack "alice@bank"))

    it "rejects malformed VPA" $ do
      validateVPA (VPA (T.pack "alicebank")) `shouldBe` Left InvalidVPA

    it "accepts a valid MPIN" $ do
      validateMPIN (MPIN (T.pack "1234")) `shouldBe` Right (MPIN (T.pack "1234"))

    it "rejects wrong MPIN against stored MPIN" $ do
      authenticateMPIN (MPIN (T.pack "1111")) (MPIN (T.pack "1234")) `shouldBe` Left AuthenticationFailed

    it "pairs debit and credit legs for positive amount" $ do
      case debitCreditPair (VPA (T.pack "payer@bank")) (VPA (T.pack "payee@bank")) (Amount 100) of
        Left _ -> False `shouldBe` True
        Right _ -> True `shouldBe` True
