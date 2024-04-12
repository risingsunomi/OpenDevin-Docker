# Pull the OpenDevin sandbox image
Write-Host "Creating OpenDevin sandbox..."
docker pull ghcr.io/opendevin/sandbox

# Build the OpenDevin image
Write-Host "Building OpenDevin docker..."
docker build -t opendevin .

if (Test-Path -Path "config.toml") {
    Write-Host "Using existing config.toml file."
} else {
    # Setup config.toml
    Write-Host "Setting up config.toml..."
    $llm_model = Read-Host "Enter your LLM Model name (see https://docs.litellm.ai/docs/providers for full list) [default: gpt-3.5-turbo]"
    if ([string]::IsNullOrEmpty($llm_model)) { $llm_model = "gpt-3.5-turbo" }
    "LLM_MODEL=`"$llm_model`"" | Out-File -FilePath config.toml -Encoding ASCII

    $llm_api_key = Read-Host "Enter your LLM API key"
    "LLM_API_KEY=`"$llm_api_key`"" | Out-File -FilePath config.toml -Append -Encoding ASCII

    $llm_base_url = Read-Host "Enter your LLM Base URL [mostly used for local LLMs, leave blank if not needed - example: http://localhost:5001/v1/]"
    if (![string]::IsNullOrEmpty($llm_base_url)) {
    "LLM_BASE_URL=`"$llm_base_url`"" | Out-File -FilePath config.toml -Append -Encoding ASCII
    }

    Write-Host "Enter your LLM Embedding Model`nChoices are openai, azureopenai, llama2 or leave blank to default to 'BAAI/bge-small-en-v1.5' via huggingface"
    $llm_embedding_model = Read-Host "> "
    "LLM_EMBEDDING_MODEL=`"$llm_embedding_model`"" | Out-File -FilePath config.toml -Append -Encoding ASCII

    if ($llm_embedding_model -eq "llama2") {
    $llm_base_url = Read-Host "Enter the local model URL (will overwrite LLM_BASE_URL)"
    "LLM_BASE_URL=`"$llm_base_url`"" | Out-File -FilePath config.toml -Append -Encoding ASCII
    } elseif ($llm_embedding_model -eq "azureopenai") {
    $llm_base_url = Read-Host "Enter the Azure endpoint URL (will overwrite LLM_BASE_URL)"
    "LLM_BASE_URL=`"$llm_base_url`"" | Out-File -FilePath config.toml -Append -Encoding ASCII
    $llm_deployment_name = Read-Host "Enter the Azure LLM Deployment Name"
    "LLM_DEPLOYMENT_NAME=`"$llm_deployment_name`"" | Out-File -FilePath config.toml -Append -Encoding ASCII
    $llm_api_version = Read-Host "Enter the Azure API Version"
    "LLM_API_VERSION=`"$llm_api_version`"" | Out-File -FilePath config.toml -Append -Encoding ASCII
    }

    $workspace_dir = Read-Host "Enter your workspace directory [default: ./workspace]"
    if ([string]::IsNullOrEmpty($workspace_dir)) { $workspace_dir = "./workspace" }
    "WORKSPACE_DIR=`"$workspace_dir`"" | Out-File -FilePath config.toml -Append -Encoding ASCII

    Write-Host "Config.toml setup completed."
}

# Run the OpenDevin container with the generated config.toml
Write-Host "Starting OpenDevin docker..."
docker run -p 3000:3000 -v ${PWD}/config.toml:/app/OpenDevin/config.toml opendevin

Write-Host "OpenDevin is running. You can access it at http://localhost:3000"