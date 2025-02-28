
HUGO_OUTPUT_DIR=./docs
HUGO_OUTPUT_BRANCH=docs-build

clean:
	@rm -rf $(HUGO_OUTPUT_DIR)

generate:
	@hugo --gc --quiet --destination $(HUGO_OUTPUT_DIR)

refresh: clean generate

COMMIT_INFO=$(shell git log -1 --pretty='%h %B')

update-docs-branch: refresh
	@#
	@# Avoid losing changes when moving back to main branch since the git checkout -f is like a hard reset
	@if [ -n "$$(git diff --name-only)" ]; then echo "Aborting due to uncommitted changes"; exit 1; fi
	@if [ -n "$$(git diff --staged --name-only)" ]; then echo "Aborting due to uncommitted staged changes"; exit 1; fi
	@#
	@# Remove the existing branch and recreate it
	@git branch -D $(HUGO_OUTPUT_BRANCH) || true
	@git checkout --orphan $(HUGO_OUTPUT_BRANCH)
	@#
	@# Not sure why everything is automatically staged
	@git reset
	@#
	@# Add the generated files and make a commit
	@git add -f $(HUGO_OUTPUT_DIR)/*
	@git commit -q --no-gpg-sign -m "Docs build" -m "Built from: '$(COMMIT_INFO)'"
	@#
	@# Back to main branch
	@git checkout -f main

publish:
	@git push -f origin $(HUGO_OUTPUT_BRANCH):$(HUGO_OUTPUT_BRANCH)

republish: update-docs-branch publish

preview:
	@hugo server
