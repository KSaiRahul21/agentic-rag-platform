.PHONY: pre-commit 


# -----------------------------
# Development Tools
# -----------------------------

# Run pre-commit hooks on all files 
pre-commit:
	pre-commit run --all-files


cz: ## Commit code using commitizen 
	cz commit