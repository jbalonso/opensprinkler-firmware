FROM debian:bookworm-slim as base

########################################
## 1st stage compiles OpenSprinkler code
FROM base as os-build

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y bash g++ make libgpiod-dev libmosquittopp-dev && rm -rf /var/lib/apt/lists/*
COPY . /OpenSprinkler
RUN cd /OpenSprinkler && make

########################################
## 2nd stage is minimal runtime + executable
FROM base

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y libstdc++6 libgpiod2 libmosquittopp1 && rm -rf /var/lib/apt/lists/* \
    && \
    mkdir /OpenSprinkler && \
    mkdir -p /data/logs

COPY --from=os-build /OpenSprinkler/OpenSprinkler /OpenSprinkler/OpenSprinkler
WORKDIR /OpenSprinkler

#-- Logs and config information go into the volume on /data
VOLUME /data

#-- OpenSprinkler interface is available on 8080
EXPOSE 8080

#-- By default, start OS using /data for saving data/NVM/log files
CMD [ "/OpenSprinkler/OpenSprinkler", "-d", "/data/" ]
