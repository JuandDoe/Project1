# Review: Part 1, Minimal Java App

## First, the headline

You are further along than you think. Reading your submission top to bottom, the most valuable thing in the whole repo is not the code, it is your `logbook.md`. The habit of writing down what you observed, what you guessed, what you tried, and what changed your mind is the single highest leverage skill in this whole field, and most developers two or three years into their careers still do not do it. You did it on day one of an exercise nobody made you do. Hold on to that.

The rest of this doc is going to focus on growth areas, because that is the point. But read the strengths section first and let it sink in, because it is real.

---

## What worked well

These are not throwaway compliments. Each one is a behavior worth keeping.

**1. You built a working thing end to end.**
A real HTTP server, a real logging stack, a real Gradle build. You picked a small library you had not used before (`fusionauth/java-http`) and got it serving traffic. That is a complete loop, and a lot of people get stuck before closing it.

**2. You debugged a real problem with real evidence.**
The `BindException: Permission denied` story is textbook good debugging. You read the actual error message, you formed a hypothesis (port permission), you confirmed it with a source, you understood the underlying reason (ports under 1024 are privileged), and you fixed it. You did not just change the port and shrug. That is the loop you want to repeat for every bug you ever see.

**3. You noticed when something did not match your mental model and you stopped to investigate.**
When the server shut down immediately, your logbook note was basically "no clue why this happened, going in with the debugger." That instinct is gold. Most juniors paper over surprises. You named yours, opened a debugger, asked for help when the debugger did not give you enough, and worked through the JVM lifecycle reasoning until it made sense. The Schrödinger thread framing made me laugh, and we will come back to it in the growth section, because the instinct is right even if the explanation is not quite.

**4. You did not hide your dead ends.**
You wrote down the wrong turns: the cache-clearing detour, the misplaced `application` block, the moment you dismissed a hypothesis. That honesty is the thing that lets future-you (and reviewers like me) actually help. Polished writeups that pretend everything was linear are far less useful than a messy log of what really happened.

**5. You asked the right question about reproducibility, unprompted.**
In the middle of the toolchain debugging mess, you stopped and asked how anyone can be sure the same JVM version is used across builds if it is not stated explicitly anywhere. That is not a junior question. That is the kind of thing that, in a real team, would make a senior nod and say "yes, exactly, that is why we pin our toolchains." It is also what led you to the actual fix (forcing Gradle to download a specific JDK). The lesson worth keeping: when something works "by accident" because of whatever is on your machine today, that is a signal to pin it down, not to move on.

---

## Growth areas

Each item below is structured the same way: what happened, why it matters, what to try next. None of these are deal breakers. They are the next layer of skill on top of what you already showed.

### 1. Your `Thread.currentThread().join()` works, but for a different reason than you wrote down

Your explanation in the logbook said the main thread is asked "to wait for the main thread to shut down" and called it a Schrödinger thread. The mental image is fun, but the actual mechanic is simpler and worth getting precise about: `Thread.join()` blocks the calling thread until the target thread terminates. When the calling thread and the target thread are the same thread, it can never terminate while it is waiting on itself, so it just blocks forever. Your code works because `main` hangs indefinitely, which keeps the JVM alive, which keeps the server running. It is a side effect, not a design.

Why this matters: it works, but it is the kind of code a senior would flag in review. There are cleaner idioms for "keep the process alive until shutdown":
- a `CountDownLatch` that is counted down by a JVM shutdown hook
- a blocking call on the server itself, if the library exposes one
- `Thread.sleep(Long.MAX_VALUE)` in a loop (also a hack, but a more honest one)

The reason to care is not style. It is that when you actually need to coordinate shutdown (close DB connections, flush logs, stop accepting new requests), the latch pattern gives you a hook. `join()` on yourself does not.

### 2. Log levels are part of the API

Your 404 branch logs `logger.error("Not Found")`. A 404 is a normal response, not an error. In a real production system, every missed request would land in your error dashboard and on-call's pager. The habit to build:

- `ERROR`: something went wrong that needs human attention
- `WARN`: something unusual happened, you should look later
- `INFO`: a normal event worth recording
- `DEBUG`: detail useful when investigating

A request hitting an unknown path is `INFO` at most, often nothing at all. Audit your own service the same way you would audit somebody else's: imagine you are on call at 2am and your phone is buzzing. Would you want this log line to wake you up?

### 3. Read error messages literally, and do not reject a hypothesis you have not tested

This is the most important note in the whole review, so I am going to spend more time on it.

In the logbook you wrote that GPT said you did not have a proper JVM, and you replied "Ofc bullshit i have a proper JVM" because `javac --version` returned a result. But the original error said:

> Toolchain installation '/usr/lib/jvm/java-21-openjdk-amd64' does not provide the required capabilities: [JAVA_COMPILER]

The error is not "you do not have a JVM." It is much more specific: "this particular toolchain installation does not advertise a JAVA_COMPILER capability." That is a real thing. It usually means a JRE-style install (no `javac`), or a multi-package distribution where the compiler package is not present, or a symlink pointing somewhere weird. GPT was closer to the truth than you gave it credit for; you dismissed the hypothesis based on a different test (`javac --version`) that was not actually testing what Gradle was complaining about.

The lesson is not "trust GPT more." The lesson is two things:

1. **Read the error message word by word.** "does not provide the required capabilities" is a different claim than "is not a JVM." Errors are usually written carefully. When you skim them and substitute a paraphrase in your head, you start chasing the paraphrase instead of the actual problem.
2. **Do not reject a hypothesis without a test that can actually disprove it.** `javac --version` works on your shell PATH; it does not test what Gradle's toolchain resolver sees. To actually test "is this Gradle toolchain install missing the compiler", the right move is to look at the contents of `/usr/lib/jvm/java-21-openjdk-amd64` and check whether `bin/javac` is there.

You eventually got to a working answer (force Gradle to download its own JDK), but the path was longer than it needed to be because you ruled out the right answer too early. This is the single most common debugging anti-pattern, and noticing it in yourself is half the cure.

### 4. Verify casual observations before they become beliefs

Your bonus note said `/TEST` worked instead of `/test` and you concluded HTTP endpoints "are not case sensitive at all." This is worth double-checking, because:

- HTTP paths are case sensitive per the spec.
- Your code uses `path.equals("/test")`, and `String.equals` in Java is case sensitive.

So if `/TEST` actually returned 200, something interesting is happening (the library might be normalizing the path, the browser might be doing something, or the test was not what you remember). The exercise: reproduce it with `curl -v http://localhost:42000/TEST` and `curl -v http://localhost:42000/test` and see what you actually get. Then look in the `fusionauth/java-http` source or docs for any path handling. You may find that your original observation was right but for a different reason than you thought, or that it was wrong, or that browsers do something subtle. Whichever it is, the value is in chasing the question to the end instead of leaving a half-formed conclusion in the logbook.

This generalizes: every time you write down "I noticed X", ask yourself "do I actually know X is true, or did I see one example?" One example is a hypothesis, not a fact.

### 5. The catch block is doing very little work

```java
} catch (InterruptedException e) {
    logger.info("It seem as something fucked up!");
    throw new RuntimeException(e);
}
```

Three small things worth knowing:

- Logging at `info` for what the message itself flags as a failure.
- The message tells future-you nothing about what was happening (which server, which port, what was being awaited).
- Wrapping a checked exception in a `RuntimeException` is sometimes the right call, but here you do not really need the catch at all; you could declare `throws InterruptedException` on `main` and let the JVM handle it.

Compare to something like:

```java
} catch (InterruptedException e) {
    Thread.currentThread().interrupt();
    logger.warn("HTTP server main thread interrupted, shutting down", e);
}
```

The `Thread.currentThread().interrupt()` line is the convention for restoring the interrupted state, the log message tells you what happened, and the exception object itself is passed in so the stack trace is preserved. Tiny details, but they are the difference between a log line that helps and one that wastes your time.

---

## Suggested follow-up exercises

Small, concrete, do them in any order:

1. **Reproduce the case sensitivity claim with curl, not a browser, and document the result.** One paragraph in the logbook with your finding and your best explanation of why.
2. **Replace `Thread.currentThread().join()` with a `CountDownLatch` plus a shutdown hook.** Write three lines explaining what each piece does.
3. **Do a log-level audit on your service.** For each `logger.X(...)` call, ask "would I want this in production at this level?" Adjust as needed.
4. **Write a three-line postmortem of the JVM toolchain debug.** What was the actual root cause, what did you try first, what would you do differently next time. This is a tiny exercise but it cements the lesson.

---

## What to focus on in Part 2

Part 2 is private repository authentication, which is mostly a debugging exercise dressed up as a configuration exercise. The two things that will most help you:

1. **Keep the logbook discipline.** Same format, same honesty about dead ends.
2. **When something fails, the error message is the primary source of truth.** GPT and Stack Overflow are second-tier sources at best, and you should always cross-check what they say against what the error actually says. The toolchain story above is the canonical example.

If you build those two habits in Part 2, the rest of the parts (Docker, intentional failures, runbook) will go much faster, because they are all variations on the same skill.

---

## A closing note

Solo-learning without seniors who give you real feedback is genuinely hard. A lot of what makes someone "good" at this job is just having watched an experienced person debug in real time and absorbed their reflexes. Without that, you have to manufacture the loop yourself, and that is what this exercise (and your logbook) is doing. Trust that the discipline you are building right now compounds, even when the day-to-day feels slow.

You are already doing the right things. The rest is reps.
