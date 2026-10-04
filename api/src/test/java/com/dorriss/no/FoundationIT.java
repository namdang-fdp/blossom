package com.dorriss.no;

import static org.assertj.core.api.Assertions.assertThat;

import java.nio.file.Files;
import java.nio.file.Path;
import org.flywaydb.core.Flyway;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.annotation.DirtiesContext;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

@Testcontainers
@DirtiesContext(classMode = DirtiesContext.ClassMode.AFTER_CLASS)
@ActiveProfiles("local")
@SpringBootTest(
    webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
    properties = {
      "jobrunr.background-job-server.enabled=false",
      "management.health.redis.enabled=false"
    })
class FoundationIT {
  @Container static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:18.6");

  @DynamicPropertySource
  static void database(DynamicPropertyRegistry registry) {
    registry.add("spring.datasource.url", postgres::getJdbcUrl);
    registry.add("spring.datasource.username", postgres::getUsername);
    registry.add("spring.datasource.password", postgres::getPassword);
  }

  @TempDir Path migrationDirectory;

  @Autowired TestRestTemplate http;
  @Autowired JdbcTemplate jdbc;

  @Test
  void migrationsAndDatabaseReadinessWork() {
    assertThat(
            http.getForEntity("/actuator/health/readiness", String.class).getStatusCode().value())
        .isEqualTo(200);
    assertThat(
            jdbc.queryForObject(
                "select count(*) from flyway_schema_history where version='1' and success",
                Integer.class))
        .isEqualTo(1);
    assertThat(jdbc.queryForObject("select count(*) from jobs.jobrunr_jobs", Integer.class))
        .isZero();
  }

  @Test
  void healthMatchesPublicContract() {
    var response = http.getForEntity("/api/v1/health", String.class);
    assertThat(response.getStatusCode().value()).isEqualTo(200);
    assertThat(response.getBody()).contains("\"service\":\"no-api\"", "\"status\":\"UP\"");
  }

  @Test
  void changedMigrationIsRejectedAndHistoryIsPreserved() throws Exception {
    Path script = migrationDirectory.resolve("V1__probe.sql");
    Files.writeString(script, "create table probe(id integer primary key);");
    var flyway =
        Flyway.configure()
            .dataSource(postgres.getJdbcUrl(), postgres.getUsername(), postgres.getPassword())
            .schemas("migration_probe")
            .locations("filesystem:" + migrationDirectory)
            .load();
    assertThat(flyway.migrate().migrationsExecuted).isEqualTo(1);
    assertThat(flyway.migrate().migrationsExecuted).isZero();
    Files.writeString(script, "create table probe(id bigint primary key);");
    assertThat(flyway.validateWithResult().validationSuccessful).isFalse();
    org.assertj.core.api.Assertions.assertThatThrownBy(flyway::migrate)
        .isInstanceOf(org.flywaydb.core.api.exception.FlywayValidateException.class);
    assertThat(
            jdbc.queryForObject(
                "select count(*) from migration_probe.flyway_schema_history where version='1' and success",
                Integer.class))
        .isEqualTo(1);
  }

  @Test
  void healthDoesNotExposeConnectionDetails() {
    var response = http.getForEntity("/actuator/health", String.class);
    assertThat(response.getStatusCode().value()).isEqualTo(200);
    assertThat(response.getBody()).contains("UP").doesNotContain("components", "jdbc:", "password");
  }
}
