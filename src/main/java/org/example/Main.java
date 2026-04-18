package org.example;

import io.fusionauth.http.server.HTTPListenerConfiguration;
import io.fusionauth.http.server.HTTPServer;
import io.fusionauth.http.server.HTTPHandler;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Main {
    final static Logger logger = LoggerFactory.getLogger(Main.class);




    public static void main(String[] args) {
        int port = 42000;

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
                logger.error("Not Found");
            }

        };

        try (HTTPServer server = new HTTPServer().withHandler(handler)
                .withListener(new HTTPListenerConfiguration(port))) {
            server.start();
            logger.info("Server started on port {} ", port);
            Thread.currentThread().join();
            // When this block exits, the server will be shutdown

        } catch (InterruptedException e) {
            logger.info("It seem as something fucked up!");
            throw new RuntimeException(e);
        }
    }
    }