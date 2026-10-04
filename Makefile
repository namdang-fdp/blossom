.PHONY: setup infra app stop format test check
setup:
	bash scripts/setup-precommit.sh
infra:
	docker compose up -d --wait postgres redis kafka minio kafka-ui dozzle
	docker compose --profile app run --rm minio-init
app:
	docker compose --profile app up -d --build
stop:
	docker compose --profile app down
format:
	cd api && ./mvnw -B -ntp spotless:apply
test:
	cd api && ./mvnw -B -ntp test
check:
	cd api && ./mvnw -B -ntp verify
