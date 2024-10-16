#!/bin/bash
# Exit on error.
set -e
# Allow ** globs, ignore empty globs
shopt -s extglob globstar nullglob

EX_USAGE=64 # Usage error exit code from /usr/include/sysexits.h

OUTPUT_FORMAT=
ASCIIDOCTOR_ARGS=

while getopts ":f:a:" arg; do
  case "${arg}" in
    f)
      OUTPUT_FORMAT=${OPTARG}
      ;;
    a)
      ASCIIDOCTOR_ARGS=${OPTARG}
      ;;
    *)
      break
      ;;
  esac
done
shift $((OPTIND-1))

read -r INPUT_FILES <<<$*

ASCIIDOCTOR=asciidoctor
if [[ "pdf" = $OUTPUT_FORMAT ]]; then
  ASCIIDOCTOR=asciidoctor-pdf
elif [[ "epub" == $OUTPUT_FORMAT ]]; then
  ASCIIDOCTOR=asciidoctor-epub3
elif [[ "kf8" == $OUTPUT_FORMAT ]]; then
  ASCIIDOCTOR="asciidoctor-epub3 -a ebook-format=kf8"
fi

if [[ -z $INPUT_FILES ]]; then
  printf "No input files specified\n" >&2
  exit $EX_USAGE
fi

#COMMAND=$(echo "$ASCIIDOCTOR -R . -D $GITHUB_WORKSPACE/asciidoc-out -r asciidoctor-diagram -a mermaid-puppeteer-config=/mermaid/puppeteer-config.json -a source-highlighter@=rouge" $ASCIIDOCTOR_ARGS $INPUT_FILES)
COMMAND=$(echo "$ASCIIDOCTOR -R . -D $GITHUB_WORKSPACE/asciidoc-out -r asciidoctor-diagram -r asciidoctor-mathematical" $ASCIIDOCTOR_ARGS $INPUT_FILES)
echo "Running '$COMMAND'"

# TEST env variable indicates we should be in testing mode (below).
mkdir $GITHUB_WORKSPACE/asciidoc-out
eval $COMMAND
OUTPUT=

FILES=$(echo $GITHUB_WORKSPACE/asciidoc-out/**/*)
echo "name=asciidoctor-artifacts::asciidoc-out" >> $GITHUB_OUTPUT
echo "Generated files $FILES"

if [[ -z $TEST_COMMAND && -z $TEST_OUTPUT ]]; then
  echo "Output:"
  echo "${OUTPUT}"
  echo "Output ${OUTPUT}"
elif [[ "${COMMAND}" != "${TEST_COMMAND}" ]]; then
  printf "Ran unexpected command:\n" >&2
  diff <(echo "${COMMAND}") <(echo "${TEST_COMMAND}") >&2
  exit 1
elif [[ "${OUTPUT}" != "${TEST_OUTPUT}" ]]; then
  printf "Printed unexpected output:\n" >&2
  diff <(echo "${OUTPUT}") <(echo "${TEST_OUTPUT}") >&2
  exit 1
else
  echo "Command equals test expectations:"
  echo "${TEST_COMMAND}"
  echo "And output equals test expectations:"
  echo "${TEST_OUTPUT}"
  exit 0
fi
