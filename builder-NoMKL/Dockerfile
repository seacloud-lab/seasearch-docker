# build Seasearch
FROM golang:1.26-bookworm
ARG VERSION
ARG COMMIT_HASH
ARG BUILD_DATE

#develop env.
RUN apt-get update
RUN apt-get install -y gcc g++
RUN apt-get install -y cmake
RUN apt-get install -y wget swig libomp-dev
RUN apt-get install -y libatlas-base-dev libatlas3-base

#node.
RUN apt-get install -y ca-certificates gnupg curl apt-transport-https
RUN apt-get install -y libpython3-stdlib libpython3.11-minimal libpython3.11-stdlib media-types
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN curl -sL https://deb.nodesource.com/setup_26.x | bash -
RUN apt-get install -y nodejs

#test node and npm
RUN node --version
RUN npm --version
RUN npm config set registry https://registry.npmmirror.com 

#copy
RUN mkdir -p /opt/faiss /opt/seasearch /opt/scripts
COPY faiss /opt/faiss
COPY build.sh /opt/scripts/build.sh

# usearch
COPY usearch_linux_amd64_2.26.0.deb /tmp/usearch_linux_amd64_2.26.0.deb
RUN apt install /tmp/usearch_linux_amd64_2.26.0.deb

#compile
WORKDIR /opt/faiss
RUN cmake -B build -DFAISS_ENABLE_GPU=OFF \
    -DFAISS_ENABLE_C_API=ON \
    -DFAISS_ENABLE_PYTHON=OFF \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_TESTING=OFF \    
    .
RUN make -C build
RUN make -C build install
RUN ln -s /opt/faiss/build/c_api/libfaiss_c.so /usr/lib/libfaiss_c.so

#set golang proxy
RUN go env -w GOPROXY=https://goproxy.cn
