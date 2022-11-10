#!/usr/bin/env bash
set -e

heroku pg:backups:download
pg_restore --verbose --clean --no-acl --no-owner -h localhost -d agiledata latest.dump
