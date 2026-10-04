package com.dorriss.no.infrastructure.storage;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.net.URI;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.validation.annotation.Validated;

@Validated
@ConfigurationProperties(prefix = "no.storage")
public record StorageProperties(
    @NotNull URI endpoint,
    @NotBlank String region,
    @NotBlank String accessKey,
    @NotBlank String secretKey,
    @NotBlank String bucket) {}
