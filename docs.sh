#!/bin/bash

base_path=$(pwd)

# Diretório do servidor
cd "${base_path}/apps/server"

# Executar mix docs no servidor
echo "Executando mix docs no servidor..."
echo $(pwd)

mix docs

# Diretório do cliente
cd ..
cd "${base_path}/apps/client"

# Executar mix docs no cliente
echo "Executando mix docs no cliente..."
mix docs

# Diretório do gerenciador
cd ..
cd "${base_path}/apps/manager"

# Executar mix docs no gerenciador
echo "Executando mix docs no gerenciador..."
mix docs

echo "Concluído!"

