FROM asciidoctor/docker-asciidoctor:1.99
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
