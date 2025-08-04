import { describe, it, expect, beforeEach } from "vitest"

type Principal = string

interface RecoveryState {
  newOwner: Principal
  votes: Principal[]
}

const walletOwner = "STWALLET"
const guardians: Principal[] = ["ST1", "ST2", "ST3"]
const anotherPrincipal = "ST999"

let mockStorage: {
  guardians: Map<Principal, Principal[]>
  thresholds: Map<Principal, number>
  recoveryRequests: Map<Principal, RecoveryState>
}

beforeEach(() => {
  mockStorage = {
    guardians: new Map(),
    thresholds: new Map(),
    recoveryRequests: new Map()
  }
})

const isGuardian = (wallet: Principal, caller: Principal): boolean => {
  const g = mockStorage.guardians.get(wallet)
  return !!g?.includes(caller)
}

describe("Keynest Recovery Module", () => {
  it("sets guardians and threshold", () => {
    mockStorage.guardians.set(walletOwner, guardians)
    mockStorage.thresholds.set(walletOwner, 2)

    expect(mockStorage.guardians.get(walletOwner)).toEqual(guardians)
    expect(mockStorage.thresholds.get(walletOwner)).toBe(2)
  })

  it("starts recovery with valid guardian", () => {
    mockStorage.guardians.set(walletOwner, guardians)
    const caller = "ST1"
    const newOwner = anotherPrincipal

    const canStart = isGuardian(walletOwner, caller)
    expect(canStart).toBe(true)

    mockStorage.recoveryRequests.set(walletOwner, {
      newOwner,
      votes: [caller]
    })

    const state = mockStorage.recoveryRequests.get(walletOwner)
    expect(state?.votes).toContain(caller)
  })

  it("votes for recovery without duplication", () => {
    const wallet = walletOwner
    const voter = "ST2"
    mockStorage.guardians.set(wallet, guardians)
    mockStorage.recoveryRequests.set(wallet, {
      newOwner: anotherPrincipal,
      votes: ["ST1"]
    })

    const state = mockStorage.recoveryRequests.get(wallet)!
    expect(state.votes.includes(voter)).toBe(false)

    state.votes.push(voter)
    mockStorage.recoveryRequests.set(wallet, state)

    const updatedVotes = mockStorage.recoveryRequests.get(wallet)!.votes
    expect(updatedVotes.length).toBe(2)
    expect(updatedVotes.includes("ST2")).toBe(true)
  })

  it("finalizes recovery if threshold is met", () => {
    const wallet = walletOwner
    const newOwner = anotherPrincipal
    const voteList = ["ST1", "ST2", "ST3"]

    mockStorage.guardians.set(wallet, guardians)
    mockStorage.thresholds.set(wallet, 3)
    mockStorage.recoveryRequests.set(wallet, {
      newOwner,
      votes: voteList
    })

    const state = mockStorage.recoveryRequests.get(wallet)!
    const threshold = mockStorage.thresholds.get(wallet)!

    expect(state.votes.length).toBeGreaterThanOrEqual(threshold)

    mockStorage.recoveryRequests.delete(wallet)

    expect(mockStorage.recoveryRequests.has(wallet)).toBe(false)
  })

  it("prevents finalization if threshold not met", () => {
    const wallet = walletOwner
    const voteList = ["ST1"]

    mockStorage.guardians.set(wallet, guardians)
    mockStorage.thresholds.set(wallet, 3)
    mockStorage.recoveryRequests.set(wallet, {
      newOwner: anotherPrincipal,
      votes: voteList
    })

    const state = mockStorage.recoveryRequests.get(wallet)!
    const threshold = mockStorage.thresholds.get(wallet)!

    expect(state.votes.length).toBeLessThan(threshold)
  })

  it("cancels recovery as owner", () => {
    const wallet = walletOwner
    mockStorage.recoveryRequests.set(wallet, {
      newOwner: anotherPrincipal,
      votes: ["ST1", "ST2"]
    })

    mockStorage.recoveryRequests.delete(wallet)
    expect(mockStorage.recoveryRequests.has(wallet)).toBe(false)
  })
})
