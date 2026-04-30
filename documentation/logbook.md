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
- Aded both the repo and file to .gitignore. Probably overkill/ redundant but who know it may avoid a typo or a single "ligne of failure" erased by an LLM in the futur. That why i call the directory no_push btw.


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
- I wanted firstly to upload every dependencies of the project to my private repo and be 100% independant from Maven central
- GPT explained it would miss the phylosophy of the exercice. create duplication and make it very weak as it would supose every dependencies maintained by myself. May make sense.
- I asked him for a minimal Hello World dependencie to validate the exercice

- Its almost midnight and an half so I will slee

For me tomorrow :
1) read again the two last review. Check if you respected the advices for this 2nd part of logbook. Finally check if mains concepts are understood
2) Do, publish to the private repo and fetch the Hello World dependencie
3) Have a look at  this potential optimization : ./gradlew publish
Consider enabling configuration cache to speed up this build: https://docs.gradle.org/9.5.0/userguide/configuration_cache_enabling.html

- Well, the idea of non privately hoesting all the dependencies doesn't please me at all. 
- This article seem to be ok, with me https://dev.to/sumstrm/time-for-secure-dependencies-private-maven-repository-for-java-kotlin-scala-5afl

The two main reasons to use private Maven repositories for your JVM packages:

   1) Secure source for open source dependencies. With 1300+ public repositories and over 24 million Java artifacts, organizations need to control the code they are using - and not allow free entry of untrusted components.
   2) Distribute internal components. With a wide range of applications that depend on each other, organizations require private repositories to share code between services while keeping artifacts private and secure.

- New plan : We will privately fetch all the dependencies, AND THEN create and fetch privately a homemade dependencie as both aproach make sense in a professional context. More can less (Take that Mr. Van der Rohe)

> 1task:main: Could not find io.fusionauth:java-http:1.4.0.
Searched in the following locations:
https://repo.repsy.io/user92137778/project1/io/fusionauth/java-http/1.4.0/java-http-1.4.0.pom
Required by:
root project '1task'
Possible solution:
Declare repository providing the artifact, see the documentation at https://docs.gradle.org/current/userguide/declaring_repositories.html

- Pleasant error, we get ride of MavenCentral public repo
- GPT told directly by itself that i needed to configure repsy ipstream by ading maven proxy to my Repsy repo setting : https://repo1.maven.org/maven2/
- Worked 
> Download https://repo.repsy.io/user92137778/project1/org/junit/platform/junit-platform-engine/1.10.0/junit-platform-engine-1.10.0.module, took 157 ms
BUILD SUCCESSFUL in 13s

- From my understanding its  a basic proxy who fetch from maven then store on my own private repo so when i build i dont go throught maven server anymore but only my own private repsy
- Lets read a bit more on it to make the concept fully ours :  https://docs.repsy.io/maven/using-repsy-as-proxy/
- My insight was right

- Well : What I want to test now is : Let say I have a bunch of dependencies, publish them with 
> ./gradlew publish
- If I ad later another dependencie and do a build without publish again before it should fail as I intentionaly didnt specified any Maven direct fetch as failback
- Interesting 
> Download https://repo.repsy.io/user92137778/project1/org/junit/platform/junit-platform-engine/6.0.3/junit-platform-engine-6.0.3-sources.jar, took 476 ms
- It just builed succefully. Well the actual behavior is silthly different from my first mental representation
- Refreshing My gradle does : Task :prepareKotlinBuildScriptModel wich seem a more complex task than running only
- Figured out that its an internal task at plugin Kotlin DSL level wich can be read from source code of IDE only. I'm too lazzy to dig that deep now. Maybe later https://github.com/JetBrains/intellij-community

- Well since i refreshed graddle with the litle elephant button I just want to check if ./gradlwev build woukd work same.

> Failed to calculate the value of task ':compileJava' property 'javaCompiler'.
> Cannot find a Java installation on your machine (Windows 11 10.0 amd64) matching: {languageVersion=21, vendor=any vendor, implementation=vendor-specific, nativeImageCapable=false}. Toolchain download repositories have not been configured.
- Make sense. I'm at work and my toolchain is Java 25 on my windows machine as its the last LTS 
- I commented in my build.gradle and made a copy/paste with 25 to switch easily. If i notice other change between both machine I would have to create HOME and WORK graddle properties
// HOME
  //java {
  //    toolchain {
  //        languageVersion.set(JavaLanguageVersion.of(21))
  //    }
  //}
- Build Passed. endpoint 200 and 404 as esxpected. No regression. Obviously one nexts step would be to learn to automate those unitary testing as its redundant

- Well no.. it was a cached build who passed as the elephant gradle button, keep going to happend. 
- Tweaked a bit my gradle.propertie so I can switch easily to work profile and JDK 25 in two click
# HOME
# org.gradle.java.installations.auto-detect=false

# WORK
org.gradle.java.installations.auto-detect=true

- But we will do it one click instead of 2 by 
- Now we dinamicaly change the version by commenting/uncomenting one area only on code 
> java {
toolchain {
  languageVersion.set(JavaLanguageVersion.of(property("jdk_version").toString().toInt()))
  }
  }
- I think its the kind of litles things who seem nothing but avoid shooting your own leg later by keeping clear config

- NOW we have a working project who comile and run + dynamic simple configuration + no regression 

- Time to go back to creating my own hello world java dependencie to ad to my Repsy
- Minimal "hw_dependencie" project done and publish with ./gradlew publish from 
- aded import to the main project
> implementation("org.example:hw_dependencie:1.0.0")
- Something went wrong.. but seriously we are so close to a success :    
> Could not find org.example:hw_dependencie:1.0.0.
Searched in the following locations:
https://repo.repsy.io/user92137778/project1/org/example/hw_dependencie/1.0.0/hw_dependencie-1.0.0.pom
If the artifact you are trying to retrieve can be found in the repository but without metadata in 'Maven POM' format, you need to adjust the 'metadataSources { ... }' of the repository declaration.
- I'm glad I went for trying two solutions for private repository cause it lead to an error i wouldnt even know just with public dependencies pushed in my private repsy

>// Publishing only repositories
repositories {
maven {
url = uri(property("repsyUrl") as String)
credentials {
username = property("repsyUsername") as String
password = property("repsyPassword") as String
}
}
}
}

> // Downloading only repository
repositories {
mavenCentral()
}
- I puted Repsy in the dowload Repository section of my graddle and not in my upload one. I wasn't clearly aware of the architecture so I copy pasted a bit  too fast the Repsy set up from the main project
- My guts told me about : "It must probably be an indetation / bracket/ Section delimitation  issue but it was blur as hell.. Anyway that one of my favorite use case with LLM. Saying you think the logic of your file is only "aproximatly correct" but failed + provide error message

- Server endpoint Work just like a charm.

IMPORTANT PERSONAL NOTE : 

- I made a similar mistake as with the JDK version when testing with javac --version and whith the Case sensitivy.
- I mixed the environement I have at work (gradle 9.3 through wrappler) with the 4.1 who come packaged with APT and Debian 13
- In a way I'm disapointed of myself cause I keep doing same big mistake : deep lack of stringency
- But I solved it, and the more I pay lack of stringency by losing time the most i will remember the importance of it
- Still I think the hability to understand I was wrong (it wasnt only a groovy > kotlin syntax difference issue) and to change my attack angle is a good point.
- I didn't gave up. Here is the point
- I then applied it to my graddle.propertie. Being sttrict and using gradle properties for JVM version instead of hardcoded allow to switch easily between Windows and Unix developement environement context
- I'm glad docker is the next part as its the logical follow up when it come to cross-platfoirm standardized runtime environement. The monkey is coming, dear whale

Bonus : Cache optimization for ./gradlew publish

- https://docs.gradle.org/9.5.0/userguide/configuration_cache_enabling.html 
- 655ms without any optimzation
- Doc goes straight to the point
- ad to gradle.properties 
> org.gradle.configuration-cache=true
- BUILD SUCCESSFUL in 641ms
- Tried again : 605 ms/ 655 ms.. doesnt seem revelant : project may be too small

- Found something else who look funny to go even faster : Enabling Parallel Configuration Caching
- Just aded directly to gradle.properties either
> org.gradle.configuration-cache.parallel=true
- BUILD SUCCESSFUL in 641ms/ 622 ms, 593 ms, 613 ms
- even if the message showed up as excepted 
>configuration cache entry reused.

- Claude sugested few other ways to go, it seem interesting but I think for now its better to close the task, go for a review and then task 3. Or maybe as a follow up exercice sure
- Hierarchisation of priorities is important.
- Still I keep thinking about Maybe I can maybe  simulate a big repo with a fake ull of 0101010 10GO dependencie or something
- Not gona lie  i'm a bit frustrated to not see even a litle improve, I wanted to feel as the guys on youtube who say "blablabla my build gies 42% faster now"


- Shit I completly forget this part of the REVIEW_PART1_FOLLOWUP.md

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
1) The catch block from growth area 5 is unchanged

A) The block currently logs at the wrong level
  - Changed log level from info to error as 
  - I thought Info was fine as in my case an interuption would have no difference with a graceful latc hook trigger.
  - If i have understood well, its an error level cause in production context the rough interuption can lead to a cascade of problem (request pending in pool causing a timeout, a framework responding weirdly and lead to a crash.)

B) The log give no context
- Sure, here my mistake was to look for something funny to write. I get myself distracted a bit
- Thought a bit about what the hell i can put there. Well we cat a catch (InterruptedException e)
- So the goal is to know thanks to the error that server wasn't shut down gracefully. As said above, will be important to investigate an issue in a real (and complex) context
> Server interrupted while waiting for shutdown latch

C) The catch block wraps a checked exception in a runtime one for no real reason

- This one will ask me a bit of thought. Lets be fully honest so far I didn't really dig try catch and exception handling. Inteliji proposed autocmplete and i approved.
- Better late than nothing. Today we will dig the subject. I started to discuss a bit with Claude to have a good understanding through question/ ask for criticize reformulation of my understanding

- The caller of a fonction and the function itself sign a contract. The contract say what are autorized imput and expected output 
- "throws" clause depict says that a given type of exception isnt handled there directly and transfe the responsability of error handling to the caller (propagation). The main throw driectly error to JVM who kills the process
- "Catch" stops the error propagation and handle the error right there  

- SHIT I compiled the test dependencie with a jvm 25 at work :)
> 1task:main: Dependency resolution is looking for a library compatible with JVM runtime version 21, but 'org.example:hw_dependencie:1.0.0' is only compatible with JVM runtime version 25 or newer.
- Of course a java program compiled in JVM X can't be compiled later in a previous JVM version
- I downloaded a JVM 25 for this project through intelijii > Project structure > SDK. Went for Amazon koreto just cause I remmeber my colleague said they fix fast and are very active int devlopment
- Complied just fine

- Lets go back to our java gestion of errors
- Try/Catch block act as a kind of watchdog where you monitor a block of code surrounded by "if" and take action accordingly if an error occur. You describe the handle erro logic into the "catch"

> } catch (InterruptedException e) {
logger.info("It seem as something fucked up!");
throw new RuntimeException(e); // ← ici
}
- The problme is by Wrapping an InterruptedException (specific) exception into a more general exception RuntimeException we only make error less specific/revelant fro debugging 
- In Java each exceptions are class herithing from each others. they can be unchecked or checked 
- InterruptedException is checked and RuntimeException is unchecked, so the code will compile even if we dont do something to handle the exception. That why the IDE suggested this trick, to simplify and avoid botherring with the exception 
- Note that wrapping exception may make sense in cas of lambda expression (heheheh the next topic..) or in case of an interface who doesnt allows to throws exception
- As public static void main(String[] args) throws InterruptedException declare throws InterruptedException we can completly let the error propagation going 
- Last but not list we avoiding overlooggin as the fix turn
> java.lang.RuntimeException: java.lang.InterruptedException
at org.example.Main.main(Main.java:47)
Caused by: java.lang.InterruptedException
at ...
- Into...
> java.lang.InterruptedException
at org.example.Main.main(Main.java:47)
- Seem nothing, but once again in a big scale production context it can save yoir mental health at 3.AM

- GOOOD : We have a good and a bad new : Good is the cache seem to work !
> Parallel Configuration Cache is an incubating feature.
Calculating task graph as no cached configuration is available for tasks: build
BUILD SUCCESSFUL in 8s

VS, while compiling again right after :
> Reusing configuration cache.
BUILD SUCCESSFUL in 659ms

- The bad new was once again my lack of stringency. I read log too fast. Well, at least we get the """big brain""" optimization satisfaction feeling :)

2) Lambda style note
- Changed shutdown hook for lambda expression syntax 
> Runtime.getRuntime().addShutdownHook(new Thread(() -> latch.countDown()));

- Fine, the name is cool, but why ?
- Lambda allow way more concise code
- In Java everything excepting instructions and primitives tyoes are objects
- So you cant define a methode outside a class or pass this function as method parameter withouth anonymous inner classes. A whole class for a single behaviour
- Was boilerplate
- Lambdas expressions (also named enclosures or  anonymous functions, allow to pass as parameters a set of instructions
- A lambda always implemnt a fonctional interface with only one abstract method
> https://www.jmdoudoux.fr/java/dej/chap-lambdas.htm

- Everything compile fine. I'm happy as I was able to do task 2 from A to Z in a not too long time. Obviously speed isn't the much important at all but still
- Note for reviewer ; Don't hesit to force me showing deep understanding of concepts used, explaining them etc. I'm a bit affraid of my own lazyness if I'm not push to :(

- Final check. Server work as a charm

- Well, in any cases.. Midnight and half.. Good night ! :)

- I'm just thinking (late night thinking) ,I may probably have not only  loaded credential from gradle properties to avoid having them hardcoded but also loaded them from a hash. to not have them in plain text anywhere.. . idk not very clear on my mind  its maybe even note possible. Hope rewiever will have some insights


- Guess who missed an important thing about the tesk :
  Document:
  • what error you see when auth is wrong,
  • how you identified the root cause,
  • how you fixed it.

- As its just worked fine from firrst time i sisnt produce auth going wrong 
- Lets add some properties in gradle.properties to cover all the case properly and see if we got fifferents messages by replacing the correct properties ones by one
> repsyUrl_WRONG
>FAILURE: Build failed with an exception.

* What went wrong:
>Configuration cache state could not be cached: field `classpath` of task `:compileJava` of type `org.gradle.api.tasks.compile.JavaCompile`: error writing value of type 'org.gradle.api.internal.artifacts.configurations.DefaultResolvableConfiguration'
Could not resolve all files for configuration ':compileClasspath'.
Could not find io.fusionauth:java-http:1.4.0.
Searched in the following locations:
https://repo.repsy.io/user92137778/project1WRONG/io/fusionauth/java-http/1.4.0/java-http-1.4.0.pom
- The build fail cause the wrong repo URL lead to try to fetch the dependcies from a repo who doesnt exist / where those dependencies arent reachable
- Without required dependencies build fail
> repsyUsername_WRONG
>BUILD SUCCESSFUL in 737ms
- Interesting, with the correct url but wrong username.. the project build succefully
>  Task :run
10:18:21.385 [main] INFO org.example.Main -- Fuck off procrastination!
1777537101409 Starting the HTTP server. Buckle up!
1777537101419 HTTP server listening on port [42000]
1777537101419 HTTP server started successfully
10:18:21.419 [main] INFO org.example.Main -- Server started on port 42000
[###########....] 75% EXECUTING [24s]
- Wait..it buiuld and run.. it surpised me first
- But ad an idea : Probably whhen you fetch dependencies from a maven repository you are on read only with no write access. so fetching dependencies is fine cause username is used to authentificate only and publish some
- Lets dig the hypotesis 
> Could not get resource 'https://repo.repsy.io/user92137778/project1/org/projectlombok/lombok/1.18.46/lombok-1.18.46.pom'.
Could not GET 'https://repo.repsy.io/user92137778/project1/org/projectlombok/lombok/1.18.46/lombok-1.18.46.pom'. Received status code 401 from server:
- Here we go. After changing the username auth and added a dependencie then to the build.gradle build fail.
- 
- WAITTT. The insight on read/write permission may be wrong cause I just noticed a folder named "extternal libraries" in my inteliji. So with already fetched dependencies, graddle just grab them from the local copy he made previously
- Once fetched the .jar are copied locally
- Lets test it by viiolently erase few jar from the folder 


 > Could not get resource 'https://repo.repsy.io/user92137778/project1/org/projectlombok/lombok/1.18.46/lombok-1.18.46.pom'.
Could not GET 'https://repo.repsy.io/user92137778/project1/org/projectlombok/lombok/1.18.46/lombok-1.18.46.pom'. Received status code 401 from server:
- It still works, only the new dependencie cause the same error 
- Hum maybe i'm wrong and the jar in external library folder isnt a fallback for already feyched dependency. Or maybe.. maybe it is but same message come cause something is weirdly cached somewhere
- Lets try to be violent again : Invalidate casche and restart + all boxes checked 

 > Could not download logback-classic-1.5.32.jar (ch.qos.logback:logback-classic:1.5.32)
Could not get resource 'https://repo.repsy.io/user92137778/project1/ch/qos/logback/logback-classic/1.5.32/logback-classic-1.5.32.jar'.
Could not GET 'https://repo.repsy.io/user92137778/project1/ch/qos/logback/logback-classic/1.5.32/logback-classic-1.5.32.jar'. Received status code 401 from server:
Could not download jackson-annotations-2.21.jar (com.fasterxml.jackson.core:jackson-annotations:2.21)
Could not get resource 'https://repo.repsy.io/user92137778/project1/com/fasterxml/jackson/core/jackson-annotations/2.21/jackson-annotations-2.21.jar'. Could not GET 'https://repo.repsy.io/user92137778/project1/com/fasterxml/jackson/core/jackson-annotations/2.21/jackson-annotations-2.21.jar'. Received status code 401 from server:
- YESSS it was cause of cache. Erased .jar locally destroyed the fallback 
- but the weird thing is I did a ./gradlew publish who was writed as success before rebuilding. So the new dependencie failed silently to be uploaded on repo
- Same after invalidate cache. I may probably be fool.. Like.. no access to repo to upload, the build fail as expected but the ./gradlew publish JUST SUCCESS/FAILL SILENTLY ?!
- Asked Claude. He said its possible. okay.. Gave me some good idea : testing with ./gradlew publish --info or --debug flags
- Honestly.. ./gradlew publish --debug was just too long to read. I ctrl+f "error, not found,notfound" 0 iteration for each of the.
- I gave the entire log to Claude
- He pointed somethin
> Task :publish UP-TO-DATE
2026-04-30T10:59:25.418+0200 [INFO] [org.gradle.api.internal.tasks.execution.SkipTaskWithNoActionsExecuter] Skipping task ':publish' as it has no actions.
- No halucination its indeed in logs
- He said : Gradle never attempted to publish anything. The configuration cache had stored a previous successful build state and simply reused it, skipping the task entirely. No HTTP request was made to Repsy — no auth failure, no success, just nothing.
  Key takeaway: the silence wasn't a Maven Publish plugin error-handling issue. It was the configuration cache short-circuiting the whole task. Before concluding an error is "silent", always check whether the task actually ran — UP-TO-DATE in the logs means Gradle skipped it entirely.
- I protested and said i invalidated cache and restart?.. but it was inteliji cache and not gradle cache. Imixed both :(
- EVEN ./gradlew publish --no-configuration-cache --info
- GAVE ME :  Skipping task ':publish' as it has no actions.
- ./gradlew publishMavenPublicationToMavenRepository --no-configuration-cache
- Finally failed. At this point I was very pissed off but was only the begining
-  ./gradlew tasks --no-configuration-cache found only 2 things :
> publishMavenPublicationToMavenLocal
publishToMavenLocal

- Tired i gave to Claude my gradle. And guess what ?
- I forget to puth credential in publishing block. They was only in reprository. All this time lost cause i didn't verified step by step and logicaly
- did again ./gradlew publish and finally failed as expected
> Could not resolve org.projectlombok:lombok:1.18.46.
Could not get resource 'https://repo.repsy.io/user92137778/project1/org/projectlombok/lombok/1.18.46/lombok-1.18.46.pom'.
Could not GET 'https://repo.repsy.io/user92137778/project1/org/projectlombok/lombok/1.18.46/lombok-1.18.46.pom'. Received status code 401 from server:
- And worked succefuly with the corrct username
> BUILD SUCCESSFUL in 13s

> repsyPassword_WRONG
- Build and run success cause dependencies was fetched from preious build. As excepted
- Erase some localy previously fetched jar
> Exception in thread "main" java.lang.NoClassDefFoundError: ch/qos/logback/core/joran/spi/JoranException
at java.base/java.lang.Class.getDeclaredConstructors0(Native Method)
at java.base/java.lang.Class.privateGetDeclaredConstructors(Class.java:2985)
- Failed as expected as there is no local fallback anymore and repo password wrong doesnt allow to go for the classic way
- The important thing is when you run, log primarily only say : dependency X, Y, Z, not found. Which is true  BUT you have no imediate clue about the auth root cause problem

- The fix was always same : put the correct propertie back by clicking on te litle elephant to resync and build again 

Some last words to ad after this task

- I must be logical, review where it can fail. From simple cause to more tricky ones
- I went too fast  exploring cache when it was all about a misundertsanding on how gradle Repo and publish task works
- I need to be careful, calm down when I'm excited and take a step back to see the whole picture. Maybe a schema had helped

- I can be proud of myself cause despite clearly under optimized way.. i manage to find one way


--------------------------------------------------------------------------------------------------------------------------------

Part 3 – Dockerize properly
• Write a Dockerfile that:
• builds the app,
• runs it as a non-root user,
• does not create OS users at container startup.
• Use docker compose to run the app.

Deliverable:
• docker compose up --build works from a clean state.
- 
- Went At the project root
> docker init
> docker compose up --build
- 
> #11 ERROR: failed to calculate checksum of ref o3mleuczvsuvlhg4001owiqmx::sgh1qtzfbrodfm26ntodg31vn: "/pom.xml": not found
#12 [deps 3/5] COPY --chmod=0755 mvnw mvnw
#12 ERROR: failed to calculate checksum of ref o3mleuczvsuvlhg4001owiqmx::sgh1qtzfbrodfm26ntodg31vn: "/mvnw": not found
#15 ERROR: failed to calculate checksum of ref o3mleuczvsuvlhg4001owiqmx::sgh1qtzfbrodfm26ntodg31vn: "/pom.xml": not found
#16 [deps 4/5] COPY .mvn/ .mvn/
#16 ERROR: failed to calculate checksum of ref o3mleuczvsuvlhg4001owiqmx::sgh1qtzfbrodfm26ntodg31vn: "/.mvn": not found
failed to solve: failed to compute cache key: failed to calculate checksum of ref o3mleuczvsuvlhg4001owiqmx::sgh1qtzfbrodfm26ntodg31vn: "/pom.xml": not found
- "/pom.xml": not found "/mvnw": not found "/.mvn": not found
- Files arent into the docker context
- Strange cause i builded at the root of project
- Shit, "pom.xml": not found "/mvnw": not found "/.mvn": not found" ... the docker  init is for maven build not gradle :)
- No option for graddle with docker.. we will have to use brain :)
- I remmeber blurrly that I heard about build stage and optimization but I dont mind for now lets just make something working
- Stack. home sweet home  https://stackoverflow.com/questions/61108021/gradle-and-docker-how-to-run-a-gradle-build-within-docker-container
- Adapted gradle version 
- Exercice says : runs it as a non-root user, does not create OS users at container startup.
- Unfortunately the current one run as root
- Lets try to make it work as root first, then we will improve
- Moved from openjdk for koretto as open JDK doesnt provide JDK 25. Stayed with alpine as its suposed to be light +fast
- sent the Dockerfile. GPT said it was bullshit: redundant build, run as root.. and proposed a better version
> failed to solve: failed to compute cache key: failed to calculate checksum of ref o3mleuczvsuvlhg4001owiqmx::vmipy2cda3d6cz1tevw6mqosd: "/settings.gradle": not found
- Changed COPY build.gradle settings.gradle for  $APP_HOME/ COPY build.gradle.kts settings.gradle.kts $APP_HOME/ to match the file name
>  ✔ Image project1-server       Built                                                                                                                                                                                53.1s
✔ Network project1_default    Created                                                                                                                                                                              0.0s
✔ Container project1-server-1 Created                                                                                                                                                                              0.1s
Attaching to server-1
server-1  | no main manifest attribute, in app.jar
server-1 exited with code 1                                                                                                                                                                                              
- Weird cause I have both 
plugins
{
  id("java")
  id("application")
  id("maven-publish")
  }
- AND
application {
  mainClass.set("org.example.Main")
  }
- Docker should find the entry point then
- Oh shit yes I remmember about this. My jar isnt a Fat/uber Jar so its 
- My concetration level started droped so hard 

- WE ARE BACK
- Aded shadow plugging to my build.gradle.kts will allow me to compile my fat jar. This is necessary for two reasons : 
1) A fat jar is a jar who contain all dependencies needed at runtime. It allow to run the application then in one line
> java -jar myapplication.jar

> When Not to Use Uber-JAR?
There are some situations where it is not advantageous to use an Uber-JAR, especially in containerised environments. When developing a web application using the Uber-WAR solution of Spring Boot,for example, a single change in your application code results in the build of the Uber-WAR file that is placed inside a Docker image and transferred to the Container repository so that the cloud environment can pick up the change. This means that a single change results in the recreation of a file that is typically around 50 to 100 Mb and that needs to be transferred over the network. And in almost all situations, there is no change to the application runtime and thus there was no need to repackage that.
- Okay I googled a bit ( and wanted a critical external point of view as i'm paranoîac when it come to potential LLM misslead
- seem as its not optimized at all 
- Layered jar will be a think to look at, maybe as a follow up. I will leave it for later or reviewer diescretion cause i feel as if I try now i will lost myself. Let keep it simple first
- shadow also read 
application {
  mainClass.set("org.example.Main")
  }
- Shadow not only import necessary dependencies at runtime but also  create the MANIFEST.MF wich contain metadata. Especially the entry point of the java program
- Thanks to this when java -jar app.jar is performed, the JVM open the Jar and find the Main-Class and call it main()
- To do so we just need on ecommand
> ./gradlew shadowJar
- Went fine and fat jar was created
> BUILD SUCCESSFUL in 8s
2 actionable tasks: 2 executed
Configuration cache entry stored.
- Let test locally
> java -jar build/libs/1task-1.0-SNAPSHOT-all.jar
- Shit JRE missmatch version
> Error: LinkageError occurred while loading main class org.example.Main
java.lang.UnsupportedClassVersionError: org/example/Main has been compiled by a more recent version of the Java Runtime (class file version 69.0), this version of the Java Runtime only recognizes class file versions up to 65.0
- Lets install the last 25 LTS koretto system wide, anyway 21 will be depreciated soon, better to go for last LTS : https://docs.aws.amazon.com/corretto/latest/corretto-25-ug/generic-linux-install.html
> 1task-1.0-SNAPSHOT-all.jar
> 23:13:26.603 [main] INFO org.example.Main -- Fuck off procrastination!
1777583606620 Starting the HTTP server. Buckle up!
1777583606629 HTTP server listening on port [42000]
1777583606630 HTTP server started successfully
23:13:26.630 [main] INFO org.example.Main -- Server started on port 42000 
- Worked + tested endpoint

> docker build -t project1 .
- Meme : -t = give a tag /name to image to avoid having only an idea/ "." indicate position of Dockerfile. the current directory in our case
- Build O.K
- lets check
> docker images
> project1:latest 9c6fb5fbf08b 376MB 0B
> docker run -p 43000:43000 project1
docker: Error response from daemon: failed to create task for container: failed to create shim task: OCI runtime create failed: unable to retrieve OCI runtime error (open /run/containerd/io.containerd.runtime.v2.task/moby/e0034c1efecc2c0413842168b0250f472df585a2a205c1c01263636b140d688a/log.json: no such file or directory): exec: "nvidia-container-runtime": executable file not found in $PATH
- Shit i probably fucked my nvidia drivers long time ago and run on intel CPU for a while without noticing
- Lets check
> nvidia-smi
> -bash: nvidia-smi: command not found
- Here we go lets try to install again properly
- Didnt worked and i'm a bit too exausted to go deep there 
> echo $XDG_SESSION_TYPE
- I'm using Wayland as display server, not X11 and the config of nvidia seem to be a pain in ass. I remember now. I switched a while ago from X11 cause blablabla i read it was more modern etc.. then saw nvidia doesnt worked anylore an dswitched to cpu
- i switched back default docker runtime from nvidia to runc
> sudo nano /etc/docker/daemon.json
- restart docker daemon 
> sudo systemctl restart docker

> docker run -p 43000:43000 project1
22:01:28.266 [main] INFO org.example.Main -- Fuck off procrastination!
1777586488287 Starting the HTTP server. Buckle up!
1777586488307 HTTP server listening on port [42000]
1777586488307 HTTP server started successfully
22:01:28.307 [main] INFO org.example.Main -- Server started on port 42000 
- IT WORKED :) 
- Tested.. wait it doesnt work when i try to hit the api endpoint as i have an erro in browser tab
> This site can’t be reached
- I'm fool i mapped port as following : -p 43000:43000
- But inside my app port is 42000 
- <Port_Exposed_Docker>:<Port_Exposed_Java_app>
- So i need to go for : 43000:42000
> docker run -p 43000:42000 project1
- WORKED.. FOR REALLL !!
- Worked same with compose
> docker compose up
- WORKED AGAIN
- Added image: project1:latest in compose as a matter of clarity so no need to read all the Dockerfile to get name of image builded
>docker ps -a
CONTAINER ID   IMAGE             COMMAND               CREATED          STATUS          PORTS                                                        NAMES
972316f48fdd   project1:latest   "java -jar app.jar"   26 seconds ago   Up 25 seconds   43000/tcp, 0.0.0.0:43000->42000/tcp, [::]:43000->42000/tcp   1task-app-1

- Lets break down docker core concepts
- Dockerfile is used to build a Docker image, which can then be launched with docker run. compose.yaml allows you to configure and launch multiple Docker images in a single command, making it the standard tool for multi-container projects and scaling.

- We will understand and explain each word of our Current Dockerfile to be sure everything is clear

# ===== BUILD STAGE =====
# Defines the first stage of the multi-stage build, named "build".
# Uses the official Gradle 9.5.0 image with JDK on Alpine (lightweight Linux).
FROM gradle:9.5.0-jdk-alpine AS build

# Declares an environment variable APP_HOME pointing to the app's working directory.
ENV APP_HOME=/usr/app

# Sets /usr/app as the current working directory for all subsequent instructions.
WORKDIR $APP_HOME

# Copies only the Gradle configuration files from the host machine into the container.
# Doing this first allows Docker to cache this layer and avoid re-downloading
# dependencies if these files have not changed.
COPY build.gradle.kts settings.gradle.kts $APP_HOME/

# Copies the gradle/ folder (containing the Gradle wrapper) into the container.
COPY gradle $APP_HOME/gradle

# Copies the rest of the project (sources, resources, etc.) into the container.
COPY . .

# Runs the Gradle task that cleans old artifacts, then compiles and packages
# the application into a fat/uber JAR (shadowJar bundles all dependencies).
# --no-daemon avoids starting the Gradle daemon, suitable for CI/container environments.
RUN gradle clean shadowJar --no-daemon


# ===== RUNTIME STAGE =====
# Defines the second stage, the final runtime image.
# Starts fresh from Amazon Corretto 25 (Amazon's JDK distribution) on Alpine.
# This image is lighter because it contains neither Gradle nor the source code.
FROM amazoncorretto:25-alpine-jdk

# Re-declares the APP_HOME environment variable (ENV values do not carry over between stages).
ENV APP_HOME=/usr/app

# Sets /usr/app as the current working directory again.
WORKDIR $APP_HOME

# Copies only the JAR produced by the "build" stage into the final image,
# renaming it app.jar. The *.jar wildcard matches the shadowJar output file.
COPY --from=build /usr/app/build/libs/*.jar app.jar

# Creates a system group "appgroup" and a system user "appuser" belonging to that group.
# Done in the Dockerfile (not at startup) so the user exists inside the image itself.
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Switches the current user to "appuser" for all subsequent instructions.
# The container will therefore run without root privileges.
USER appuser

# Documents that the application listens on port 43000.
# This is an indication for Docker and third-party tools — it does not open the port by itself.
EXPOSE 43000

# Defines the default command executed when the container starts:
# runs the JAR with the JVM via "java -jar app.jar".
# ENTRYPOINT (unlike CMD) cannot be easily overridden,
# making it suitable as the fixed and primary entry point of the application.
ENTRYPOINT ["java", "-jar", "app.jar"]

- Finally we go to discuss with Claude a bit to know if some optimisation can be done to speed up the amount of time taked by our docker build 


- Almost 1 AM, lets sleep a bit we will dig Dockerfilne line by line and build optimization tomorrow :)



