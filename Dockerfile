FROM ghcr.io/nesquena/hermes-webui:latest AS hermes_webui

FROM nousresearch/hermes-agent:latest

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends rsync locales passwd \
    && rm -rf /var/lib/apt/lists/*; \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 || true

ENV LANG=en_US.utf8 \
    LC_ALL=C \
    HERMES_HOME=/opt/data \
    HERMES_WEBUI_AGENT_DIR=/opt/hermes \
    HERMES_WEBUI_HOST=0.0.0.0 \
    HERMES_WEBUI_STATE_DIR=/opt/data/webui \
    HERMES_WEBUI_DEFAULT_WORKSPACE=/opt/data/workspace \
    API_SERVER_ENABLED=true \
    API_SERVER_HOST=0.0.0.0 \
    API_SERVER_CORS_ORIGINS=*

RUN groupadd -g 1024 hermeswebui \
    && useradd -u 1024 -d /home/hermeswebui -g hermeswebui -G users,hermes -s /bin/bash -m hermeswebui \
    && mkdir -p /app /uv_cache /workspace /opt/data/webui \
        /etc/cont-init.d \
        /etc/s6-overlay/s6-rc.d/hermes-webui/dependencies.d \
        /etc/s6-overlay/s6-rc.d/user/contents.d \
    && rm -rf /home/hermeswebui/.hermes \
    && ln -s /opt/data /home/hermeswebui/.hermes \
    && chown -R hermeswebui:hermeswebui /home/hermeswebui /app /uv_cache /workspace \
    && chown -R hermes:hermes /opt/data \
    && chmod -R ug+rwX /opt/data \
    && chmod 0755 /home/hermeswebui \
    && chmod 1777 /app /uv_cache /workspace

COPY --from=hermes_webui /apptoo /apptoo
COPY --from=hermes_webui /hermeswebui_init.bash /hermeswebui_init_original.bash
COPY docker/hermeswebui-init-wrapper.bash /hermeswebui_init.bash
COPY docker/hermes-container-start /usr/local/bin/hermes-container-start
COPY docker/hermes-webui-permissions /etc/cont-init.d/00-hermes-webui-permissions
COPY docker/hermes-webui-run /etc/s6-overlay/s6-rc.d/hermes-webui/run
COPY docker/hermes-webui-type /etc/s6-overlay/s6-rc.d/hermes-webui/type
RUN mv /usr/bin/chown /usr/bin/chown.real
COPY --chmod=0755 docker/chown-wrapper /usr/bin/chown
RUN mv /usr/bin/chmod /usr/bin/chmod.real
COPY --chmod=0755 docker/chmod-wrapper /usr/bin/chmod

RUN chmod 0755 /hermeswebui_init.bash /hermeswebui_init_original.bash \
        /usr/local/bin/hermes-container-start \
        /etc/cont-init.d/00-hermes-webui-permissions \
        /etc/s6-overlay/s6-rc.d/hermes-webui/run /usr/bin/chown \
    && touch /etc/s6-overlay/s6-rc.d/hermes-webui/dependencies.d/base \
        /etc/s6-overlay/s6-rc.d/user/contents.d/hermes-webui \
    && if [ -f /etc/s6-overlay/s6-rc.d/user/contents ]; then \
        grep -qxF hermes-webui /etc/s6-overlay/s6-rc.d/user/contents \
        || printf '%s\n' hermes-webui >> /etc/s6-overlay/s6-rc.d/user/contents; \
    fi

EXPOSE 8787 8642

CMD ["hermes-container-start"]
