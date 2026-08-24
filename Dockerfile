FROM asciidoctor/docker-asciidoctor:1.106
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
