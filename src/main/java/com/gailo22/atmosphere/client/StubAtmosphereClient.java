package com.gailo22.atmosphere.client;

import java.util.Random;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;

import net.minidev.json.JSONArray;
import net.minidev.json.JSONObject;

import org.atmosphere.cpr.MetaBroadcaster;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class StubAtmosphereClient {

	protected final Logger logger = LoggerFactory.getLogger(getClass());

	private ExecutorService executor;

	private boolean shuttingDown = false;

	@PostConstruct
	public void start() {

		this.executor = Executors.newSingleThreadExecutor();

		this.executor.submit(new Runnable() {
			@Override
			public void run() {
				while (!StubAtmosphereClient.this.shuttingDown) {

					final Random random = new Random();
					final JSONObject object = new JSONObject();
					final JSONArray entryArray1 = new JSONArray();
					entryArray1.add(random.nextInt(10));
					entryArray1.add(random.nextInt(10));
					entryArray1.add(random.nextInt(10));
					entryArray1.add(random.nextInt(10));
					final JSONArray entryArray2 = new JSONArray();
					entryArray2.add(random.nextInt(10));
					entryArray2.add(random.nextInt(10));
					entryArray2.add(random.nextInt(10));
					entryArray2.add(random.nextInt(10));
					final JSONObject entry1 = new JSONObject();
					entry1.put("entry", entryArray1);
					final JSONObject entry2 = new JSONObject();
					entry2.put("entry", entryArray2);

					object.put("01/01/2012", entry1);
					object.put("02/01/2012", entry2);


					final String message = object.toJSONString();
					StubAtmosphereClient.this.logger.info("Broadcasting Message: " + message);
					MetaBroadcaster.getDefault().broadcastTo("/", message);

					try {
						Thread.sleep(7000);
					} catch (final InterruptedException ex) {
						StubAtmosphereClient.this.logger.debug("Stub Lisram service interrupted");
					}
				}
				StubAtmosphereClient.this.logger.debug("Stub Lisram service stopped");
			}
		});
	}

	@PreDestroy
	public void stop() {
		this.logger.debug("Shutting down stub Lisram service...");
		this.shuttingDown = true;
		this.executor.shutdownNow();
	}
}
