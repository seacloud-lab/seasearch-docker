FROM ubuntu:24.04
ARG VERSION
ARG COMMIT_HASH
ARG BUILD_DATE

RUN apt-get update --fix-missing
RUN apt-get install -y libgomp1 ca-certificates wget
RUN apt-get install -y libatlas-base-dev libatlas3-base

RUN wget https://github.com/unum-cloud/USearch/releases/download/v2.26.0/usearch_linux_amd64_2.26.0.deb
RUN apt install -y ./usearch_linux_amd64_2.26.0.deb
RUN rm usearch_linux_amd64_2.26.0.deb

RUN mkdir -p /opt/scripts
COPY opt /opt
COPY entrypoint.sh /opt/scripts/entrypoint.sh
RUN chmod +x /opt/scripts/entrypoint.sh
RUN ln -s /opt/faiss/build/c_api/libfaiss_c.so /usr/lib/libfaiss_c.so
RUN ln -s /opt/faiss/build/faiss/libfaiss.so /usr/lib/libfaiss.so
CMD ["bash", "-c", "/opt/scripts/entrypoint.sh"]
