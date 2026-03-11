return {
  -- Treesitter: ensure graphql parser is installed for syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "graphql" },
    },
  },

  -- GraphQL LSP: provides diagnostics, autocomplete, hover, go-to-definition
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        graphql = {
          -- graphql-language-service-cli must be installed:
          --   npm i -g graphql-language-service-cli
          -- Requires a .graphqlrc.yml / graphql.config.ts in the project root
          filetypes = { "graphql", "typescriptreact", "typescript", "javascriptreact", "javascript" },
        },
      },
    },
  },
}
