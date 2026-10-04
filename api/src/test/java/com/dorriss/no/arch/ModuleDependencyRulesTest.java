package com.dorriss.no.arch;

import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.noClasses;
import static org.assertj.core.api.Assertions.assertThat;

import com.tngtech.archunit.core.domain.JavaClasses;
import com.tngtech.archunit.core.importer.ClassFileImporter;
import com.tngtech.archunit.core.importer.ImportOption;
import org.junit.jupiter.api.Test;

class ModuleDependencyRulesTest {
  private final JavaClasses classes =
      new ClassFileImporter()
          .withImportOption(ImportOption.Predefined.DO_NOT_INCLUDE_TESTS)
          .importPackages("com.dorriss.no");

  @Test
  void commonAndInfrastructureStayIndependentOfBusinessModules() {
    assertThat(classes.contain("com.dorriss.no.common.health.HealthController")).isTrue();
    assertThat(classes.contain("com.dorriss.no.infrastructure.storage.S3Config")).isTrue();
    noClasses()
        .that()
        .resideInAnyPackage("com.dorriss.no.common..", "com.dorriss.no.infrastructure..")
        .should()
        .dependOnClassesThat()
        .resideInAPackage("com.dorriss.no.modules..")
        .check(classes);
  }
}
