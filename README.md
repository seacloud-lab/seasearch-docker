# What's seasearch-docker
SeaSearch Docker is used to build SeaSearch docker images

# How to build the seasearch builder

## Preparation

Before building the image, you have to fetch faiss, by running with the following commands:

```shell
cd builder #builder-NoMKL if the MKL is not supported by the cpu
#clone or fetch codes of faiss
git clone https://github.com/facebookresearch/faiss.git
```

In this step, please make sure you can fetch the codes from the repositories, the **github.com/faiss** and **gitlab.seafile.top/seasearch**.

## Build seasearch builder

During the step with building, the official CDN apt sources has been used. You can remove or annotate it on the **Dockerfile**. You can build the image by following commands:

```shell
docker build -t seasearch-builder .
```

Usually, the versions of faiss and go are relatively stable, and a builder image can usually be applied to multiple versions of seasearch. Therefore, in general, it is not necessary to create a new builder for new versions of seasearch.

## Build binary package

Through the seasearch builder, you can compile and package seasearch projects

```shell
#clone and fetch seasearch
git clone git@gitlab.seafile.top:seatable-dev/seasearch.git
docker run --name seasearch-builder --rm -v {you_seasearch_code_dir}:/opt/seasearch -it seasearch-builder bash /opt/scripts/build.sh {version}
```

The result binary file is {you_seasearch_code_dir}/seasearch-{version}.tar.gz

## Build seasearch docker image
Build seasearch docker image use the following commands

```shell
mv {you_seasearch_code_dir}/seasearch-{version}.tar.gz seasearch/seasearch-{version}.tar.gz
cd seasearch #seasearch-NoMKL if the MKL is not supported by your cpu
tar -zxvf seasearch-{version}.tar.gz
docker build -t seasearch:{version} .
```

## Start seasearch server

You have to specify the port used by seasearch in running seasearch docker image, and **4080** is default. At the same time, We highly recommend that map **/opt/seasearch/data** to the host (i.e., **host_dir**) to achieve data persistence. For example:

```shell
docker run --name seasearch --rm \  
  -v /path/to/host/data:/opt/seasearch/data \  
  -p 4080:4080 \  
  -e ZINC_FIRST_ADMIN_USER=admin \  
  -e ZINC_FIRST_ADMIN_PASSWORD=password \
  seasearch:{version}
```