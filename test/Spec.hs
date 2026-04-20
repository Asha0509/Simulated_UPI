module Main (main) where

import qualified ReconciliationSpec
import qualified SDKSpec
import qualified TransactionSpec
import qualified TypesSpec
import qualified UPISpec
import Test.Hspec (hspec)

main :: IO ()
main = hspec $ do
  TypesSpec.spec
  TransactionSpec.spec
  UPISpec.spec
  ReconciliationSpec.spec
  SDKSpec.spec
module Main (main) where

import qualified ReconciliationSpec
import qualified SDKSpec
import qualified TransactionSpec
import qualified TypesSpec
import qualified UPISpec
import Test.Hspec (hspec)

main :: IO ()
main = hspec $ do
  TypesSpec.spec
  TransactionSpec.spec
  UPISpec.spec
  ReconciliationSpec.spec
  SDKSpec.spec
