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


