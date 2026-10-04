package com.dorriss.no.common.health;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Schema;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HealthController {
  @Operation(operationId = "getHealth", summary = "Kiểm tra tiến trình API")
  @GetMapping("/api/v1/health")
  public HealthResponse health() {
    return new HealthResponse("no-api", "UP");
  }

  public record HealthResponse(
      @Schema(requiredMode = Schema.RequiredMode.REQUIRED, allowableValues = "no-api")
          String service,
      @Schema(requiredMode = Schema.RequiredMode.REQUIRED, allowableValues = "UP") String status) {}
}
