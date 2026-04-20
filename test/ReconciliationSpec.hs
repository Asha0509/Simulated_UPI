module ReconciliationSpec (spec) where

import Reconciliation (reconcileReceipts)
import Test.Hspec (Spec, describe, it, shouldBe)
import Types
  ( Amount(..)
  , Receipt(..)
  , ReconciliationReport(..)
  , TxnId(..)
  , TxnState(..)
  , VPA(..)
  )
import qualified Data.Text as T

spec :: Spec
spec =
  describe "Reconciliation.reconcileReceipts" $ do
    it "computes settled, failed, net amount, and duplicate IDs" $ do
      let id1 = TxnId (T.pack "TXN-1")
          id2 = TxnId (T.pack "TXN-2")
          fromV = VPA (T.pack "payer@bank")
          toV = VPA (T.pack "payee@bank")
          receipts =
            [ Receipt id1 (Amount 200) fromV toV Settled 1
            , Receipt id2 (Amount 50) fromV toV Failed 2
            , Receipt id1 (Amount 200) fromV toV Settled 3
            ]
          report = reconcileReceipts receipts
      totalSettled report `shouldBe` 2
      totalFailed report `shouldBe` 1
      netAmount report `shouldBe` Amount 400
      duplicates report `shouldBe` [id1]
module ReconciliationSpec (spec) where

import Reconciliation (reconcileReceipts)
import Test.Hspec (Spec, describe, it, shouldBe)
import Types
  ( Amount(..)
  , Receipt(..)
  , ReconciliationReport(..)
  , TxnId(..)
  , TxnState(..)
  , VPA(..)
  )
import qualified Data.Text as T

spec :: Spec
spec =
  describe "Reconciliation.reconcileReceipts" $ do
    it "computes settled, failed, net amount, and duplicate IDs" $ do
      let id1 = TxnId (T.pack "TXN-1")
          id2 = TxnId (T.pack "TXN-2")
          fromV = VPA (T.pack "payer@bank")
          toV = VPA (T.pack "payee@bank")
          receipts =
            [ Receipt id1 (Amount 200) fromV toV Settled 1
            , Receipt id2 (Amount 50) fromV toV Failed 2
            , Receipt id1 (Amount 200) fromV toV Settled 3
            ]
          report = reconcileReceipts receipts
      totalSettled report `shouldBe` 2
      totalFailed report `shouldBe` 1
      netAmount report `shouldBe` Amount 400
      duplicates report `shouldBe` [id1]
