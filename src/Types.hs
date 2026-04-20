module Types
  ( VPA(..)
  , Amount(..)
  , TxnId(..)
  , MPIN(..)
  , TxnError(..)
  , TxnState(..)
  , Receipt(..)
  , ReconciliationReport(..)
  ) where

import Data.Text (Text)

newtype VPA = VPA { unVPA :: Text }
  deriving (Eq, Ord, Show)

newtype Amount = Amount { unAmount :: Int }
  deriving (Eq, Ord, Show)

newtype TxnId = TxnId { unTxnId :: Text }
  deriving (Eq, Ord, Show)

newtype MPIN = MPIN { unMPIN :: Text }
  deriving (Eq, Ord, Show)

data TxnError
  = InvalidVPA
  | InvalidAmount
  | InvalidMPINFormat
  | AuthenticationFailed
  | TransactionNotFound
  | InvalidTransition
  deriving (Eq, Show)

data TxnState
  = Initiated
  | Authenticated
  | Settled
  | Failed
  deriving (Eq, Show)

data Receipt = Receipt
  { receiptTxnId :: TxnId
  , receiptAmount :: Amount
  , receiptFromVPA :: VPA
  , receiptToVPA :: VPA
  , receiptFinalState :: TxnState
  , receiptTimestamp :: Int
  } deriving (Eq, Show)

data ReconciliationReport = ReconciliationReport
  { totalSettled :: Int
  , totalFailed :: Int
  , netAmount :: Amount
  , duplicates :: [TxnId]
  } deriving (Eq, Show)
