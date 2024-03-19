#!/bin/sh

# The 'install.sh' entrypoint script is always executed as the root user.
#
# These following environment variables are passed in by the dev container CLI.
# These may be useful in instances where the context of the final 
# remoteUser or containerUser is useful.
# For more details, see https://containers.dev/implementors/features#user-env-var
# echo "The effective dev container remoteUser is '$_REMOTE_USER'"
# echo "The effective dev container remoteUser's home directory is '$_REMOTE_USER_HOME'"

# echo "The effective dev container containerUser is '$_CONTAINER_USER'"
# echo "The effective dev container containerUser's home directory is '$_CONTAINER_USER_HOME'"

set -e

echo "Activating feature 'git-subtree'..."

# Store the initial directory
INITIAL_DIR=$(pwd)

# Get the git executable directory
GIT_EXEC_PATH=$(git --exec-path)
echo "Git found in $GIT_EXEC_PATH"

# Clone git source into /tmp for temporary use
echo "Cloning git source into /tmp..."
cd /tmp
git clone https://github.com/git/git.git

# Navigate to the contrib/subtree directory
cd git/contrib/subtree

# Prepare subtree 
echo "Preparing git-subtree..."
make

# Install git-subtree to the correct location
echo "Installing git-subtree to $GIT_EXEC_PATH..."
install -m 755 git-subtree "$GIT_EXEC_PATH"

# Clean up
echo "Removing temporary git source..."
rm -rf /tmp/git 

# Source the appropriate profile to update PATH
if [[ -f ~/.bashrc ]]; then
  source ~/.bashrc
elif [[ -f ~/.profile ]]; then
  source ~/.profile
fi

cd $INITIAL_DIR

# Verification
echo "Verifying git subtree installation..."
if git subtree --help >/dev/null 2>&1; then 
    echo "Git subtree installation successful!"
else
    echo "Git subtree installation may have failed. Error output:"
    git subtree help  # No redirection here for error visibility
fi
