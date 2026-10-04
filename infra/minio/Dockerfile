FROM alpine:3.22.3

RUN apk add --no-cache ca-certificates curl

# Keep the original releases; official registry images and dl.min.io are unavailable.
# Checksums are from the matching official GitHub release assets.
RUN set -eu; \
    case "$(apk --print-arch)" in \
      x86_64) arch=amd64; \
        minio_sha=7c5bd8512c6e966455b1d198209358b2d191c77a83ab377c4073281065fb855f; \
        mc_sha=01f866e9c5f9b87c2b09116fa5d7c06695b106242d829a8bb32990c00312e891 ;; \
      aarch64) arch=arm64; \
        minio_sha=5c83cd2cf151717ba0243f73e1c7802ff36e272b67144bdd7f1f7d684fd6f03d; \
        mc_sha=14c8c9616cfce4636add161304353244e8de383b2e2752c0e9dad01d4c27c12c ;; \
      *) echo "Unsupported MinIO architecture" >&2; exit 1 ;; \
    esac; \
    curl -fSL --retry 3 \
      "https://github.com/minio/minio/releases/download/RELEASE.2025-09-07T16-13-09Z/minio.linux-${arch}.RELEASE.2025-09-07T16-13-09Z" \
      -o /usr/local/bin/minio; \
    echo "${minio_sha}  /usr/local/bin/minio" | sha256sum -c -; \
    curl -fSL --retry 3 \
      "https://github.com/minio/mc/releases/download/RELEASE.2025-08-13T08-35-41Z/mc.linux-${arch}.RELEASE.2025-08-13T08-35-41Z" \
      -o /usr/local/bin/mc; \
    echo "${mc_sha}  /usr/local/bin/mc" | sha256sum -c -; \
    chmod +x /usr/local/bin/minio /usr/local/bin/mc

EXPOSE 9000 9001
ENTRYPOINT ["minio"]
CMD ["server", "/data", "--console-address", ":9001"]
