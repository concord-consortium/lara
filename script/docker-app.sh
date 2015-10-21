#!/bin/bash


# spring binstub --all
rake db:migrate
rails s -b 0.0.0.0
