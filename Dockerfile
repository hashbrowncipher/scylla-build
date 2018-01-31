FROM ubuntu:16.04
RUN apt-get update && apt-get install -y python3 build-essential
ADD thrift /build/thrift
# Thrift deps
RUN apt-get install -y \
  automake bison flex g++ libboost-all-dev libevent-dev libssl-dev libtool make pkg-config
WORKDIR /build/thrift
RUN ./bootstrap.sh
RUN ./configure
RUN make -j4
RUN make install
ADD antlr3 /build/antlr3
# antlr3 deps
RUN apt-get install -y maven openjdk-8-jdk-headless
WORKDIR /build/antlr3
RUN mvn package -DskipTests
RUN cp runtime/Cpp/include/* /usr/include
ADD antlr3.bin /usr/local/bin/antlr3
ADD scylla /build/scylla
# Seastar
RUN apt-get install -y \
  libgnutls-dev cmake ragel
# Scylla/Unknown
RUN apt-get install -y \
  ninja-build libunwind-dev libcrypto++-dev python3 pkg-config \
  libsystemd-dev python3-pyparsing libsnappy-dev libjsoncpp-dev libyaml-cpp-dev \
  # used to determine current version
  git \
  # c-ares?
  libsctp-dev \
  libprotobuf-dev protobuf-compiler \
  liblz4-dev \
  # wtf?
  xfslibs-dev \
  systemtap-sdt-dev \
  libxml2-dev libpciaccess-dev \
  libaio-dev
WORKDIR /build/scylla
RUN ./configure.py
RUN ninja
