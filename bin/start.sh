#!/bin/sh

bin/crawler eval "Crawler.ReleaseTasks.migrate()"

bin/crawler start
