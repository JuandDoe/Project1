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