FROM fj0rd/io:rs as build

RUN cargo install mdbook mdbook-epub \
 && strip /opt/cargo/bin/mdbook \
 && strip /opt/cargo/bin/mdbook-epub

FROM debian:bullseye-slim

COPY --from=build /opt/cargo/bin/mdbook /opt/cargo/bin/mdbook-epub /usr/local/bin
