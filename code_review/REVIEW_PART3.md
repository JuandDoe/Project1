# Review: Part 3, Dockerize Properly

## Headline

This was the most ambitious round and it has a different shape from the others. The technical work is mid-level engineering, multi-stage builds, custom JREs via jlink, BuildKit secrets, and it works. But the *way* you got there has a question worth sitting with. Both go in this review.

Before that, the part you do not always get credit for: between the Part 2 review and this round, you also went back and did the Part 2 follow-throughs. That deserves its own paragraph.

---

## Part 2 follow-throughs you completed

The "Post review follows ups" section in your logbook (lines 802 onwards) documents that you:

- Switched Gradle from account credentials to repo-scoped credentials, exactly as we discussed.
- Renamed the property keys to `repsyRepoUsername` / `repsyRepoPassword` so the scope is visible at the call site. This was your own addition, not in the review.
- Replaced the `_WRONG` values with safe placeholders that do not derive from the working ones.
- Added `mavenCentral()` back as a fallback alongside Repsy, addressing the single-point-of-failure concern.
- Tested by wiping every Gradle cache directory and rebuilding from clean.

Five concrete fixes, all from one review. Most people address the one thing that broke and move on. You worked through the whole list and added an improvement of your own (the rename) on top. Worth saying so out loud.

---

## What was strong in Part 3 itself

**1. The multi-stage architecture is correct.**
Three stages (build, jre-build, runtime) with the final image starting from bare Alpine 3.23. The final image carries the fat JAR and a custom minimal JRE, nothing else. No Gradle, no JDK, no source code. That is the production-grade pattern, not the beginner pattern.

**2. Credentials are handled correctly at the Docker layer.**
`--mount=type=secret,id=gradle_props` injects `gradle.properties` only during the RUN step that needs it. The credentials are never written into any image layer. Even if the final image leaked publicly, the credentials would not be extractable from it. After the Part 2 incident, this matters more than the average code review point.

**3. The jlink custom JRE is genuinely advanced work.**
Using jdeps to identify which modules the app actually needs, then jlink to assemble a stripped JRE with only those modules, is mid-level engineering. Most engineers do not learn jlink for years.

**4. The layer cache strategy is correctly ordered.**
Copy build files first, run `gradle dependencies`, then copy source, then build. Source-only changes do not invalidate the dependency layer. The 36s to 8.7s rebuild speedup you measured (logbook line 1167) is real and earned.

**5. The non-root user is created at build time, not at startup.**
`addgroup -S appgroup && adduser -S appuser -G appgroup` followed by `USER appuser`. Exactly what the task asked for, with the user baked into the image rather than created on first launch.

**6. You annotated the new Dockerfile line by line.**
Every directive has a comment explaining what it does and often why. Some are perfunctory, most are useful. This is the right thing to do after vibecoding: document until you actually understand. We will talk about the order question shortly, but the documentation pass itself is correct work.

**7. You created the `.dockerignore` yourself.**
Logbook line 1348: *"Okay actually I think the reviewer will kill me. I just remember that  .dockerignore right now"*. You caught it without prompting. The contents are sensible: secrets, build artifacts, `.git`, IDE files. No surprises.

**8. You reasoned about command scope, late but correctly.**
You first ran `docker system prune -a --volumes` as your version of "clean state." That command nukes every unused Docker resource on the entire machine. It was harmless on your install because you only have one project on it; on a setup with other work, it would have been catastrophic. Then you asked me for the right command, got `docker compose down -v --remove-orphans`, and instead of just adopting it and moving on, you compared the two in your logbook (line 1346): project-scoped vs system-wide, project-scoped is safer. The praise is not for the first command (which was risky). It is for the comparison you made afterward. The same reasoning applied *before* running anything destructive would have caught the issue earlier, and that is the version of this habit worth keeping.

**9. You pushed back on Part 2 advice and you were right to do so.**
Logbook line 1177 argues that build optimization on small Docker projects is different from build optimization on small Gradle projects, because Docker rebuild iterations are much slower and the cost of waiting compounds during debugging. That is a correct refinement of the Part 2 advice. The "optimization is theater on small projects" line was about Gradle specifically, and you accurately spotted that the same logic does not extend to Docker. This kind of independent thinking is the difference between absorbing feedback and actually internalizing it.

---

## The process question

Now the part that matters most.

By your own admission (logbook line 1169): *"Okay I must completly admit from jlint it was mostly 'full' vibecoding. I just wanted an optimized stuff which build faster than my basic one."*

You shipped code you did not fully understand, then went back and learned it. The annotation pass you did afterward is the right recovery, and the fact that you did the recovery at all puts you ahead of most people in the same situation. But the question worth sitting with is not "is vibecoding bad." It is **what order matters, and why.**

The order you used: vibecode, push, understand.
The order that costs less long-term: understand, push.

Same final code, very different long-term cost. Three reasons:

**1. Pushed-then-understood code becomes load-bearing before you can defend it.** When something breaks at midnight a month from now, you will be debugging code you did not write, in a state you do not remember choosing, against a problem you cannot fully describe. The annotation pass you do now is read-only. Pre-push, the same understanding pass could have caught real issues (you would have noticed if jlink picked the wrong modules, for instance) and you could have adjusted. Post-push, you are just describing what is there.

**2. The vibecoded artifact subtly shapes what you ask next.** When you ask Claude "is this jlink config right?", the answer is constrained by what is already in the file. When you ask "what would the right jlink config be for an app like this?", the answer is freer and more useful. The first question is what most post-vibecode review looks like. The second is what pre-vibecode design looks like. The first one tends to confirm what you already pushed.

**3. It is harder to reverse a decision once it is committed.** Sunk cost is a real thing for engineers too. If you pre-commit to a multi-stage jlink build and then realize a single-stage with a slim JRE base would have been sufficient and simpler, the path of least resistance is to keep what you have. If you have not committed yet, swapping is free.

The fix is not "stop using LLMs to write code." LLMs are tools and they are useful. The fix is: **for any non-trivial code, the understanding step happens before the push, not after.** It does not have to be from scratch. It can be "Claude generates this, I read it line by line, I ask three 'why' questions, I test one assumption by changing a value and observing what happens." Maybe an hour on top of the generation. The cost of skipping that hour is what we just talked about.

You wrote this in your own logbook (line 1175): *"This way i will either stop to feel guilty for vibecoding too much and take thoses new concepts as mine"*.

The "or" you wrote (stop or take as mine) is actually an "and" in practice. Take them as yours, by understanding before the push. That is the discipline.

---

## What is still broken

These are a mix. The first two are leftovers from previous reviews, still pending. The other two are new this round, both arrived with the vibecoded Dockerfile, both easy fixes.

**1. `Main.java` line 17: `final CountDownLatch latch = new CountDownLatch(2);`.** (Carryover from Part 1 follow-up.)
This is the second review where I am noting this. The fix is one character. I see your `// test` on line 54 and yes, I read it as the self-aware "this file is still in test mode" wink it is. I appreciate the gesture. Now fix the bug. "I know about it" does not help the next person who maintains this code, and the bug is genuinely real: the moment you put anything between `latch.await()` and program exit, the count-2 version drops it on the floor. Change `2` to `1`. I am going to stop being polite about this one specifically.

**2. `Dockerfile` line 173: `EXPOSE 43000`.** (Carryover from your earlier Part 3 checkpoint.)
The app listens on 42000 (`Main.java` line 21). The compose file correctly maps `43000:42000`, so functionally it works. But EXPOSE is documentation, and documentation that does not match reality is worse than no documentation. Should be `EXPOSE 42000`.

**3. The original Dockerfile commented out at the top of the new file (lines 1 to 44).** (New this round.)
Useful for your own learning right now, not OK for any shared codebase. Comments are not version control. The right tool for "I want to remember the old version" is `git log`. The convention exists because once code lives commented in a shared repo, nobody else will ever clean it up; removing someone else's commented code feels presumptuous, so it accumulates forever. For this exercise, fine. In a real PR, kill it.

**4. `Dockerfile` line 5: stray French text.** (New this round.)
The line ends with *"dans ton docker-compose.yml."* This is a sentence fragment Claude wrote in mid-explanation that ended up pasted into the file. Quick cleanup pass. Small thing, but the kind of detail reviewers notice and read as "did not check the work."

---

## Two smaller notes

**`.dockerignore` has a duplicated line.** `*.ipr` appears on lines 32 and 33. Cosmetic.

**`build.gradle.kts` has accumulated dead dependencies.** `lombok` was added during your Part 2 wrong-credentials investigation and the project does not actually use it. `junit-jupiter-api:6.0.3` is marked in your own comment as *"not used dependencies so far. just here for repo logic testing/understanding"*. Both should either be removed or have a comment explaining why they stay. Carrying unused dependencies is a small cost on a small project and a real one on a big project; the habit to build now is "if it is not used, it is not declared."

---

## The arc across three reviews

Reading the three reviews back to back, the picture is consistent. You are technically capable, fundamentally curious, and meta-aware in a way that is genuinely rare. The patterns that also recur are:

- **You leave behind small unfixed things.** CountDownLatch(2) flagged in two reviews now without being fixed. EXPOSE 43000 has carried unchanged through multiple revisions of the Dockerfile, including the rewrite. Each one is trivial alone. The pattern is what is interesting: finishing-touches are the part of the work where your attention drops fastest. Worth knowing about yourself.
- **You ship before you fully understand.** Twice now. The credentials in `gradle.properties` was the unintentional version. The vibecoded Dockerfile is the deliberate one. Same shape underneath: action precedes verification.
- **You catch yourself, but only after.** You named the stringency pattern after the third instance. You named the vibecoding after the push. The catch is real and it counts. The next test, the test that is not yet complete, is catching yourself before, not after.

That third bullet is the same advice from Part 2 and Part 1. It keeps recurring because the next level of skill, for you specifically, is not more knowledge. It is the *timing* of when you apply what you already know.

---

## Closing

You produced more good engineering in this round than in either of the previous two. The Part 2 follow-throughs alone would be a respectable week of work for a junior. The Docker work on top of that is mid-level for the techniques used (jlink, BuildKit secrets, multi-stage layer cache strategy), and you are now in a position to actually understand all of it because you spent the time to annotate it line by line.

Three reviews in, the picture I keep landing on is: you have the instincts, you have the curiosity, you have the meta-awareness. What you do not yet have is the *timing* of those instincts. That is a learnable skill and you are partway through learning it.

Good work. Now fix the CountDownLatch.
