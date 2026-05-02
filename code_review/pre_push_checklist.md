# Pre-Push Checklist

> Open this before you click push. Not after.

---

## 1. Re-read the spec

- [ ] Read every requirement **word for word** — not diagonally
- [ ] Check previous review carryovers — is every pending fix actually applied?

## 2. Re-read your code

- [ ] Read every modified file **line by line** — you are actively looking for problems
- [ ] Remove everything vestigial: commented-out code, test lines, accidental paste fragments
- [ ] Check internal consistency: ports, variable names, constants — do they match across all files?

## 3. If you used an LLM to generate code

- [ ] You can explain every non-trivial block out loud
- [ ] You asked at least one "why" question and tested one assumption by changing a value and observing what happens

## 4. Final check

- [ ] Read your full diff once — everything the reviewer will see, you saw first

---

*If you can't check a box honestly, you're not done.*