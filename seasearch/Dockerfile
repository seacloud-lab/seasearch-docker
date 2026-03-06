FROM antrea/ubuntu:24.04
ARG VERSION
ARG COMMIT_HASH
ARG BUILD_DATE

RUN apt-get update --fix-missing
RUN apt-get install -y libgomp1 ca-certificates

RUN mkdir -p /opt/scripts
COPY opt/faiss /opt/faiss
COPY opt/seasearch /opt/seasearch
COPY entrypoint/seasearch.sh /opt/scripts/entrypoint.sh
RUN chmod +x /opt/scripts/entrypoint.sh
RUN ln -s /opt/faiss/build/c_api/libfaiss_c.so /usr/lib/libfaiss_c.so
RUN ln -s /opt/faiss/build/faiss/libfaiss.so /usr/lib/libfaiss.so
CMD ["bash", "-c", "/opt/scripts/entrypoint.sh"]
