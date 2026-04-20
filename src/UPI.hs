module UPI
  ( DebitLeg(..)
  , CreditLeg(..)
  , validateVPA
  , validateMPIN
  , hashMPIN
  , authenticateMPIN
  , debitCreditPair
  ) where

import Data.Hashable (hash)
import Data.Text (Text)
import qualified Data.Text as T
import Types (Amount(..), MPIN(..), TxnError(..), VPA(..))

data DebitLeg = DebitLeg
  { debitFrom :: VPA
  , debitAmount :: Amount
  } deriving (Eq, Show)

data CreditLeg = CreditLeg
  { creditTo :: VPA
  , creditAmount :: Amount
  } deriving (Eq, Show)

-- | Validate a virtual payment address in the form localpart@handle.
validateVPA :: VPA -> Either TxnError VPA
validateVPA vpa@(VPA raw)
  | T.null local = Left InvalidVPA
  | T.null handle = Left InvalidVPA
  | T.count (T.pack "@") raw /= 1 = Left InvalidVPA
  | otherwise = Right vpa
  where
    parts = T.splitOn (T.pack "@") raw
    (local, handle) =
      case parts of
        [l, h] -> (l, h)
        _ -> (T.empty, T.empty)

-- | Validate that MPIN is 4 to 6 numeric digits.
validateMPIN :: MPIN -> Either TxnError MPIN
validateMPIN mpin@(MPIN raw)
  | T.length raw < 4 = Left InvalidMPINFormat
  | T.length raw > 6 = Left InvalidMPINFormat
  | T.all isDigitChar raw = Right mpin
  | otherwise = Left InvalidMPINFormat
  where
    isDigitChar :: Char -> Bool
    isDigitChar c = c >= '0' && c <= '9'

-- | Hash an MPIN to simulate secure comparison.
hashMPIN :: MPIN -> Int
hashMPIN (MPIN raw) = hash (T.unpack raw)

-- | Authenticate a provided MPIN against a stored MPIN hash.
authenticateMPIN :: MPIN -> MPIN -> Either TxnError ()
authenticateMPIN provided stored =
  case validateMPIN provided of
    Left err -> Left err
    Right _ ->
      if hashMPIN provided == hashMPIN stored
        then Right ()
        else Left AuthenticationFailed

-- | Build matching debit and credit legs for settlement.
debitCreditPair :: VPA -> VPA -> Amount -> Either TxnError (DebitLeg, CreditLeg)
debitCreditPair fromVPA toVPA amount@(Amount value)
  | value <= 0 = Left InvalidAmount
  | otherwise =
      case (validateVPA fromVPA, validateVPA toVPA) of
        (Right validFrom, Right validTo) ->
          Right
            ( DebitLeg { debitFrom = validFrom, debitAmount = amount }
            , CreditLeg { creditTo = validTo, creditAmount = amount }
            )
        (Left err, _) -> Left err
        (_, Left err) -> Left err
module UPI
  ( DebitLeg(..)
  , CreditLeg(..)
  , validateVPA
  , validateMPIN
  , hashMPIN
  , authenticateMPIN
  , debitCreditPair
  ) where

import Data.Hashable (hash)
import Data.Text (Text)
import qualified Data.Text as T
import Types (Amount(..), MPIN(..), TxnError(..), VPA(..))

data DebitLeg = DebitLeg
  { debitFrom :: VPA
  , debitAmount :: Amount
  } deriving (Eq, Show)

data CreditLeg = CreditLeg
  { creditTo :: VPA
  , creditAmount :: Amount
  } deriving (Eq, Show)

-- | Validate a virtual payment address in the form localpart@handle.
validateVPA :: VPA -> Either TxnError VPA
validateVPA vpa@(VPA raw)
  | T.null local = Left InvalidVPA
  | T.null handle = Left InvalidVPA
  | T.count (T.pack "@") raw /= 1 = Left InvalidVPA
  | otherwise = Right vpa
  where
    parts = T.splitOn (T.pack "@") raw
    (local, handle) =
      case parts of
        [l, h] -> (l, h)
        _ -> (T.empty, T.empty)

-- | Validate that MPIN is 4 to 6 numeric digits.
validateMPIN :: MPIN -> Either TxnError MPIN
validateMPIN mpin@(MPIN raw)
  | T.length raw < 4 = Left InvalidMPINFormat
  | T.length raw > 6 = Left InvalidMPINFormat
  | T.all isDigitChar raw = Right mpin
  | otherwise = Left InvalidMPINFormat
  where
    isDigitChar :: Char -> Bool
    isDigitChar c = c >= '0' && c <= '9'

-- | Hash an MPIN to simulate secure comparison.
hashMPIN :: MPIN -> Int
hashMPIN (MPIN raw) = hash (T.unpack raw)

-- | Authenticate a provided MPIN against a stored MPIN hash.
authenticateMPIN :: MPIN -> MPIN -> Either TxnError ()
authenticateMPIN provided stored =
  case validateMPIN provided of
    Left err -> Left err
    Right _ ->
      if hashMPIN provided == hashMPIN stored
        then Right ()
        else Left AuthenticationFailed

-- | Build matching debit and credit legs for settlement.
debitCreditPair :: VPA -> VPA -> Amount -> Either TxnError (DebitLeg, CreditLeg)
debitCreditPair fromVPA toVPA amount@(Amount value)
  | value <= 0 = Left InvalidAmount
  | otherwise =
      case (validateVPA fromVPA, validateVPA toVPA) of
        (Right validFrom, Right validTo) ->
          Right
            ( DebitLeg { debitFrom = validFrom, debitAmount = amount }
            , CreditLeg { creditTo = validTo, creditAmount = amount }
            )
        (Left err, _) -> Left err
        (_, Left err) -> Left err
