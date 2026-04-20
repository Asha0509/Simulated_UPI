module SDK
  ( initiate
  , authenticate
  , settle
  , reconcile
  ) where

import Data.IORef (IORef, atomicModifyIORef', newIORef)
import qualified Data.Map.Strict as Map
import Data.Text (Text)
import qualified Data.Text as T
import System.IO.Unsafe (unsafePerformIO)
import Reconciliation (reconcileReceipts)
import Transaction (TxnEvent(..), transition)
import Types
  ( Amount(..)
  , MPIN(..)
  , Receipt(..)
  , ReconciliationReport
  , TxnError(..)
  , TxnId(..)
  , TxnState(..)
  , VPA(..)
  )
import UPI (authenticateMPIN, debitCreditPair, validateVPA)

data TxnRecord = TxnRecord
  { recordId :: TxnId
  , recordFromVPA :: VPA
  , recordToVPA :: VPA
  , recordAmount :: Amount
  , recordState :: TxnState
  } deriving (Eq, Show)

data SDKState = SDKState
  { nextTxnSeq :: Int
  , nextTimestamp :: Int
  , txns :: Map.Map TxnId TxnRecord
  } deriving (Eq, Show)

sdkStateRef :: IORef SDKState
sdkStateRef = unsafePerformIO (newIORef emptyState)
{-# NOINLINE sdkStateRef #-}

emptyState :: SDKState
emptyState = SDKState
  { nextTxnSeq = 1
  , nextTimestamp = 1
  , txns = Map.empty
  }

payerVPA :: VPA
payerVPA = VPA (T.pack "payer@bank")

storedMPIN :: MPIN
storedMPIN = MPIN (T.pack "1234")

mkTxnId :: Int -> TxnId
mkTxnId seqNum = TxnId (T.pack ("TXN-" <> show seqNum))

-- | Initiate a transaction for a destination VPA and amount.
initiate :: VPA -> Amount -> IO (Either TxnError TxnId)
initiate toVPA amount@(Amount value)
  | value <= 0 = pure (Left InvalidAmount)
  | otherwise =
      case validateVPA toVPA of
        Left err -> pure (Left err)
        Right validTo ->
          case validateVPA payerVPA of
            Left err -> pure (Left err)
            Right validFrom -> do
              txnId <- atomicModifyIORef' sdkStateRef (insertTxn validFrom validTo amount)
              pure (Right txnId)

insertTxn :: VPA -> VPA -> Amount -> SDKState -> (SDKState, TxnId)
insertTxn fromVPA toVPA amount state0 =
  ( state0 { nextTxnSeq = seqNum + 1, txns = Map.insert txnId txnRecord (txns state0) }
  , txnId
  )
  where
    seqNum = nextTxnSeq state0
    txnId = mkTxnId seqNum
    txnRecord =
      TxnRecord
        { recordId = txnId
        , recordFromVPA = fromVPA
        , recordToVPA = toVPA
        , recordAmount = amount
        , recordState = Initiated
        }

-- | Authenticate a transaction using an MPIN.
authenticate :: TxnId -> MPIN -> IO (Either TxnError TxnId)
authenticate txnId mpin =
  atomicModifyIORef' sdkStateRef step
  where
    step state0 =
      case Map.lookup txnId (txns state0) of
        Nothing -> (state0, Left TransactionNotFound)
        Just rec ->
          case authenticateMPIN mpin storedMPIN of
            Left err ->
              let failedResult = setState txnId rec MarkFailed state0
              in case failedResult of
                   Left _ -> (state0, Left err)
                   Right state1 -> (state1, Left err)
            Right () ->
              case setState txnId rec MarkAuthenticated state0 of
                Left transErr -> (state0, Left transErr)
                Right state1 -> (state1, Right txnId)

setState :: TxnId -> TxnRecord -> TxnEvent -> SDKState -> Either TxnError SDKState
setState txnId rec event state0 =
  case transition (recordState rec) event of
    Left err -> Left err
    Right newState ->
      Right
        state0
          { txns = Map.insert txnId rec { recordState = newState } (txns state0)
          }

-- | Settle a transaction and return a final receipt.
settle :: TxnId -> IO (Either TxnError Receipt)
settle txnId =
  atomicModifyIORef' sdkStateRef step
  where
    step state0 =
      case Map.lookup txnId (txns state0) of
        Nothing -> (state0, Left TransactionNotFound)
        Just rec ->
          case transition (recordState rec) MarkSettled of
            Left err -> (state0, Left err)
            Right settledState ->
              case debitCreditPair (recordFromVPA rec) (recordToVPA rec) (recordAmount rec) of
                Left err ->
                  case setState txnId rec MarkFailed state0 of
                    Left _ -> (state0, Left err)
                    Right state1 -> (state1, Left err)
                Right _ ->
                  let ts = nextTimestamp state0
                      settledRecord = rec { recordState = settledState }
                      newState =
                        state0
                          { nextTimestamp = ts + 1
                          , txns = Map.insert txnId settledRecord (txns state0)
                          }
                      receipt =
                        Receipt
                          { receiptTxnId = recordId settledRecord
                          , receiptAmount = recordAmount settledRecord
                          , receiptFromVPA = recordFromVPA settledRecord
                          , receiptToVPA = recordToVPA settledRecord
                          , receiptFinalState = recordState settledRecord
                          , receiptTimestamp = ts
                          }
                  in (newState, Right receipt)

-- | Reconcile a list of receipts into totals and duplicates.
reconcile :: [Receipt] -> ReconciliationReport
reconcile = reconcileReceipts
module SDK
  ( initiate
  , authenticate
  , settle
  , reconcile
  ) where

import Data.IORef (IORef, atomicModifyIORef', newIORef)
import qualified Data.Map.Strict as Map
import Data.Text (Text)
import qualified Data.Text as T
import System.IO.Unsafe (unsafePerformIO)
import Reconciliation (reconcileReceipts)
import Transaction (TxnEvent(..), transition)
import Types
  ( Amount(..)
  , MPIN(..)
  , Receipt(..)
  , ReconciliationReport
  , TxnError(..)
  , TxnId(..)
  , TxnState(..)
  , VPA(..)
  )
import UPI (authenticateMPIN, debitCreditPair, validateVPA)

data TxnRecord = TxnRecord
  { recordId :: TxnId
  , recordFromVPA :: VPA
  , recordToVPA :: VPA
  , recordAmount :: Amount
  , recordState :: TxnState
  } deriving (Eq, Show)

data SDKState = SDKState
  { nextTxnSeq :: Int
  , nextTimestamp :: Int
  , txns :: Map.Map TxnId TxnRecord
  } deriving (Eq, Show)

sdkStateRef :: IORef SDKState
sdkStateRef = unsafePerformIO (newIORef emptyState)
{-# NOINLINE sdkStateRef #-}

emptyState :: SDKState
emptyState = SDKState
  { nextTxnSeq = 1
  , nextTimestamp = 1
  , txns = Map.empty
  }

payerVPA :: VPA
payerVPA = VPA (T.pack "payer@bank")

storedMPIN :: MPIN
storedMPIN = MPIN (T.pack "1234")

mkTxnId :: Int -> TxnId
mkTxnId seqNum = TxnId (T.pack ("TXN-" <> show seqNum))

-- | Initiate a transaction for a destination VPA and amount.
initiate :: VPA -> Amount -> IO (Either TxnError TxnId)
initiate toVPA amount@(Amount value)
  | value <= 0 = pure (Left InvalidAmount)
  | otherwise =
      case validateVPA toVPA of
        Left err -> pure (Left err)
        Right validTo ->
          case validateVPA payerVPA of
            Left err -> pure (Left err)
            Right validFrom -> do
              txnId <- atomicModifyIORef' sdkStateRef (insertTxn validFrom validTo amount)
              pure (Right txnId)

insertTxn :: VPA -> VPA -> Amount -> SDKState -> (SDKState, TxnId)
insertTxn fromVPA toVPA amount state0 =
  ( state0 { nextTxnSeq = seqNum + 1, txns = Map.insert txnId txnRecord (txns state0) }
  , txnId
  )
  where
    seqNum = nextTxnSeq state0
    txnId = mkTxnId seqNum
    txnRecord =
      TxnRecord
        { recordId = txnId
        , recordFromVPA = fromVPA
        , recordToVPA = toVPA
        , recordAmount = amount
        , recordState = Initiated
        }

-- | Authenticate a transaction using an MPIN.
authenticate :: TxnId -> MPIN -> IO (Either TxnError TxnId)
authenticate txnId mpin =
  atomicModifyIORef' sdkStateRef step
  where
    step state0 =
      case Map.lookup txnId (txns state0) of
        Nothing -> (state0, Left TransactionNotFound)
        Just rec ->
          case authenticateMPIN mpin storedMPIN of
            Left err ->
              let failedResult = setState txnId rec MarkFailed state0
              in case failedResult of
                   Left _ -> (state0, Left err)
                   Right state1 -> (state1, Left err)
            Right () ->
              case setState txnId rec MarkAuthenticated state0 of
                Left transErr -> (state0, Left transErr)
                Right state1 -> (state1, Right txnId)

setState :: TxnId -> TxnRecord -> TxnEvent -> SDKState -> Either TxnError SDKState
setState txnId rec event state0 =
  case transition (recordState rec) event of
    Left err -> Left err
    Right newState ->
      Right
        state0
          { txns = Map.insert txnId rec { recordState = newState } (txns state0)
          }

-- | Settle a transaction and return a final receipt.
settle :: TxnId -> IO (Either TxnError Receipt)
settle txnId =
  atomicModifyIORef' sdkStateRef step
  where
    step state0 =
      case Map.lookup txnId (txns state0) of
        Nothing -> (state0, Left TransactionNotFound)
        Just rec ->
          case transition (recordState rec) MarkSettled of
            Left err -> (state0, Left err)
            Right settledState ->
              case debitCreditPair (recordFromVPA rec) (recordToVPA rec) (recordAmount rec) of
                Left err ->
                  case setState txnId rec MarkFailed state0 of
                    Left _ -> (state0, Left err)
                    Right state1 -> (state1, Left err)
                Right _ ->
                  let ts = nextTimestamp state0
                      settledRecord = rec { recordState = settledState }
                      newState =
                        state0
                          { nextTimestamp = ts + 1
                          , txns = Map.insert txnId settledRecord (txns state0)
                          }
                      receipt =
                        Receipt
                          { receiptTxnId = recordId settledRecord
                          , receiptAmount = recordAmount settledRecord
                          , receiptFromVPA = recordFromVPA settledRecord
                          , receiptToVPA = recordToVPA settledRecord
                          , receiptFinalState = recordState settledRecord
                          , receiptTimestamp = ts
                          }
                  in (newState, Right receipt)

-- | Reconcile a list of receipts into totals and duplicates.
reconcile :: [Receipt] -> ReconciliationReport
reconcile = reconcileReceipts
