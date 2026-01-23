FROM apache/superset:latest

USER root

RUN usermod -aG root superset

COPY ./superset-init.sh /superset-init.sh
RUN chmod +x /superset-init.sh

COPY --chown=superset superset_config.py /app/
ENV SUPERSET_CONFIG_PATH /app/superset_config.py

RUN /app/.venv/bin/python -m ensurepip && \
    /app/.venv/bin/pip3 install --no-cache-dir --upgrade pip && \
    /app/.venv/bin/pip3 install --no-cache-dir snowflake-sqlalchemy

USER superset

ENTRYPOINT [ "/superset-init.sh" ]