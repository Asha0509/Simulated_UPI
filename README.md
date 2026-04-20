# Simulated UPI Payment SDK

A pure Haskell SDK that simulates a UPI payment lifecycle: initiate -> authenticate -> settle -> reconcile.

This project is intentionally designed with:
- Pure business logic in domain modules
- Explicit error handling with `Either TxnError a`
- A single IO boundary in `SDK` for in-memory state
- Deterministic behavior suitable for tests and interviews

## 1) Project Goal

The SDK models core UPI payment behavior without networking or databases.
It demonstrates how to design a clear, testable payment flow using functional patterns.

## 2) Tech Stack

- Language: Haskell (GHC 9.6.5)
- Build tool: Stack
- Testing: Hspec
- Key libraries: `text`, `hashable`, `containers`

## 3) Project Structure

```text
.
|- src/
|  |- Types.hs
|  |- Transaction.hs
|  |- UPI.hs
|  |- Reconciliation.hs
|  |- SDK.hs
|- test/
|  |- TypesSpec.hs
|  |- TransactionSpec.hs
|  |- UPISpec.hs
|  |- ReconciliationSpec.hs
|  |- SDKSpec.hs
|  |- Spec.hs
|- upi-payment-sdk.cabal
|- stack.yaml
```

## 4) Core Modules and Responsibilities

### `Types`
- Defines domain wrappers and records:
	- `VPA`, `Amount`, `TxnId`, `MPIN`
	- `TxnError`
	- `TxnState`
	- `Receipt`
	- `ReconciliationReport`

### `Transaction`
- Implements transaction state transitions using `TxnEvent`.
- Enforces valid state progression.

### `UPI`
- Validates VPA format (`localpart@handle`).
- Validates MPIN rules (4 to 6 numeric digits).
- Simulates MPIN hashing and comparison.
- Builds debit-credit settlement legs.

### `Reconciliation`
- Aggregates receipts into:
	- settled count
	- failed count
	- net settled amount
	- duplicate transaction IDs

### `SDK`
- Public API and only IO boundary.
- Manages transaction records in memory (`IORef`).
- Exposes:
	- `initiate`
	- `authenticate`
	- `settle`
	- `reconcile`

## 5) End-to-End Process and Procedure

This is the exact business flow implemented by the SDK.

### Step 1: Initiate Transaction
1. Client calls `initiate toVPA amount`.
2. SDK validates `amount > 0`.
3. SDK validates destination VPA and payer VPA.
4. SDK creates a new `TxnId` and stores record with state `Initiated`.

Expected output:
- `Right txnId` on success
- `Left InvalidAmount` or `Left InvalidVPA` on validation failure

### Step 2: Authenticate Transaction
1. Client calls `authenticate txnId mpin`.
2. SDK checks transaction exists.
3. MPIN is validated and compared against stored MPIN hash.
4. On success: state becomes `Authenticated`.
5. On auth failure: transaction is marked `Failed`.

Expected output:
- `Right txnId` on successful authentication
- `Left AuthenticationFailed` for wrong MPIN
- `Left TransactionNotFound` for unknown ID

### Step 3: Settle Transaction
1. Client calls `settle txnId`.
2. SDK checks the transaction exists and is in a valid state.
3. SDK transitions state to `Settled`.
4. SDK generates a `Receipt` with timestamp and final state.

Expected output:
- `Right receipt` on success
- `Left InvalidTransition` for invalid state transitions
- `Left TransactionNotFound` for unknown ID

### Step 4: Reconcile Receipts
1. Client collects multiple receipts.
2. Calls `reconcile receipts`.
3. SDK returns summary report including duplicate IDs.

Expected output:
- `ReconciliationReport` with totals and duplicate detection

## 6) State Machine

Valid transitions:

```text
Initiated --MarkAuthenticated--> Authenticated
Initiated --MarkFailed---------> Failed
Authenticated --MarkSettled----> Settled
Authenticated --MarkFailed-----> Failed
Settled/Failed --any event-----> InvalidTransition
```

## 7) Error Handling Strategy

The project uses explicit return types for all business outcomes:

- No exceptions in core business logic
- Every invalid case is represented as `TxnError`
- Callers must handle success and failure branches

This improves predictability and testability.

## 8) How to Run

### Prerequisite
- Stack installed and available in terminal

### Build

```bash
stack build
```

### Run Tests

```bash
stack test
```

Current expected test status:
- 14 examples
- 0 failures

## 9) Usage Example

```haskell
import qualified Data.Text as T
import SDK (initiate, authenticate, settle, reconcile)
import Types (Amount(..), MPIN(..), VPA(..), Receipt)

demo :: IO ()
demo = do
	started <- initiate (VPA (T.pack "merchant@bank")) (Amount 250)
	case started of
		Left err -> print err
		Right txnId -> do
			auth <- authenticate txnId (MPIN (T.pack "1234"))
			case auth of
				Left err -> print err
				Right _ -> do
					done <- settle txnId
					case done of
						Left err -> print err
						Right receipt -> do
							let report = reconcile [receipt]
							print report
```

## 10) Why This Design

- Simple to understand and debug
- Good separation between pure logic and stateful orchestration
- Easy to extend for retries, refunds, timeout handling, and persistence
- Strongly typed domain model reduces invalid states

## 11) Future Enhancements

- Persistent storage (SQLite/Postgres)
- Real cryptographic MPIN hashing
- API layer (Servant/Scotty)
- Idempotency keys for duplicate-safe requests
- Concurrency and race-condition safeguards

## 12) Sample Output (O/P)

### `stack test` output

```text
Types
	wraps Amount and exposes integer payload [v]
	supports TxnState equality checks [v]
	wraps VPA text [v]
Transaction.transition
	moves Initiated to Authenticated [v]
	moves Authenticated to Settled [v]
	rejects transitions from Failed [v]
UPI helpers
	validates a proper VPA [v]
	rejects malformed VPA [v]
	accepts a valid MPIN [v]
	rejects wrong MPIN against stored MPIN [v]
	pairs debit and credit legs for positive amount [v]
Reconciliation.reconcileReceipts
	computes settled, failed, net amount, and duplicate IDs [v]
SDK flow
	runs initiate -> authenticate -> settle successfully [v]
	fails authentication with wrong MPIN [v]

Finished in 0.0249 seconds
14 examples, 0 failures
```

### `git push origin main` output

```text
To https://github.com/Asha0509/Simulated_UPI.git
	 <old_commit>..<new_commit>  main -> main
```