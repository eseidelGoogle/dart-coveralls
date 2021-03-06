#!/bin/bash

# Fast fail the script on failures.
set -e

dartanalyzer bin/dart_coveralls.dart lib/dart_coveralls.dart

dart --checked test/test_all.dart

# Install dart_coveralls; gather and send coverage data.
if [ "$COVERALLS_TOKEN" ] && [ "$TRAVIS_DART_VERSION" = "stable" ]; then
  echo "Running coverage..."
  dart bin/dart_coveralls.dart report \
    --retry 2 \
    --exclude-test-files \
    --debug \
    test/test_all.dart
  echo "Coverage complete."
else
  if [ -z ${COVERALLS_TOKEN+x} ]; then echo "COVERALLS_TOKEN is unset"; fi
  if [ -z ${TRAVIS_DART_VERSION+x} ]; then
    echo "TRAVIS_DART_VERSION is unset";
  else
    echo "TRAVIS_DART_VERSION is $TRAVIS_DART_VERSION";
  fi

  echo "Skipping coverage for this configuration."
fi
