#!/bin/bash
set -e

printenv

ruby ensure_ticket_status_on_pull_request.rb
