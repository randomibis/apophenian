
HUGO_OUTPUT_DIR=./docs
HUGO_OUTPUT_BRANCH=docs-build

clean:
	@rm -rf $(HUGO_OUTPUT_DIR)

generate:
	@hugo --gc --quiet --destination $(HUGO_OUTPUT_DIR)

refresh: clean generate

COMMIT_SHA=$(shell git log -1 --pretty='%h')
COMMIT_INFO=$(shell git log -1 --pretty='%B')

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
	@# Create the CNAME file so the GitHub pages custom domain works
	@echo "apophenian.art" > docs/CNAME
	@#
	@# Make a little readme file
	@echo -e "# Docs build\n\nOrphan branch and commit with content built from $(COMMIT_SHA) in main branch." > README.md
	@#
	@# Add the generated files and make a commit
	@git add -f $(HUGO_OUTPUT_DIR)/* README.md
	@git commit -q --no-gpg-sign -m "Docs build" -m "Built from $(COMMIT_SHA) in main branch" -m "'$(COMMIT_INFO)'"
	@#
	@# Back to main branch
	@git checkout -f main

publish:
	@git push -f origin $(HUGO_OUTPUT_BRANCH):$(HUGO_OUTPUT_BRANCH)
	@echo "Updated https://apophenian.art/"

publish-action-url:
	@curl -s "https://api.github.com/repos/randomibis/apophenian/actions/runs?per_page=1" | \
	  jq -r '.workflow_runs[0] | "https://github.com/randomibis/apophenian/actions/runs/" + (.id | tostring)'

republish: update-docs-branch publish
	@sleep 1
	@$(MAKE) publish-action-url

prod-diff:
	@git fetch origin && \
	  PROD_SHA=$$(git log -n1 origin/docs-build | grep 'Built from' | awk '{print $$3}') && \
	  echo "====================================================================" && \
	  git ll -n1 $$PROD_SHA && \
	  echo "====================================================================" && \
	  git diff $$PROD_SHA

preview:
	@hugo server
