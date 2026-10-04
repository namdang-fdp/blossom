package com.dorriss.no;

import static org.assertj.core.api.Assertions.assertThat;
import static org.awaitility.Awaitility.await;

import com.dorriss.no.infrastructure.messaging.kafka.DomainEventPublisher;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.TimeUnit;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.jobrunr.scheduling.JobScheduler;
import org.jobrunr.server.BackgroundJobServer;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Import;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.annotation.DirtiesContext;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.GenericContainer;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.containers.wait.strategy.Wait;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.testcontainers.kafka.KafkaContainer;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.NoSuchKeyException;

@Testcontainers
@DirtiesContext(classMode = DirtiesContext.ClassMode.AFTER_CLASS)
@ActiveProfiles("local")
@Import(InfrastructureIT.SmokeConfiguration.class)
@SpringBootTest(
    properties = {
      "jobrunr.background-job-server.poll-interval-in-seconds=5",
      "jobrunr.background-job-server.worker-count=2",
      "logging.level.org.apache.kafka=WARN"
    })
class InfrastructureIT {
  @Container static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:18.6");

  @Container
  static GenericContainer<?> redis = new GenericContainer<>("redis:7.4.6").withExposedPorts(6379);

  @Container static KafkaContainer kafka = new KafkaContainer("apache/kafka:3.9.1");

  @Container
  static GenericContainer<?> minio =
      new GenericContainer<>("minio/minio:RELEASE.2025-09-07T16-13-09Z")
          .withEnv("MINIO_ROOT_USER", "smoke-local")
          .withEnv("MINIO_ROOT_PASSWORD", "smoke-local-password")
          .withCommand("server /data")
          .withExposedPorts(9000)
          .waitingFor(Wait.forHttp("/minio/health/ready").forPort(9000));

  @DynamicPropertySource
  static void properties(DynamicPropertyRegistry registry) {
    registry.add("spring.datasource.url", postgres::getJdbcUrl);
    registry.add("spring.datasource.username", postgres::getUsername);
    registry.add("spring.datasource.password", postgres::getPassword);
    registry.add("spring.data.redis.host", redis::getHost);
    registry.add("spring.data.redis.port", () -> redis.getMappedPort(6379));
    registry.add("spring.kafka.bootstrap-servers", kafka::getBootstrapServers);
    registry.add(
        "no.storage.endpoint", () -> "http://" + minio.getHost() + ":" + minio.getMappedPort(9000));
    registry.add("no.storage.access-key", () -> "smoke-local");
    registry.add("no.storage.secret-key", () -> "smoke-local-password");
  }

  @Autowired StringRedisTemplate cache;
  @Autowired DomainEventPublisher publisher;
  @Autowired S3Client storage;
  @Autowired JobScheduler scheduler;
  @Autowired BackgroundJobServer jobServer;
  @Autowired JdbcTemplate jdbc;

  @Test
  void redisRoundTripHasExpiryAndCleanup() {
    String key = "smoke:" + UUID.randomUUID();
    try {
      cache.opsForValue().set(key, "fixture", Duration.ofSeconds(30));
      assertThat(cache.opsForValue().get(key)).isEqualTo("fixture");
      assertThat(cache.getExpire(key)).isPositive();
    } finally {
      cache.delete(key);
    }
  }

  @Test
  void kafkaPublisherRoundTripsThroughRealBroker() throws Exception {
    String topic = "smoke-" + UUID.randomUUID();
    String key = UUID.randomUUID().toString();
    publisher.publish(topic, key, Map.of("kind", "fixture")).get(30, TimeUnit.SECONDS);
    var config =
        Map.<String, Object>of(
            ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG,
            kafka.getBootstrapServers(),
            ConsumerConfig.GROUP_ID_CONFIG,
            "smoke-" + UUID.randomUUID(),
            ConsumerConfig.AUTO_OFFSET_RESET_CONFIG,
            "earliest",
            ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG,
            StringDeserializer.class,
            ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG,
            StringDeserializer.class);
    try (var consumer = new KafkaConsumer<String, String>(config)) {
      consumer.subscribe(List.of(topic));
      await()
          .atMost(Duration.ofSeconds(30))
          .untilAsserted(
              () -> {
                var records = consumer.poll(Duration.ofSeconds(1));
                assertThat(records.records(topic))
                    .anySatisfy(
                        record -> {
                          assertThat(record.key()).isEqualTo(key);
                          assertThat(record.value()).contains("fixture");
                        });
              });
    }
  }

  @Test
  void s3RoundTripPreservesBytesAndDeletesObject() {
    String bucket = "smoke-" + UUID.randomUUID();
    String key = "fixture.txt";
    byte[] payload = "Nở fixture".getBytes(StandardCharsets.UTF_8);
    storage.createBucket(request -> request.bucket(bucket));
    try {
      storage.putObject(request -> request.bucket(bucket).key(key), RequestBody.fromBytes(payload));
      assertThat(storage.getObjectAsBytes(request -> request.bucket(bucket).key(key)).asByteArray())
          .isEqualTo(payload);
      storage.deleteObject(request -> request.bucket(bucket).key(key));
      org.assertj.core.api.Assertions.assertThatThrownBy(
              () -> storage.getObjectAsBytes(request -> request.bucket(bucket).key(key)))
          .isInstanceOf(NoSuchKeyException.class);
    } finally {
      storage.deleteObject(request -> request.bucket(bucket).key(key));
      storage.deleteBucket(request -> request.bucket(bucket));
    }
  }

  @Test
  void durableJobRetriesAndSucceeds() {
    jdbc.execute("create table job_smoke (id varchar(36) primary key, attempts int not null)");
    String id = UUID.randomUUID().toString();
    jdbc.update("insert into job_smoke values (?, 0)", id);
    jobServer.stop();
    var jobId = scheduler.<SmokeJob>enqueue(job -> job.run(id));
    try {
      assertThat(
              jdbc.queryForObject(
                  "select state from jobs.jobrunr_jobs where id=?", String.class, jobId.toString()))
          .isEqualTo("ENQUEUED");
    } finally {
      jobServer.start();
    }
    await()
        .atMost(Duration.ofSeconds(120))
        .untilAsserted(
            () -> {
              assertThat(
                      jdbc.queryForObject(
                          "select attempts from job_smoke where id=?", Integer.class, id))
                  .isEqualTo(2);
              assertThat(
                      jdbc.queryForObject(
                          "select state from jobs.jobrunr_jobs where id=?",
                          String.class,
                          jobId.toString()))
                  .isEqualTo("SUCCEEDED");
            });
  }

  @TestConfiguration
  static class SmokeConfiguration {
    @Bean
    SmokeJob smokeJob(JdbcTemplate jdbc) {
      return new SmokeJob(jdbc);
    }
  }

  public static class SmokeJob {
    private final JdbcTemplate jdbc;

    public SmokeJob(JdbcTemplate jdbc) {
      this.jdbc = jdbc;
    }

    public void run(String id) {
      int attempts =
          jdbc.queryForObject(
              "update job_smoke set attempts=attempts+1 where id=? returning attempts",
              Integer.class,
              id);
      if (attempts == 1) {
        throw new IllegalStateException("Expected fixture failure to verify retry");
      }
    }
  }
}
