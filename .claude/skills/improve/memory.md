# Lessons from improve

Written by /distill from improve's verdicts. Numbers are permanent.

1. When an install recipe takes a tool at latest (`@latest` or a plain `brew install`) and nothing fails today, do not pitch pinning it. Committing a lockfile the package manager already writes is a different case.
   - Scope: all repos
   - Evidence: bip-0039 2026-11-14 "install leaves tparse unpinned"; bip-0039 2026-11-05 "Go toolchain unpinned against golangci-lint pin"; macros 2026-11-15 "Unpinned protoc-gen-go"
2. When code implements a named textbook algorithm, do not pitch a property of the algorithm itself, such as its worst-case complexity or an in-place step that consumes its input. An implementation bug, a departure from the standard form, or a doc comment that misstates it is still fair.
   - Scope: algo-java
   - Evidence: algo-java 2026-11-15 "Heap is unusable after sort()"; algo-java 2026-11-08 "QuickSort degrades on duplicates"
3. When the repo's docs make a manual step a written rule (rerun a tool, edit a file by hand), do not pitch a generator or recorded digest to automate it. A test that reads the existing files is still fair.
   - Scope: uav-missions
   - Evidence: uav-missions 2026-11-18 "A changed `.pm` does not flag stale PRISM data"; uav-missions 2026-11-18 "Generate the comparison table instead of editing it by hand"
