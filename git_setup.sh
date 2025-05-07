#!/bin/bash

# Navigate to your project directory
cd /Users/pantelistsagkas/Development/cicd-portfolio

# Check git status to see what files are tracked/untracked
git status

# Add all files to staging
git add .

# Commit the changes
git commit -m "Initial commit: Add CI/CD portfolio website"

# Verify the commit was created
git log --oneline

# Optional: Set up a remote repository (uncomment and modify if needed)
git remote add origin https://github.com/PantelisTsagkas/cicd-portfolio.git
git branch -M main
git push -u origin main
