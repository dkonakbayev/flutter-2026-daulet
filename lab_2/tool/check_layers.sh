#!/usr/bin/env sh
# R10: package:http may appear only in core/api and in *_repository.dart.
# Prints nothing when the layers are clean.
grep -rl "package:http" lib/ | grep -vE '(lib/core/api/|_repository\.dart$)'
exit 0
