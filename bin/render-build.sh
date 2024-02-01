#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
rails db:schema:load
./bin/rails assets:precompile
./bin/rails assets:clean