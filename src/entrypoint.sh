#!/bin/bash
set -e

printenv

ruby /home/runner/ensure_ticket_status_on_pull_request.rb
