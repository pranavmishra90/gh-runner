# base image
FROM pranavmishra90/facsimilab-main:dev AS base

#input GitHub runner version argument
ARG RUNNER_VERSION='2.319.1'
ENV DEBIAN_FRONTEND=noninteractive

USER root

# update the base packages + add a non-sudo user
RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update -y && apt-get upgrade -y  && \
    apt-get install -y --no-install-recommends \
    curl nodejs wget unzip vim git jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip && \
    curl -sL https://aka.ms/InstallAzureCLIDeb | bash

RUN useradd -u 1050 -g docker -m docker

# cd into the user directory, download and unzip the github actions runner
RUN --mount=type=cache,target=/var/cache/apt \
    cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Install Docker
RUN --mount=type=cache,target=/var/cache/apt \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc  && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# install some additional dependencies
RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

FROM base AS final

ARG CACHEBUST=1
RUN echo "Cache breaker: $CACHEBUST" > /dev/null

# get random text
RUN curl "https://www.random.org/integers/?num=100&min=1&max=100&col=5&base=10&format=plain&rnd=new" > random.txt
# add over the start.sh script
ADD scripts/start.sh start.sh

# make the script executable
RUN chmod +x start.sh

# set the user to "docker" so all subsequent commands are run as the docker user
USER docker

# set the entrypoint to the start.sh script
ENTRYPOINT ["./start.sh"]

ARG ISO_DATEIME
LABEL org.opencontainers.image.title="Modified FacsimiLab Main Runner"
LABEL org.opencontainers.image.authors='Pranav Kumar Mishra'
LABEL org.opencontainers.image.description="A modified version of ubuntu:22.04 to be used as a github actions runner"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.created=${ISO_DATETIME}
LABEL org.opencontainers.image.base.name="ubuntu:22.04"
LABEL version=${RUNNER_VERSION}
LABEL org.opencontainers.image.version=${RUNNER_VERSION}