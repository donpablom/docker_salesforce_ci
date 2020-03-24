FROM ubuntu:18.04

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

# Update apt-get set locales
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl ca-certificates locales \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_VERSION jdk-12.0.2+10
# Install Java jdk-12.0.2+10
RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    case "${ARCH}" in \
       aarch64|arm64) \
         ESUM='855f046afc5a5230ad6da45a5c811194267acd1748f16b648bfe5710703fe8c6'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk12-binaries/releases/download/jdk-12.0.2%2B10/OpenJDK12U-jdk_aarch64_linux_hotspot_12.0.2_10.tar.gz'; \
         ;; \
       armhf) \
         ESUM='9fec85826ffb7b2b2cf2853a6ed3e001b528ed5cf13e435cd13026398b5178d8'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk12-binaries/releases/download/jdk-12.0.2%2B10/OpenJDK12U-jdk_arm_linux_hotspot_12.0.2_10.tar.gz'; \
         ;; \
       ppc64el|ppc64le) \
         ESUM='4b0c9f5cdea1b26d7f079fa6478aceebf1923c947c4209d5709c0869dd71b98f'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk12-binaries/releases/download/jdk-12.0.2%2B10/OpenJDK12U-jdk_ppc64le_linux_hotspot_12.0.2_10.tar.gz'; \
         ;; \
       s390x) \
         ESUM='9897deeaf7a2c90374fbaca8b3eb8e63267d8fc1863b43b21c0bfc86e4783470'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk12-binaries/releases/download/jdk-12.0.2%2B10/OpenJDK12U-jdk_s390x_linux_hotspot_12.0.2_10.tar.gz'; \
         ;; \
       amd64|x86_64) \
         ESUM='1202f536984c28d68681d51207a84b6c76e5998579132d3fe1b8085aa6a5f21e'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk12-binaries/releases/download/jdk-12.0.2%2B10/OpenJDK12U-jdk_x64_linux_hotspot_12.0.2_10.tar.gz'; \
         ;; \
       *) \
         echo "Unsupported arch: ${ARCH}"; \
         exit 1; \
         ;; \
    esac; \
    curl -LfsSo /tmp/openjdk.tar.gz ${BINARY_URL}; \
    echo "${ESUM} */tmp/openjdk.tar.gz" | sha256sum -c -; \
    mkdir -p /opt/java/openjdk; \
    cd /opt/java/openjdk; \
    tar -xf /tmp/openjdk.tar.gz --strip-components=1; \
    rm -rf /tmp/openjdk.tar.gz;

# Install git curl python3 etc..
RUN apt-get update \
	&& apt-get install -y \
		build-essential \
        curl \
        git \
        maven \
        ant \
        unzip \
		python3 \
	&& rm -rf /var/lib/apt/lists/*

# Set paths and 
ENV NODE_VERSION=8.9.4 \
    NVM_DIR=/root/.nvm \
    NVM_VERSION=0.33.8 \
	JAVA_HOME=/opt/java/openjdk \
    PATH="/opt/java/openjdk/bin:$PATH"
	
# Install nvm with node and npm
RUN curl https://raw.githubusercontent.com/creationix/nvm/v$NVM_VERSION/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

# Set node path
ENV NODE_PATH=$NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV ANT_HOME /usr/share/java/apache-ant
ENV PATH $PATH:$ANT_HOME/bin
ENV PATH=$NVM_DIR:$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

RUN npm install -g npm
RUN npm install -g sfdc-generate-package
RUN npm install -g jsforce