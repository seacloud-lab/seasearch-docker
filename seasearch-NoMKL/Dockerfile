FROM linuxcontainers/debian-slim:12
ARG VERSION
ARG COMMIT_HASH
ARG BUILD_DATE

RUN echo "deb http://cdn-fastly.deb.debian.org/debian stable main \
deb http://cdn-fastly.deb.debian.org/debian-security stable-security main \
deb http://cdn-fastly.deb.debian.org/debian-security-debug stable-security-debug main" > /etc/apt/sources.list

RUN apt-get update --fix-missing
RUN apt-get install -y libgomp1
RUN apt-get install -y libatlas-base-dev libatlas3-base

RUN mkdir -p /opt/scripts
COPY opt /opt
COPY entrypoint.sh /opt/scripts/entrypoint.sh
RUN chmod +x /opt/scripts/entrypoint.sh
RUN ln -s /opt/faiss/build/c_api/libfaiss_c.so /usr/lib/libfaiss_c.so
RUN ln -s /opt/faiss/build/faiss/libfaiss.so /usr/lib/libfaiss.so
CMD ["bash", "-c", "/opt/scripts/entrypoint.sh"]
