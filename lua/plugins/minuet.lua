return {
  -- Configure Minuet AI
  {
    "milanglacier/minuet-ai.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    event = "InsertEnter",
    opts = {
      provider = "openai_compatible",
      provider_options = {
        openai_compatible = {
          model = "gemma4:e4b",
          end_point = "http://127.0.0.1:11434/v1/chat/completions",
          api_key = "TERM",
          name = "Ollama",
          stream = true,
          optional = {
            max_tokens = 256,
            top_p = 0.9,
            temperature = 0.2,
          },
        },
      },
      -- Enable Minuet's virtual text frontend to handle suggestions
      virtualtext = {
        auto_trigger_ft = { "*" }, -- Auto-trigger for all filetypes
        keymap = {
          accept = "<A-A>",      -- Keep Alt + Shift + A as a secondary accept key
          accept_line = "<A-a>", -- Alt + a to accept a single line
          prev = "<A-[>",        -- Alt + [ to trigger manually or cycle previous
          next = "<A-]>",        -- Alt + ] to trigger manually or cycle next
          dismiss = "<A-e>",     -- Alt + e to dismiss suggestion
        },
      },
    },
  },

  -- Integrate Minuet AI's Tab acceptance into blink.cmp
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        -- Check if Minuet suggestion is visible. If so, accept it; otherwise, fall back
        -- to snippet_forward, select_next, and Neovim's default tab/indent behavior.
        ["<Tab>"] = {
          function()
            if require("minuet.virtualtext").action.is_visible() then
              require("minuet.virtualtext").action.accept()
              return true
            end
          end,
          "snippet_forward",
          "select_next",
          "fallback",
        },
      },
      sources = {
        -- Do not add minuet here so it doesn't show in the dropdown menu
        default = { "lsp", "path", "snippets", "buffer" },
      },
    },
  },
}
