# Contains all arguments that are passed
CODE_SERVER_ARGS=($@)

# Number of arguments that are given
NUMBER_OF_ARG=${#CODE_SERVER_ARGS[@]}

# Prepare the variables for installing specific Code Server version
if [[ $NUMBER_OF_ARG -eq 1 ]]; then
    CODE_SERVER_VERSION=${CODE_SERVER_ARGS[0]}
    CODE_SERVER_DOWNLOAD_URL="https://github.com/cdr/code-server/releases/download/${CODE_SERVER_VERSION}/code-server${CODE_SERVER_VERSION}-linux-x64.tar.gz"
fi

# Check if a directory does not exist
if [[ ! -d "/home/vagrant/code-server" ]]; then
    echo ">>> Installing Code Server ${CODE_SERVER_VERSION}"
    wget --quiet "${CODE_SERVER_DOWNLOAD_URL}"
    tar xzf code-server${CODE_SERVER_VERSION}-linux-x64.tar.gz
    mv code-server${CODE_SERVER_VERSION}-linux-x64.tar.gz code-server
    rm -f code-server${CODE_SERVER_VERSION}-linux-x64.tar.gz
else
    echo "Code Server is already installed."
fi