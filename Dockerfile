FROM ghcr.io/sul-dlss/scriptshifter-base:latest
ARG WORKROOT="/usr/local/scriptshifter/src"

# Copy core application files.
WORKDIR ${WORKROOT}

# Copy requirements first for better caching
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY VERSION entrypoint.sh sscli uwsgi.ini wsgi.py ./
COPY scriptshifter ./scriptshifter/
COPY test ./test/

# Create cache directory
RUN mkdir -p /data/hf/datasets
ENV HF_DATASETS_CACHE=/data/hf/datasets
RUN ./sscli admin init-db

# Set permissions
RUN chmod +x ./entrypoint.sh
RUN chown -R www:www ${WORKROOT} /data

# Switch to non-root user
USER www

EXPOSE 8000

ENTRYPOINT ["./entrypoint.sh"]