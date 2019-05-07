#!/usr/bin/env bash

# TODO(dotdoom): move this into fastlane.

set -e

install_debug_keys() {
	# These files are neccessary to build debug version of the app. There
	# are no real secrets inside.
	cp tools/ci/google-services.json \
	   flutter/android/app/google-services.json
	cp tools/ci/org.dasfoo.delern.debug \
	   flutter/ios/Runner/GoogleService-Info/org.dasfoo.delern.debug
	mkdir -p "${HOME?}/.android"
	cp tools/ci/debug.keystore "${HOME?}/.android/debug.keystore"
}

cd "$(dirname "$0")/.."
"${1?method name is required}"
