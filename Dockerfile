FROM alpine:latest as builder
ARG BENTO4_VERSION=v1.6.0-637
LABEL maintainer="farsheed.ashouri@gmail.com"
# Install dependencies
RUN apk update && apk add --no-cache ca-certificates bash python3 make cmake gcc g++ git

RUN echo $BENTO4_VERSION

# Clone the bento4 repo
RUN git clone https://github.com/axiomatic-systems/Bento4 /tmp/bento4 \ 
    && cd /tmp/bento4  \
    && git checkout $BENTO4_VERSION

# Build
RUN rm -rf /tmp/bento4/cmakebuild \
    && mkdir -p /tmp/bento4/cmakebuild/x86_64-unknown-linux \
    && cd /tmp/bento4/cmakebuild/x86_64-unknown-linux \
    && cmake -DCMAKE_BUILD_TYPE=Release ../.. && \
    make

# Install
RUN cd /tmp/bento4 && python3 Scripts/SdkPackager.py x86_64-unknown-linux . cmake \ 
    && mkdir /opt/bento4 \
    && mv /tmp/bento4/SDK/Bento4-SDK-*.x86_64-unknown-linux/* /opt/bento4


# Stage 2 - Create the output image
FROM alpine:latest
ARG BENTO4_VERSION
LABEL version=$BENTO4_VERSION
LABEL maintainer="farsheed.ashouri@gmail.com"

# Setup environment variables
ENV PATH=/opt/bento4/bin:${PATH}

# Install Dependencies
RUN apk --no-cache add ca-certificates bash python3 libstdc++

# Copy Binaries
COPY --from=builder /opt/bento4 /opt/bento4

WORKDIR /opt/bento4

CMD ["bash"]
