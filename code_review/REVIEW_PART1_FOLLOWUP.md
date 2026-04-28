# Review: Part 1 follow-up

## Headline

This round is a real step up. Not flattery, calibration: the work you did on the four exercises is meaningfully better than the original Part 1 submission, and the reason it is better is not because the code got bigger or the topic got harder. It is because of how you investigated. Specifics below.

---

## What was strong

**1. The case sensitivity exercise: you went past the answer and found the actual cause.**
You could have stopped at "I tested in three browsers and curl, paths are case sensitive, my original observation was wrong, done." That would have been a passing answer. Instead you went looking for why your original observation had seemed to show the opposite, even after the retest. You noticed that typing `/TEST` directly in Brave returned 404, but typing `/test` and then editing the URL to `/TEST` returned 200, and you traced that inconsistency to browser autocompletion silently rewriting `/TEST` into `/test` from your history. The conclusion you wrote, that you need to be careful about the difference between what you think you are sending as input and what you are actually sending, is the right lesson, and you arrived at it by yourself. That is the difference between memorizing a fact and understanding a phenomenon.

**2. The CountDownLatch(2) experiment is the best thing in this submission.**
After you got the count-1 version working, you deliberately changed it to count-2 to see if your mental model of how the latch worked was correct. When the program exited anyway, instead of shrugging and reverting, you investigated and corrected your own model: SIGINT is OS-level, it kills the JVM regardless of what your code is doing, and the shutdown hook is just a chance to run cleanup before that happens.

I want to be very clear about why this matters. Most juniors, and a lot of mid-level engineers, treat working code as the end of the road. You treated it as a hypothesis and stress-tested it. That is the single behavior that separates engineers who keep growing from engineers who plateau. It is also a habit that is very hard to teach and you appear to have it natively. Hold on to it.

**3. You used the review feedback as a tool, not as a verdict.**
The line in your logbook ("It remind me the reviewer said each words of an error is important. We may think each word of reviewer is important as well") is exactly what I hoped for. You took the toolchain lesson and applied it to a different situation. That generalization step is where feedback actually becomes skill.

**4. The shell-side validation of the shutdown hook.**
Sending `SIGINT` from a separate shell, identifying the right PID with `ps aux | grep '[g]radlew'`, and then stopping to figure out the `[g]radlew` regex trick on your own. None of that was required. You did it because you were curious and slightly annoyed at yourself for not understanding it. That is exactly the right energy.

---

## One real bug

`Main.java:17` currently has `final CountDownLatch latch = new CountDownLatch(2);`. This is the experimental value from your "what if I set it to 2?" test. It needs to be `1`.

Here is why it matters, even though the program "still exits":

- With count `1`, the design works as intended: shutdown hook counts down, `latch.await()` returns, main thread runs to completion, try-with-resources closes the server cleanly, program exits.
- With count `2`, the latch never reaches zero, so `latch.await()` blocks forever. The program still exits when you SIGINT it, but only because the JVM kills the main thread as part of shutdown. The graceful-shutdown path is dead. Nothing after `latch.await()` in main can ever run.

Today that does not show up because there is nothing important between `latch.await()` and the end of `main`. The moment you add anything (close a database connection, flush a metrics buffer, write a goodbye log line), the bug bites you and the symptom will be confusing because the program looks like it works.

The fix is one character. The habit to build is bigger: **before you commit, run the code one more time in its intended final state.** Experimental values are easy to leave behind. A quick "did I revert my probes?" pass before `git add` is the cheap way to catch them.

---

## Two smaller notes

**The catch block from growth area 5 is unchanged.**
You addressed all four explicit exercises, which is fair, and growth area 5 was in the discussion section without a corresponding exercise. So this is not a miss, just a follow-up. The block currently logs at the wrong level, gives no context, and wraps a checked exception in a runtime one for no real reason. When you have ten minutes, take another look at it with the log-level habit you just built in exercise 3 and see what you want to change.

**Lambda style note.**
Your shutdown hook is written like this:

```java
Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {
    @Override
    public void run() {
        latch.countDown();
    }
}));
```

This is the pre-Java-8 style, which is what most older Stack Overflow answers will show you. Since Java 8 (you are on 21), the idiomatic version is:

```java
Runtime.getRuntime().addShutdownHook(new Thread(() -> latch.countDown()));
```

Same behavior, much less ceremony. Worth knowing because once you start spotting it, you will see opportunities for it everywhere. It is also a good signal when reading other people's code: if you see anonymous inner classes everywhere in modern Java, the codebase is probably copying patterns from before 2014.

---

## Green light for Part 2

You are ready. Part 2 (private repository auth) is going to test the same skills you just demonstrated, but with a class of error that is less specific than what you have seen so far. Auth failures often arrive as 401, 403, "could not resolve dependency", or just silence, and the work is figuring out which of network, credentials, scope, host, certificate, or config is actually the cause.

Two things to carry forward into Part 2:
1. Keep the logbook style. It is the most valuable artifact you produce.
2. The "scope/context I am working into" frame you wrote in your toolchain postmortem is going to be directly useful again. When auth fails, the first question is always "auth from whose perspective, against what, with what credentials." That is the same shape of question.

Good work this round.
