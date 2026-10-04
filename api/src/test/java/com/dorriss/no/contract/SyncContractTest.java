package com.dorriss.no.contract;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.stream.Stream;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.MethodSource;

class SyncContractTest {
  private static final ObjectMapper JSON = new ObjectMapper();

  static Stream<JsonNode> sharedCases() throws Exception {
    Path directory =
        Path.of(SyncContractTest.class.getResource("/contracts/fixtures/sync").toURI());
    try (var paths = Files.list(directory)) {
      var cases = new java.util.ArrayList<JsonNode>();
      for (var path : paths.filter(p -> p.toString().endsWith(".json")).sorted().toList()) {
        JSON.readTree(path.toFile()).forEach(cases::add);
      }
      return cases.stream();
    }
  }

  @ParameterizedTest(name = "fixture {index}")
  @MethodSource("sharedCases")
  void sharedWireCorpusRoundTripsOrRejectsInvalidInput(JsonNode fixture) throws Exception {
    String schema = fixture.path("schema").asText();
    JsonNode body = fixture.path("body");
    if (!fixture.path("valid").asBoolean()) {
      assertThatThrownBy(() -> SyncContractSamples.decode(schema, body.toString()))
          .as(fixture.path("name").asText())
          .isInstanceOf(Exception.class);
      return;
    }
    Object dto = SyncContractSamples.decode(schema, body.toString());
    assertThat(dto).isNotInstanceOf(java.util.Map.class);
    JsonNode encoded = JSON.readTree(JSON.writeValueAsString(dto));
    assertThat(encoded).as(fixture.path("name").asText()).isEqualTo(body);
  }

  @Test
  void retryPreservesResultsAndPartialSuccessKeepsOtherOperationsPending() throws Exception {
    var cases = sharedCases().toList();
    var mixed =
        cases.stream()
            .filter(c -> c.path("name").asText().equals("mixed-response"))
            .findFirst()
            .orElseThrow();
    var retry =
        cases.stream()
            .filter(c -> c.path("name").asText().equals("duplicate-response"))
            .findFirst()
            .orElseThrow();
    var dto =
        (SyncContractSamples.PushResponse)
            SyncContractSamples.decode("PushResponse", mixed.path("body").toString());
    assertThat(dto.results()).hasSize(3);
    assertThat(dto.results().stream().filter(a -> a instanceof SyncContractSamples.AppliedAck))
        .hasSize(1);
    assertThat(retry.path("body").path("results")).isEqualTo(mixed.path("body").path("results"));
  }

  @Test
  void duplicateOperationIdsInOneBatchAreRejected() throws Exception {
    JsonNode request =
        sharedCases()
            .filter(c -> c.path("name").asText().equals("mixed-request"))
            .findFirst()
            .orElseThrow()
            .path("body")
            .deepCopy();
    var operations = (com.fasterxml.jackson.databind.node.ArrayNode) request.path("operations");
    operations.add(operations.get(0).deepCopy());
    assertThatThrownBy(() -> SyncContractSamples.decode("PushRequest", request.toString()))
        .isInstanceOf(IllegalArgumentException.class);
  }
}
