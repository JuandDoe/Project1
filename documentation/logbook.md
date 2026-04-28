Part 1 – Minimal app

• Create a small Java service (Spring Boot / plain Java / anything you’re comfortable with).
- Creation of a java Hello world project powered by gradle with intelijii

• One endpoint is enough (e.g. /health → ok).
https://github.com/FusionAuth/java-http/https://fusionauth.io/blog/java-http-new-release
Had previous experiences only with jetty. Chosed java-http cause minimalism plain java sound fun

> Fuck off procrastination!
1776446234472 Starting the HTTP server. Buckle up!
1776446234494 Unable to start the HTTP server because one of the listeners threw an exception.
java.net.BindException: Permission denied
at java.base/sun.nio.ch.Net.bind0(Native Method)
at java.base/sun.nio.ch.Net.bind(Net.java:565)
at java.base/sun.nio.ch.Net.bind(Net.java:554)
at java.base/sun.nio.ch.NioSocketImpl.bind(NioSocketImpl.java:636)
at java.base/java.net.ServerSocket.bind(ServerSocket.java:391)
at io.fusionauth.http.server.internal.HTTPServerThread.<init>(HTTPServerThread.java:85)
at io.fusionauth.http.server.HTTPServer.start(HTTPServer.java:96)
at org.example.Main.main(Main.java:28)

- Clearly a permission issue  : java.net.BindException: Permission denied

- You can't open a port below 1024, if you don't have root privileges  https://stackoverflow.com/questions/25544849/java-net-bindexception-permission-denied-when-creating-a-serversocket-on-mac-os

- Explaintaion : 0-1024 ports are privileged ports.

- Fix : Use non privileged 4200 port instead. No 420 Weed server for now.

- > Task :org.example.Main.main()
  Fuck off procrastination!
  1776447559722 Starting the HTTP server. Buckle up!
  1776447559743 HTTP server listening on port [4200]
  1776447559743 HTTP server started successfully
  1776447559743 HTTP server shutdown requested. Attempting to close each listener. Wait up to [10000] ms.
  1776447559745 HTTP server shutdown successfully.

- Absolutly no clue whth it shutdown automaticly. Probably stupid reason, I read again did'nt found. Lets go with debugger. 
Understanding nothing more. Thanks debugger. 
- Asked Free chatgpt without account
- It seem to be a thread related problem : when the code is executed and we go until the end of main, server.close is called automaticaly. Normal JVM behaviour.

Thread.currentThread().join(); : Ask the Main thread to wait for the main thread to shut down. A thread can't end up if he has to end up his own death to end. Schodinger Thread :)

• Logging enabled

- Went for the lazzy logback setup 
- copy/paste snipset from official configuration page : https://logback.qos.ch/manual/configuration.html
- Strugle a bit to import the proper dependence from mavencentral. Finally goes for the rough solution, importing the largest all in one dependencie and not granular import one litle piece and one other.

• App run locally (./gradlew run or equivalent)

- Went to https://docs.gradle.org/current/userguide/application_plugin.html
copy pasted
  application {
  mainClass = "org.gradle.sample.Main"
  }
- Didn't catched i had to separate pluggin declaratiuion then usage so i copy pasted my wrong graddle in gp and get solution from there
- 
- ./gradlew run failed
- > FAILURE: Build failed with an exception.

>What went wrong:
Could not determine the dependencies of task ':run'.
Could not resolve all dependencies for configuration ':runtimeClasspath'.
Failed to calculate the value of task ':compileJava' property 'javaCompiler'.
Toolchain installation '/usr/lib/jvm/java-21-openjdk-amd64' does not provide the required capabilities: [JAVA_COMPILER]

- Ask my best friedn (AKA GPT) 
> Toolchain installation '/usr/lib/jvm/java-21-openjdk-amd64' does not provide the required capabilities: [JAVA_COMPILER]
- He said I hadent a proper JVM installation (without compiler) so following command should return nothing. Ofc bullshit i have a proper JVM
> javac --version
- This graddle elephant is faulty 
- aded  
- > org.gradle.java.installations.auto-download=true 
- Download a fresh jdk to use for reproductable build 
  > org.gradle.java.installations.auto-detect=false
  - Avoid using my own JDK broken setup 

> rm -rf ~/.gradle/caches
rm -rf ~/.gradle/kotlin-dsl
rm -rf ~/.gradle/daemon
- Erase graddle cache. I leted GPT grab me by hand for the specific command. Just asked him how deleted entire cache.

  - Was trigered by GPT saying can do a reproductible build
  > org.gradle.java.installations.auto-download=true
- How the hell can we be sure if a JVM version isnt explicitly told
- GPT told me i was the most awesome God's creatire for pointing it out and proposed me to ad following code in seeting.gradle
> java {
toolchain {
languageVersion.set(JavaLanguageVersion.of(21))
}
}

- IT WORKED 
> > Task :run
10:56:30.569 [main] INFO org.example.Main -- Fuck off procrastination!
1776502590584 Starting the HTTP server. Buckle up!
1776502590596 HTTP server listening on port [42000]
1776502590596 HTTP server started successfully
10:56:30.596 [main] INFO org.example.Main -- Server started on port 42000
<==========---> 80% EXECUTING [10s]
> :run

- Bonus :  Tried my endpoint http://localhost:42000/TEST instead of http://localhost:42000/test in firefow browser by mistake and discovered its not case sensitive at all


_____________________________________________________________________________________________________________________________________________________________________________

Suggested follow-up exercises

1. **Reproduce the case sensitivity claim with curl, not a browser, and document the result.** One paragraph in the logbook with your finding and your best explanation of why.

- First I thought I was probably when i thought i noticed it was probably crazzyness from half sleep cause it was impossible to reproduce the case sensitivity
Testd http://localhost:42000/TEST on :
brave v1.89.143 => 404 NOT FOUND
firefox 140.7.0esr (64-bit) => NOT FOUND
chrome 147.0.7727.116 (Official Build) (64-bit) => NOT FOUND

then instead of typing directly on tab http://localhost:42000/TEST i typed http://localhost:42000/test and then correct manually with http://localhost:42000/TEST 
It gave me Successful HTTP request on brave v1.89.143

- At this point I was like : shit wth is happening. And thought okay it may be cache or autocompletion. Breath deeply, Looked calm at what exactly happend when i sent request through browser tab.
- It was autocompletion through browsr historic search suggestion who turned http://localhost:42000/TEST into http://localhost:42000/test without I paid attention to it.
- I WRITED "/TEST" but was actually sending "/test" through autocompletion/suggestion

As I'm a serious junior I did the test curl as suggested to go until enfd of the logic 
> curl -v http://localhost:42000/TEST
Host localhost:42000 was resolved.
IPv6: ::1
IPv4: 127.0.0.1
Trying [::1]:42000...
Connected to localhost (::1) port 42000
using HTTP/1.x
GET /TEST HTTP/1.1
Host: localhost:42000
User-Agent: curl/8.14.1
Accept: */*
Request completely sent off
  < HTTP/1.1 404 

> curl -v http://localhost:42000/test
Host localhost:42000 was resolved.
IPv6: ::1
IPv4: 127.0.0.1
Trying [::1]:42000...
Connected to localhost (::1) port 42000
using HTTP/1.x
GET /test HTTP/1.1
Host: localhost:42000
User-Agent: curl/8.14.1
Accept: */*
Request completely sent off
  < HTTP/1.1 200 

- Conclusion : 
- I need to be carefuk about what I THINK i send as imput and what I REALLY send as imput.
- Even for small task using proper tools as insomnia and postman is a good idea as it offer a cleaner testing environemnt set up who may help avoiding small mistakes.

2. **Replace `Thread.currentThread().join()` with a `CountDownLatch` plus a shutdown hook.** Write three lines explaining what each piece does.

- Wanted to have a look at a medium article on CountDownLatch but finally decided that i'm not a pusssy and be brave enough to go for Oracle offcial documentation https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CountDownLatch.html
- We will read Padjet articles who paraphrase offical doc if we are too stupid to understand the primary source.

> A synchronization aid that allows one or more threads to wait until a set of operations being performed in other threads completes.
A CountDownLatch is initialized with a given count. The await methods block until the current count reaches zero due to invocations of the countDown() method, after which all waiting threads are released and any subsequent invocations of await return immediately. This is a one-shot phenomenon -- the count cannot be reset. If you need a version that resets the count, consider using a CyclicBarrier.

- "plus a shutdown hook"

- I want to clarify what a hook is. I know what hook up is, but i don't think the reviewer want us have sex with the JVM.
- It seem as its related to fishing but i'm unsure reviewer like this activity

- un hook est une opportunité laissée au programmeur ou à l'utilisateur de modifier le fonctionnement d'un code préexistant.
  https://french.stackexchange.com/questions/6698/traduction-de-hook-dans-un-contexte-de-programmation
Allow people to ask translation of tech terminology by tech bros. It seem as an hook in this context is something who allow the user to interact dynamicaly with the software when the software is running.
In our case I think it mean like : Shuting down the server dynamical through a keyboard shortcut as a good old "ctrl+c"

- Struggle to find example, googleed "CountDownLatch to shut down server" nothing semt interesting, no example directly in doc neither. At least nothing i'm smart enough to adapt. 
-  Cant go further than initialization   : CountDownLatch latch = new CountDownLatch(1);
- Started to be grumpy, doesnt wanted to pipe my current code to GPT and ask him to correct me so fast.
- Didn't now what to do, was stuck. Read again the question. It remind me the reviewer said each words of an error is important. We may think each word of reviewer is important as well
- Copy pasted task 2 : "CountDownLatch` plus a shutdown hook" => https://stackoverflow.com/questions/8897643/setup-shutdownhook-and-exit-application this stuff look promising

- Seem to work. ctrl+c kill the server 
+ Lets try if it work too with a SIGNINT cause its pointless if we cant kill the server from an another Sell 
> ps aux | grep 'java'
- Retuned too much process
- ps aux | grep '[g]radlew'
> ant      3626441  0.6  0.3 3290696 127140 pts/26 Sl+  18:35   0:04 java -Xmx64m -Xms64m -Dorg.gradle.appname=gradlew -classpath /home/ant/IdeaProjects/1task/gradle/wrapper/gradle-wrapper.jar org.gradle.wrapper.GradleWrapperMain clean run
- way better : PID is 3626441
- Checked if our change introduced a regression : /test OK 200  && /TEST NOT FOUND 400. No regression 
> kill -SIGINT 3626441
- Worked like a charm :)

- BUUUTT used ps aux | grep '[g]radlew' instead of ps aux | grep 'gradlew' I understand is to not having grep process itself in output but even with explaination of regular expression i'm in a frog.
- Will try to dig until I fully understand cause it anoy me (both taking time to get it AND drifted from initial exercice and get lost with this "distraction")
- I think i understand [g] mean expression must start with "g" so 'gradlwev' start with "'" not "g" and will not be outputed 

EXPLAINATIONS

final CountDownLatch latch = new CountDownLatch(1);
// 

Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {
@Override
public void run() {
latch.countDown();
}
}));

try (HTTPServer server = new HTTPServer().withHandler(handler)
.withListener(new HTTPListenerConfiguration(port))) {
server.start();
logger.info("Server started on port {} ", port);
latch.await();

- I take a break cause Nuggets are ready and I need a break :) 

- Okay something piss me of run() method has an usage but I don't see where. And it trigger me cause i can't explain the code properly as asked if I don't find this answer.
> @FunctionalInterface
public interface Runnable
Represents an operation that does not return a result.
This is a functional interface whose functional method is run().

- I ADORE when I undertsand nothing :)

- Okay I think I get it 
>final CountDownLatch latch = new CountDownLatch(1);
// logout or shutdown event
Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {
- Initialise CountDownLatch + the thread with a shutdownHook
> latch.await();
- Stop the thread 

- Run() is called ?
- Cause SIGINT sent by ctrl+C is a POSIX standard who make jvm execute Runtime.getRuntime().addShutdownHook(...) and run() is in the scope so the code ito the scope  is executed
- latch is decreased and fall to 0 so the main   is not blocked anymore and end gracefuly

- Just to check if what we read so far is true, lets try to put         
>inal CountDownLatch latch = new CountDownLatch(2)
- We except the program not stop as 2-1 = 1>0
- Shit. It stop the server anyway. I may have missed something.
- Okay I mixed : countDown() lock a thread if > 0 but a SIGINT come from OS. The order come from the OS so the porcess >MUST STOP. The addShutdownHook just allow to clean or execute some code before the shutdown ordered  by OS but cant ignore the order

3. **Do a log-level audit on your service.** For each `logger.X(...)` call, ask "would I want this in production at this level?" Adjust as needed.

Turned   logger.error("Not Found");  into logger.info("Not Found"); As discussed cause 404 is a common issue and a path error doesnt need human attention / to wake you up at 2AM. Reviewer said on side she only eventualy put Errors 5XX as error
Other log level stay info as I dont have external monitoring or log system. But I noted they wouldnt even probably be info level in a real production context, just ignored

4. **Write a three-line postmortem of the JVM toolchain debug.** What was the actual root cause, what did you try first, what would you do differently next time. This is a tiny exercise but it cements the lesson.

- The root cause was the toolchain the gradle build system saw does not advertise a JAVA_COMPILER capability
- I puted myself from shell perspective with javac command and as I saw there was a proper jvm with compilation tool installed I drawed conclusions too fast

- 1) Newt Time i must read message properly the error message and be humble toward him.  NOT REJECTING HYPOTHESIS I HAVEN4T TESTED
- 2) I need to keep in mind the context/scope i'm working into ( Here : Gradle scope and what Gradle "see")


_____________________________________________________________________________________________________________________________________________________________________________

Part 2 – Gradle + repository authentication
• Configure Gradle to fetch a dependency from:
• a real private Maven repository or
• a locally simulated one that requires authentication.
• No hardcoded secrets in the repository.
• Use environment variables or ~/.gradle/gradle.properties.

Document:
• what error you see when auth is wrong,
• how you identified the root cause,
• how you fixed it.

- Lets google it!
> set up maven private repo
- Well browsing few results but feel as if I start reading what each techs solutions tell about themeself they will kidding me by all saying they are THE marvellous 3 legs unicorns out there. 
- Goodl old dear stack : https://stackoverflow.com/questions/12410423/how-do-i-setup-a-private-remotely-accessible-maven-repository
- Post from one year ago. Should still be a up to date solution : https://repsy.io/
- ITS FREE; (very important as we are rats) - Anyway the scope of the exercice is about finding a tool and properly seted up. So, no problem to go "dirty", right ? 
- Started set up : seem quite simple with few click through a GUI. Private repo seed up
- Get an access token. create a folder no_push/ and a repsy.txt inside to store it . Exclude both from Git
- Aded both the repo and file to .gitignore. Probably overkill/ redundant but who know it may avoid a typo or a single "ligne of failure" erased by an LLM in the futur

- Walked a bit around the website and found something interesting : Using Repository with Gradle
-  Well..well..well. Here the kind of problem I hate. Foud a good documentation, matching my tool... but half.

> publishing {
publications {
maven(MavenPublication) {
from components.java
}
}

    repositories {
        maven {
            url 'https://repo.repsy.io/{MY REPSY USERNAME}/{MY REPOSITORY NAME}'
            credentials {
                username 'MY REPSY USERNAME'
                password 'MY REPSY PASSWORD'
            }
        }
    }
- That seem as groovy syntax, which is legacy. We should use Kotlin. 
- I was like.. well its easy I give my current gradle file to GPT and the groovy snipset, tell him i'm on graddle 9 + kotlin and he will do some magic.
- Fail. It just circled in an error hello loop. Had some hope with Claude. Same ki,d of output.
- I tried to cope few seconds  like.. well maybe we can go for obviously depreciated groovy.. So i just have to copy pasta the snipset (okay we are all cowards sometime)
- jacklackofsurprise for Reddit just puted me back on hearth : https://www.reddit.com/r/groovy/comments/1e0t4ip/is_groovy_usage_growing_or_declining_now_what_is/
> 2y ago
  I mean, this Subreddit has 3.2k members and the last post before you was 22 days ago.... do the math.

- Anyway the reviewer would probably have noticed I changed the stack. Or not, may have been a good test.. BUT we have to stay honest. Changin a stack for not using my brain is stupid.
- Lets try using brain
- Tired
- Tried last desesperate moove : https://www.codeconvert.ai/groovy-to-kotlin-converter
- Same output. Silently cried
- CTRL +f "kotlin" on https://docs.repsy.io/maven/using-repository-with-gradle/ => 0 occurence

- Okay let be honest at this point i'm a bit lost : 
Was my maven repo choice a stupid one ? Liike.. maybe I chosed the first solution who seem free + okay and my mistake is there : mostly the tool choice
- Maybe its fine and i'm a bit affraid of facing the idea to really understand graddle => kotlin conversion 

- Found nothing revelant to my problem
- Asked GPT something as : OKay, calm down I'm lost let get back to basics, logicaly
- Checked gradle version
  > gradle -v
  openjdk version "21.0.10" 2026-01-20
  OpenJDK Runtime Environment (build 21.0.10+7-Debian-1deb13u1)
  OpenJDK 64-Bit Server VM (build 21.0.10+7-Debian-1deb13u1, mixed mode, sharing)

------------------------------------------------------------
Gradle 4.4.1
------------------------------------------------------------

Build time:   2012-12-21 00:00:00 UTC
Revision:     none

Groovy:       2.4.21
Ant:          Apache Ant(TM) version 1.10.15 compiled on September 29 2024
JVM:          21.0.10 (Debian 21.0.10+7-Debian-1deb13u1)
OS:           Linux 6.12.73+deb13-amd64 amd64

- 4.4.1... I think we found something :)
- last version : 9.4.1 (18 Mar 2026) https://endoflife.date/gradle 
- 4.4.1 : (04 Dec 2018) Ended 7 years ago (26 Nov 2018)
> update gradle linux debian 13
- Guess what ! https://unix.stackexchange.com/questions/805289/apt-get-install-gradle-puts-a-4-4-1-version-2012-for-java-8-which-cannot-be-i
> The reason Debian doesn’t ship a newer version of gradle is that packaging Gradle 4.5 or newer requires Kotlin, as well as removing some proprietary dependencies that newer versions of Gradle rely on to build, and doing all of that with properly-aligned versions of all the dependencies is an enormous amount of work. There was progress last year but that seems to have stalled for the time being.
-  Here we go : https://docs.gradle.org/current/userguide/installation.html
- found something interesting on the gradle website 
> ./gradlew wrapper --gradle-version latest 

> ./gradlew wrapper --gradle-version latest
openjdk version "21.0.10" 2026-01-20
OpenJDK Runtime Environment (build 21.0.10+7-Debian-1deb13u1)
OpenJDK 64-Bit Server VM (build 21.0.10+7-Debian-1deb13u1, mixed mode, sharing)
Downloading https://services.gradle.org/distributions/gradle-4.4.1-bin.zip
........................................................................
Unzipping /home/ant/.gradle/wrapper/dists/gradle-4.4.1-bin/46gopw3g8i1v3zqqx4q949t2x/gradle-4.4.1-bin.zip to /home/ant/.gradle/wrapper/dists/gradle-4.4.1-bin/46gopw3g8i1v3zqqx4q949t2x
Set executable permissions for: /home/ant/.gradle/wrapper/dists/gradle-4.4.1-bin/46gopw3g8i1v3zqqx4q949t2x/gradle-4.4.1/bin/gradle
FAILURE: Build failed with an exception.

- FUCK YOU STUPID ELEPHANT. I hope your specie will colapse
- Why the hell latest still 4.1, I guess they just go hit the official debian 13 repo so it change nothing and i'm facing same problem

- Okay i found https://snapcraft.io/gradle
- But my understanding of flat sandboxing is very low ifk even if its a good path. Kepp calm. Lets keep it simple, stupid : Instal gradle 9 at system vide level

- Sumarize all to GPT and simply get back to KISS : installing graddle 9 through graddle wrapper in my debian 13
> gradle wrapper --gradle-version 9.5.0
BUILD SUCCESSFUL in 0s

> ./gradlew build
> ./gradlew --version : Gradle 9.5.0
- it start to smell good :)


BUILD SUCCESSFUL in 3s
5 actionable tasks: 5 executed
Consider enabling configuration cache to speed up this build: https://docs.gradle.org/9.5.0/userguide/configuration_cache_enabling.html

- Finally, now we can follow the Repsy documentation, and adpat the groovy syntax with GPT to adpat to Kotlin
> CONFIGURE SUCCESSFUL in 42ms 
Task :prepareKotlinBuildScriptModel UP-TO-DATE
BUILD SUCCESSFUL in 1s
- YES ! :)
> ./gradlew publish
BUILD SUCCESSFUL in 14s
- !!!!!! :)

> BUILD SUCCESSFUL in 678ms
  5 actionable tasks: 5 up-to-date
  Consider enabling configuration cache to speed up this build: https://docs.gradle.org/9.5.0/userguide/configuration_cache_enabling.html
- Lets dig this cache optimzation. It seem funny

- Still I have the feeling, confirmed by GPT that my current build doesnt really download the dependencies from my private repo as requested by the exercice
-  For now its a fail. too bad
- I wanted firstly toupload every dependencies of the project to my private repo and be 100% independant from Maven central
- GPT ecxplained it would miss the phylosophy of the exercice. create duplication and make it very weak as it would supose every dependencies maintained by myself. Sound logical.
- I asked him for a minimal Hello World dependencie to validate the exercice

- Its almost midnight and an half so I will slee

For me tomorrow :
1) read again the two last review. Check if you respected the advices for this 2nd part of logbook. Finally check if mains concepts are understood
2) Do, publish to the private repo and fetch the Hello World dependencie
3) Have a look at  this potential optimization : ./gradlew publish
Consider enabling configuration cache to speed up this build: https://docs.gradle.org/9.5.0/userguide/configuration_cache_enabling.html

