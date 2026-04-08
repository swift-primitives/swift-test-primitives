# Audit: swift-test-primitives

## Legacy — Consolidated 2026-04-08

### From: swift-institute/Research/audit-primitives.md (2026-04-03)

**Pre-publication dependency-tree audit — P0/P1/P2 checks**

#### P1: Compound Type Name [API-NAME-001]

**File**: `Sources/Test Snapshot Primitives/Test.Snapshot.Diff.Result.StructuralOperation.swift:26`

```swift
public enum StructuralOperation: Sendable, Hashable, Codable {
```

Full path is `Test.Snapshot.Diff.Result.StructuralOperation`. Should be `Structural.Operation` or `Structure.Operation`.

---

### From: swift-institute/Research/audits/implementation-naming-2026-03-20/swift-test-primitives.md (2026-03-20)

**Implementation + naming audit**

HIGH=0, MEDIUM=4, LOW=3, INFO=0
Finding IDs: IMPL-002, IMPL-010, PATTERN-017, PATTERN-021

| ID | Severity | Rule | File | Line | Description |
|----|----------|------|------|------|-------------|
| TEST-001 | MEDIUM | [IMPL-002] | Test.Issue.Kind.swift | 49 | `.rawValue` access on `Test.Expectation.ID` |
| TEST-002 | MEDIUM | [IMPL-002] | Test.Event.swift | 122 | `.rawValue` access on `Test.Case.ID` |
| TEST-003 | MEDIUM | [IMPL-002] | Test.Benchmark.Trend.swift | 29,42 | `.rawValue` on `Interpretation` struct |
| TEST-004 | LOW | [API-IMPL-005] | Test.Expression.Value.swift | 76-84 | `OptionalProtocol` helper protocol in same file as `Test.Expression.Value` |
| TEST-005 | LOW | [API-IMPL-005] | Test.Benchmark.Measurement.swift | 155-161 | `Sample.Metric` extension in same file as `Test.Benchmark.Measurement` |
| TEST-006 | LOW | [PATTERN-021] | Test.Benchmark.Complexity+evidence.swift | various | Raw `Int` and `Double` arithmetic (acceptable — pure math) |
| TEST-007 | MEDIUM | [API-NAME-002] | Test.Snapshot.Strategy+Description.swift | 70 | `dump` is a property name that mirrors stdlib function — borderline |
