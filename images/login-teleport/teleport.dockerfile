# syntax=docker.io/docker/dockerfile-upstream:1.20.0

FROM cr.eu-north1.nebius.cloud/soperator/login_sshd:4.0.1-slurm25.11.3

ARG TELEPORT_VERSION=18.8.2

RUN sed -i '/messagebus/d' /var/lib/dpkg/statoverride && \
    curl -fsSL "https://cdn.teleport.dev/teleport_${TELEPORT_VERSION}_amd64.deb" -o /tmp/teleport.deb && \
    dpkg -i /tmp/teleport.deb && \
    rm /tmp/teleport.deb

COPY images/login-teleport/teleport_entrypoint.sh /opt/bin/slurm/
RUN chmod +x /opt/bin/slurm/teleport_entrypoint.sh

ENTRYPOINT ["/opt/bin/slurm/teleport_entrypoint.sh"]
