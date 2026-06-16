return {
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
          end_point = "http://localhost:11434/v1/chat/completions",
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
      virtualtext = {
        auto_trigger_ft = { "*" },
        keymap = {
          accept = "<A-A>",
          accept_line = "<A-a>",
          prev = "<A-[>",
          next = "<A-]>",
          dismiss = "<A-e>",
        },
      },
    },
  },
}
