module Reconciliation
  ( reconcileReceipts
  ) where

import qualified Data.Map.Strict as Map
import Types (Amount(..), Receipt(..), ReconciliationReport(..), TxnId, TxnState(..))

-- | Compute totals, net settled amount, and duplicate transaction IDs.
reconcileReceipts :: [Receipt] -> ReconciliationReport
reconcileReceipts receipts =
  ReconciliationReport
    { totalSettled = settledCount
    , totalFailed = failedCount
    , netAmount = Amount settledAmount
    , duplicates = duplicateTxnIds
    }
  where
    settledCount = length [r | r <- receipts, receiptFinalState r == Settled]
    failedCount = length [r | r <- receipts, receiptFinalState r == Failed]
    settledAmount = sum [unAmount (receiptAmount r) | r <- receipts, receiptFinalState r == Settled]
    idCounts = foldr countTxnId Map.empty receipts
    duplicateTxnIds = Map.keys (Map.filter (> 1) idCounts)

    countTxnId :: Receipt -> Map.Map TxnId Int -> Map.Map TxnId Int
    countTxnId receipt = Map.insertWith (+) (receiptTxnId receipt) 1
