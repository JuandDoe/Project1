# Review: Part 3 follow-up

You worked through the Part 3 review like a punch list and addressed every item, plus several things that were not on the list. The pre-push checklist you built is the most mature move you have made across this whole exercise. This note is short because most of what is here is praise. There is also one specific shift in framing worth talking about, and two small new issues that the shift would have caught.

---

## What you fixed (and what you fixed without being asked)

From the review:
- `CountDownLatch(2)` to `1`. Finally.
- `EXPOSE 43000` to `42000`, including the comment line above it.
- The commented-out original Dockerfile is gone.
- The stray French fragment is gone.
- `.dockerignore` no longer has the duplicate `*.ipr`.
- `lombok` and the unused `junit-jupiter-api:6.0.3` are removed from `build.gradle.kts`.

Beyond the review:
- You also removed `jackson-databind`, which was unused and not on the list. You caught it yourself.
- After the dependency cleanup, you re-ran `jdeps` and discovered the module set had changed: `java.desktop` and `java.sql` were no longer needed, and `java.logging` and `java.xml` were now needed. You updated `--add-modules` accordingly. That is the kind of follow-on thinking that distinguishes mechanical fix-and-move-on from actually understanding what just changed.
- You fact-checked Claude's claim that the new module set would be smaller. Ran `jlink --add-modules X --output /tmp/test` for each module, measured with `du -sh`, confirmed. That is the verification habit applied correctly, on a claim you had every reason to take on faith.
- You added a `README.md` that explains the build and run paths, which was not asked for.
- You bumped `jdk_version=21` to `25` in the HOME profile so both profiles work with the `static void main()` syntax.
- You noticed `// test` on `Main.java` line 54 yourself while running through your own checklist, and removed it.

That last one is the thing I want to point at specifically. The checklist worked. Right there, in real time, on a real artifact you would otherwise have shipped. That is what the tool is for.

---

## The checklist itself

The line in your `pre_push_checklist.md` that I think is the strongest is this one:

> *If you can't check a box honestly, you're not done.*

That sentence is the whole discipline compressed into eight words, and the choice of "honestly" is the right bar. Not "if everything is perfect" but "if you cannot honestly say you did the check."

Across three reviews we kept naming a pattern (small things left undone, attention dropping on polishing, action before verification). All three reviews pointed at the pattern. None of them gave you a tool that addressed it directly. You built the tool yourself. That is meaningfully different from absorbing feedback. That is taking the criticism and converting it into an external scaffold for future-you to lean on.

---

## What the checklist did not catch

Two new issues this round, both falling exactly under the "internal consistency: ports, variable names, constants" category your own checklist names:

**1. `gradle.example.properties` has stale property names.** During the Part 2 follow-throughs you renamed the credential keys in `build.gradle.kts` to `repsyRepoUsername` / `repsyRepoPassword`. The template file still has the old names: `repsyUsername` / `repsyPassword`. Anyone who follows your README workflow (copy the example, fill in values, build) will hit a build failure because Gradle looks for keys that do not exist in their file.

**2. The Dockerfile jlink module comment is stale.** You correctly updated the `--add-modules` line to `java.base,java.logging,java.instrument,java.naming,java.xml,jdk.compiler,jdk.unsupported`. But the comment block above it (lines 70-77) still describes `java.desktop` (AWT/Swing) and `java.sql` (JDBC), which are no longer in the list, and does not describe `java.logging` or `java.xml`, which are. The code is right; the documentation is now wrong about what the code does.

I am noting these without making them the headline, because I do not think they are the most interesting part. The interesting part is the framing they point to.

---

## The shift worth making

Your own logbook captures the issue better than I can. Line 1460, in the middle of running the checklist on this very push:

> *"Feel already as a pain in the ass to check with serious."*

That is an honest description of what the task feels like. Walking through a diff hunting for inconsistency is *boring*. There is no novelty, no dopamine, no immediate feedback. It is exactly the kind of task that human attention struggles with, regardless of how disciplined someone is, and "summon more discipline" is not a real strategy. You are not unique in that. Most engineers feel the same way about the same kind of task. The ones who consistently catch these issues do not have better focus. They have better tools.

The strategy that actually works: **for anything a computer can verify, the right tool is automation, not vigilance.** A checklist is a manual scaffold. A pre-commit hook, a CI check, or a script is the same scaffold, except the computer runs it for you, every time, without negotiation, regardless of how tired or distracted you are.

Concrete examples that would have caught the two new issues this round, without any human attention required:

- **A CI step that runs the build from a clean clone, using only what is in the repo.** If `gradle.example.properties` keys do not match what `build.gradle.kts` expects, the build fails. CI fails. You see it before anyone reviews.
- **A CI step that does `docker compose up --build` and hits the `/test` endpoint.** Catches the EXPOSE port mismatch we discussed in the Part 3 review. Catches network binding failures (relevant for Part 4 directly). Catches a whole class of "works on my machine" bugs.
- **A pre-commit hook that fails if `gradle.properties` is staged.** Would have prevented the original credentials leak before any commit happened.
- **A simple grep check, in the pre-commit hook or in CI, that flags `TODO`, `// test`, `// TEMP`, or large blocks of commented-out code.** Catches the kind of vestigial-code review your checklist asks you to do by hand.

The framing shift: **the goal is not to be more vigilant. It is to remove vigilance as a requirement.** Your attention is a finite, expensive resource. Spend it on the parts of the work that genuinely need a human, jlink module selection, architectural decisions, code where there is no obvious right answer. Let the computer guard the boring perimeter.

---

## Closing

The pre-push checklist is a real artifact. Keep it. The next move is to take the items on it that a computer could verify and migrate them into actual automation, one at a time, as you go. You do not need to set it all up at once. One pre-commit hook that catches one specific class of mistake is a real win.

For Part 4 specifically, since the task is about introducing and debugging operational failures: the network binding case (127.0.0.1 vs 0.0.0.0) is itself a great candidate for the kind of CI check described above. Build something that would catch it, *before* you build the failure. The act of building the check first will teach you more than fixing the failure afterward will.

Good work this round. The trajectory is right.
