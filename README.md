Rotating Leadership DAO
Overview

The Rotating Leadership DAO is a decentralized governance smart contract that allows a leadership token to rotate among members of the DAO at a fixed interval of blockchain blocks. The contract ensures that leadership is distributed among registered members in a deterministic, transparent, and auditable way.

The DAO supports:

Adding and removing members by the current leader.

Automatic leadership rotation based on block height.

Force-rotation capability for immediate leadership changes.

Proposal voting infrastructure (prepared for extension).

This contract is built using Clarity, the smart contract language for the Stacks blockchain.

Key Features

Leadership Rotation

Leadership rotates to the next member in a round-robin fashion every BLOCKS-PER-ROTATION blocks (~24 hours with 10-minute blocks).

The rotation index tracks which member is next in line.

Member Management

Only the current leader can add or remove members.

Duplicate membership is prevented.

Membership is stored in a mapping (members) and an ordered member-list.

Access Control

Only the current leader has the authority to modify membership or force a leadership rotation.

All unauthorized actions return appropriate error codes.

Read-Only Queries

get-current-leader: Returns the current leader.

get-blocks-until-rotation: Returns the number of blocks remaining until the next rotation.

is-member: Checks if an account is a member.

get-member-count: Returns total number of members.

is-rotation-due: Checks if rotation is required.

get-next-leader: Returns who will be the next leader when rotation occurs.

Voting Infrastructure (Optional Extension)

Structures for proposals and voting are defined (proposal-votes, voter-record) for future DAO governance features.

Contract Constants
Constant	Description
ERR-NOT-AUTHORIZED	Error for unauthorized actions.
ERR-ALREADY-MEMBER	Error when adding an existing member.
ERR-NOT-MEMBER	Error when removing a non-member.
ERR-NO-MEMBERS	Error when no members exist for rotation.
ERR-INVALID-ROTATION	Error when rotation is attempted too early.
CONTRACT-OWNER	The deploying account (initial leader).
BLOCKS-PER-ROTATION	Number of blocks per rotation (~144 blocks).
Contract Variables

current-leader: Tracks the current leader’s principal.

last-rotation-block: Block height of the last rotation.

member-count: Total number of members.

rotation-index: Index of the next leader in member-list.

Public Functions

Membership Management

add-member(new-member: principal): Add a new member (leader only).

remove-member(member: principal): Remove an existing member (leader only).

Leadership Rotation

rotate-leadership(): Rotates the leadership if rotation interval has passed.

force-rotate(): Forces a leadership rotation by adjusting the last rotation block (leader only).

Private Functions

is-leader(account: principal): Checks if a given account is the current leader.

Usage Example
;; Check current leader
(get-current-leader)

;; Add a new member
(add-member 'ST3CKS1MEMBER1234567890)

;; Rotate leadership if due
(rotate-leadership)

;; Force rotation
(force-rotate)

Initialization

The contract deployer is automatically set as the initial leader.

Member count and member list are initialized with the deployer as the first member.

Error Codes
Error	Description
u100	Not authorized.
u101	Member already exists.
u102	Account is not a member.
u103	No members available.
u104	Rotation attempted before the required block interval.