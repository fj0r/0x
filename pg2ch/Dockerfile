FROM fj0rd/go as build

ENV GO111MODULE=off
RUN go get -u github.com/mkabilov/pg2ch

FROM fj0rd/io:base

COPY --from=build /root/go/bin/pg2ch /usr/local/bin/

ENTRYPOINT ["pg2ch", "-config", "/config.yaml"]
