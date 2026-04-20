module Transaction
  ( TxnEvent(..)
  , transition
  ) where

import Types (TxnError(..), TxnState(..))

data TxnEvent
  = MarkAuthenticated
  | MarkSettled
  | MarkFailed
  deriving (Eq, Show)

-- | Transition a transaction state with an event.
transition :: TxnState -> TxnEvent -> Either TxnError TxnState
transition Initiated MarkAuthenticated = Right Authenticated
transition Authenticated MarkSettled = Right Settled
transition Initiated MarkFailed = Right Failed
transition Authenticated MarkFailed = Right Failed
transition Settled _ = Left InvalidTransition
transition Failed _ = Left InvalidTransition
transition _ _ = Left InvalidTransition
module Transaction
  ( TxnEvent(..)
  , transition
  ) where

import Types (TxnError(..), TxnState(..))

data TxnEvent
  = MarkAuthenticated
  | MarkSettled
  | MarkFailed
  deriving (Eq, Show)

-- | Transition a transaction state with an event.
transition :: TxnState -> TxnEvent -> Either TxnError TxnState
transition Initiated MarkAuthenticated = Right Authenticated
transition Authenticated MarkSettled = Right Settled
transition Initiated MarkFailed = Right Failed
transition Authenticated MarkFailed = Right Failed
transition Settled _ = Left InvalidTransition
transition Failed _ = Left InvalidTransition
transition _ _ = Left InvalidTransition
