#!/bin/sh

release_ctl eval --mfa "Phlink.ReleaseTasks.migrate/1" --argv -- "$@"
