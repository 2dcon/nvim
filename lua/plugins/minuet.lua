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
      -- Keep minuet's built-in virtualtext trigger disabled so it doesn't conflict with blink.cmp
      virtualtext = {
        auto_trigger_ft = {},
        keymap = {},
      },
    },
  },

  -- Integrate Minuet AI with blink.cmp
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        ghost_text = {
          enabled = true,
        },
      },
      sources = {
        -- Add 'minuet' to the default list of completion sources
        default = { "lsp", "path", "snippets", "buffer", "minuet" },
        providers = {
          minuet = {
            name = "minuet",
            module = "minuet.blink",
            score_offset = 100,
          },
        },
      },
    },
  },
}
