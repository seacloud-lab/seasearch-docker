# build Seasearch
FROM intel/oneapi-basekit:2025.3.2-0-devel-ubuntu24.04
ARG VERSION
ARG COMMIT_HASH
ARG BUILD_DATE

#develop env.
RUN sed -i 's/http:\/\/mirrors.aliyun.com/http:\/\/mirrors.cloud.aliyuncs.com/g' /etc/apt/sources.list


RUN apt-get update --fix-missing
RUN apt-get install -y gcc g++
RUN apt-get install -y wget swig libomp-dev
RUN apt-get install -y git
RUN whereis cmake
RUN apt-get remove -y cmake
RUN mkdir -p /opt/cmake
COPY lib/cmake-4.0.2-linux-x86_64.sh /opt/cmake/cmake-4.0.2-linux-x86_64.sh
WORKDIR /opt/cmake
RUN bash cmake-4.0.2-linux-x86_64.sh --skip-license
RUN ln -s /opt/cmake/bin/cmake /usr/local/bin/cmake
RUN cmake --version

#node.
RUN apt-get install -y ca-certificates gnupg curl apt-transport-https
RUN apt-get install -y libpython3-stdlib libpython3.12-minimal libpython3.12-stdlib media-types
RUN mkdir -p /opt/node
COPY lib/node-v22.16.0-linux-x64.tar.xz /opt/node/node-v22.16.0-linux-x64.tar.xz
WORKDIR /opt/node
RUN tar -xJvf node-v22.16.0-linux-x64.tar.xz
RUN ln -s /opt/node/node-v22.16.0-linux-x64/bin/node /usr/local/bin/node
RUN ln -s /opt/node/node-v22.16.0-linux-x64/bin/npm /usr/local/bin/npm


#test node and npm
RUN node --version
RUN npm --version
RUN npm config set registry https://registry.npmmirror.com 

# build faiss
RUN wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB \
    | gpg --dearmor | tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null
RUN echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | tee /etc/apt/sources.list.d/oneAPI.list

#copy
RUN mkdir -p /opt/faiss /opt/seasearch /opt/scripts
COPY faiss /opt/faiss
COPY gflags /opt/gflags
COPY build.sh /opt/scripts/build.sh

#compile
## gflags
WORKDIR /opt/gflags
RUN mkdir build
WORKDIR /opt/gflags/build
RUN cmake -DBUILD_SHARED_LIBS=ON -DBUILD_STATIC_LIBS=ON -DINSTALL_HEADERS=ON -DINSTALL_SHARED_LIBS=ON -DINSTALL_STATIC_LIBS=ON ..
RUN make -j2
RUN make install

## faiss
WORKDIR /opt/faiss
RUN cmake -B build -DFAISS_ENABLE_GPU=OFF \
    -DFAISS_ENABLE_C_API=ON \
    -DFAISS_ENABLE_PYTHON=OFF \
    -DBLA_VENDOR=Intel10_64_dyn  \
    -DBUILD_SHARED_LIBS=ON \
    "-DMKL_LIBRARIES=-Wl,--start-group;/opt/intel/oneapi/mkl/latest/lib/intel64/libmkl_intel_lp64.a;/opt/intel/oneapi/mkl/latest/lib/intel64/libmkl_gnu_thread.a;/opt/intel/oneapi/mkl/latest/lib/intel64/libmkl_core.a;-Wl,--end-group" \
    .
RUN make -C build
RUN make -C build install
RUN ln -s /opt/faiss/build/c_api/libfaiss_c.so /usr/lib/libfaiss_c.so

#set golang proxy
RUN mkdir -p /opt/go
COPY lib/go1.24.3.linux-amd64.tar.gz /opt/go/go1.24.3.linux-amd64.tar.gz
WORKDIR /opt/go
RUN tar -zxvf go1.24.3.linux-amd64.tar.gz
RUN ln -s /opt/go/go/bin/go /usr/local/bin/go
RUN go env -w GOPROXY=https://goproxy.cn

