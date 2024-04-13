#!/bin/bash

# Pull the OpenDevin sandbox image
echo "Pulling OpenDevin sandbox docker..."
docker pull ghcr.io/opendevin/sandbox

# Build the OpenDevin image
echo "Building OpenDevin docker..."
docker build --no-cache -t opendevin .

if [ -f "config.toml" ]; then
  echo "Using existing config.toml file."
else
    # Setup config.toml
    echo "Setting up config.toml..."
    read -p "Enter your LLM Model name (see https://docs.litellm.ai/docs/providers for full list) [default: gpt-3.5-turbo]: " llm_model
    llm_model=${llm_model:-gpt-3.5-turbo}
    echo "LLM_MODEL=\"$llm_model\"" > config.toml

    read -p "Enter your LLM API key: " llm_api_key
    echo "LLM_API_KEY=\"$llm_api_key\"" >> config.toml

    read -p "Enter your LLM Base URL [mostly used for local LLMs, leave blank if not needed - example: http://localhost:5001/v1/]: " llm_base_url
    if [[ ! -z "$llm_base_url" ]]; then echo "LLM_BASE_URL=\"$llm_base_url\"" >> config.toml; fi

    echo "Enter your LLM Embedding Model\nChoices are openai, azureopenai, llama2 or leave blank to default to 'BAAI/bge-small-en-v1.5' via huggingface"
    read -p "> " llm_embedding_model
    echo "LLM_EMBEDDING_MODEL=\"$llm_embedding_model\"" >> config.toml

    if [ "$llm_embedding_model" = "llama2" ]; then
    read -p "Enter the local model URL (will overwrite LLM_BASE_URL): " llm_base_url
    echo "LLM_BASE_URL=\"$llm_base_url\"" >> config.toml
    elif [ "$llm_embedding_model" = "azureopenai" ]; then
    read -p "Enter the Azure endpoint URL (will overwrite LLM_BASE_URL): " llm_base_url
    echo "LLM_BASE_URL=\"$llm_base_url\"" >> config.toml
    read -p "Enter the Azure LLM Deployment Name: " llm_deployment_name
    echo "LLM_DEPLOYMENT_NAME=\"$llm_deployment_name\"" >> config.toml
    read -p "Enter the Azure API Version: " llm_api_version
    echo "LLM_API_VERSION=\"$llm_api_version\"" >> config.toml
    fi

    read -p "Enter your workspace directory [default: ./workspace]: " workspace_dir
    workspace_dir=${workspace_dir:-./workspace}
    echo "WORKSPACE_DIR=\"$workspace_dir\"" >> config.toml
fi

# Run the OpenDevin container with the generated config.toml
echo "Starting OpenDevin docker..."
docker run -p 3001:3001 -v $(pwd)/config.toml:/app/OpenDevin/config.toml opendevin