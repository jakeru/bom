#!/bin/bash
set -e
npm run build
cd dist
git init
git add -A
git commit -m "Deploy"
git push -f git@github.com:jakeru/bom.git master:gh-pages
