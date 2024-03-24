# QuicAnalyses

Este projeto visa fornecer uma ferramenta de análise para o protocolo QUIC, implementada em Elixir. A análise é conduzida utilizando uma estrutura de projeto Umbrella e a biblioteca Quicer.

## Requisitos

- Elixir 1.16
- Netem

## Como Executar

Para executar o projeto, siga estas etapas:

    1. Inicie o shell interativo do Elixir com o projeto carregado:

    ```
    iex -S mix

    ```
    
    2. Dentro do shell do Elixir, inicie o gerenciador:

    ```
    Manager.start
    ```

## Relatório

Após a execução bem-sucedida da análise, um relatório será gerado e estará localizado no diretório priv do componente do servidor dentro da estrutura de projeto Umbrella.

## Configuração Adicional

Você pode definir variáveis adicionais para personalizar a análise, conforme descrito na documentação do gerenciador (Manager). Consulte a documentação para obter informações detalhadas sobre as variáveis que podem ser configuradas e seus efeitos na análise do protocolo QUIC.
