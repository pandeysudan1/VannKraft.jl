# Git Commit Message Template

Use this as your commit message when you push to GitHub:

---

## Title (Keep under 72 characters)
```
refactor: Restructure VannKraft library with IOAPI module
```

## Body
```
Reorganize VannKraft into hierarchical module structure aligned with 
hydropower plant architecture. Add comprehensive IOAPI module with AGC/LFC 
control interfaces.

BREAKING CHANGE: None - all original exports maintained

FEATURES:
- Reorganize library into 4 main modules (Hydraulics, Electrical, 
  ControlSystem, IOAPI)
- Add IOAPI module with:
  * AGC (Automatic Generation Control) with PI control
  * LFC (Load Frequency Control) with ACE calculation
  * Setpoint manager with validation
  * Turbine control interface with ramp-rate limiting
  * System monitoring and statistics functions
  * Transient detection algorithm
- Add comprehensive test suite (50+ test cases)

CHANGES:
- Move hydraulic components to src/hydraulics/
- Move electrical components to src/electrical/
- Move control components to src/control_system/
- Update main VannKraft.jl to aggregate submodules
- Rewrite test/runtests.jl with comprehensive coverage
- Clean up Project.toml dependencies

TESTS:
- Module loading tests (4 test sets)
- Hydraulics component tests (6 tests)
- Electrical component tests (2 tests)
- Control system tests (2 tests)
- IOAPI functionality tests (38+ tests)
- Integration tests (3 tests)
- Total: 50+ test cases, all passing

DOCUMENTATION:
- Add comprehensive docstrings to all public APIs
- Create PR_DESCRIPTION.md with architecture overview
- Create COMMIT_CHECKLIST.md with PR verification
- Add inline usage examples

BACKWARD COMPATIBILITY:
✓ All original exports maintained via re-export
✓ Existing code continues to work unchanged
✓ New functionality available through IOAPI module

See PR_DESCRIPTION.md for detailed information.
```

---

## Quick Reference

### Before Committing
```bash
# 1. Verify tests pass
cd c:\Storage\Github\Packages\VannKraft
julia --project=. -e "using Pkg; Pkg.test()"

# 2. Verify validation script
julia --project=. test_validation.jl

# 3. Check git status
git status
```

### Commands to Execute
```bash
# Stage all changes
git add -A

# Commit with message
git commit -m "refactor: Restructure VannKraft library with IOAPI module" -m "Details..."

# Or use the template above for more detailed commit

# Push to branch
git push origin feature/library-restructuring
```

### Alternative: More Detailed Commit
If you want to include the full message, create a file `COMMIT_MSG.txt` with the content above and use:
```bash
git commit -F COMMIT_MSG.txt
```

---

## PR Title for GitHub
```
Refactor: Restructure VannKraft library with new IOAPI module

- Reorganize components into Hydraulics, Electrical, ControlSystem, IOAPI modules
- Add comprehensive AGC/LFC control interfaces
- 50+ unit tests for full coverage
- Backward compatible, all original exports maintained
```

## PR Description
Link to: `PR_DESCRIPTION.md` in the repository root

---

## Verification Checklist Before Push

- [ ] Tests pass: `julia --project=. -e "using Pkg; Pkg.test()"`
- [ ] Validation passes: `julia --project=. test_validation.jl`
- [ ] All files staged: `git add -A`
- [ ] Commit message is clear and detailed
- [ ] No sensitive information in commit
- [ ] Branch name is descriptive
- [ ] Documentation updated (PR_DESCRIPTION.md included)

---

## Sample Minimal Commit

```bash
git add -A

git commit -m "refactor: Restructure VannKraft with IOAPI module" \
  -m "- Organize into 4 hierarchical modules" \
  -m "- Add AGC/LFC control system interfaces" \
  -m "- Add 50+ unit tests" \
  -m "- Maintain backward compatibility" \
  -m "See PR_DESCRIPTION.md for details"

git push origin feature/library-restructuring
```

---

## After Push

1. Create pull request on GitHub
2. Add description from PR_DESCRIPTION.md
3. Reference related issues (if any)
4. Request reviewers
5. Wait for CI/CD to pass
6. Address review comments
7. Merge when approved

---

This is ready to go! 🚀
