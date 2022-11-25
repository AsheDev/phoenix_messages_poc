#!/bin/bash

# RAILS_ENV=development
mix ecto.create
mix ecto.migrate

mix phx.server
