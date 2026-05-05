package org.example;

import io.fusionauth.http.server.HTTPListenerConfiguration;
import io.fusionauth.http.server.HTTPServer;
import io.fusionauth.http.server.HTTPHandler;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.concurrent.CountDownLatch;

public class Main {
    final static Logger logger = LoggerFactory.getLogger(Main.class);

    static void main() throws InterruptedException {

        final CountDownLatch latch = new CountDownLatch(1);
        // logout or shutdown event
        Runtime.getRuntime().addShutdownHook(new Thread(() -> latch.countDown()));

        int port = Integer.parseInt(System.getenv().getOrDefault("APP_PORT", "42000"));

        logger.info("Fuck off procrastination!");
        HTTPHandler handler = (req, res) -> {
            // Handler code goes here
            String path = req.getPath();
            if (path.equals("/test")) {
                res.setStatus(200);
                res.setContentType("text/plain");
                res.getWriter().write("Successful HTTP request");
                logger.info("Successful HTTP request");
            }
            else {
                res.setStatus(404);
                res.setContentType("text/plain");
                res.getWriter().write("Not Found");
                logger.info("Not Found");
            }

        };
        try (HTTPServer server = new HTTPServer().withHandler(handler)
                .withListener(new HTTPListenerConfiguration(port))) {
            server.start();
            logger.info("Server started on port {} ", port);
            latch.await();

        } catch (InterruptedException e) {
            logger.error("Server interrupted while waiting for shutdown latch");
            throw e;
        }

    }
    }