return {
  -- Configure Minuet AI
  {
    "milanglacier/minuet-ai.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    event = "VeryLazy", -- Load on VeryLazy so that autocommands register properly on startup
    config = function()
      require("minuet").setup({
        provider = "openai_compatible",
        after_cursor_filter_length = 1,
        before_cursor_filter_length = 1,
        provider_options = {
          openai_compatible = {
            model = "qwen3.5:4b",
            end_point = "http://127.0.0.1:11434/v1/chat/completions",
            api_key = "TERM",
            name = "Ollama",
            stream = true,
            optional = {
              max_tokens = 256,
              top_p = 0.9,
              temperature = 0.2,
            },
            -- The transform function receives and returns a single table containing end_point, headers, and body
            transform = {
              function(data)
                data.headers["Authorization"] = nil
                return data
              end,
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
        -- Switch to warning/error notifications only to keep the editor quiet
        notify = "warn",
        throttle = 1000,     -- Throttle requests to once per second to avoid CPU/GPU spikes
        debounce = 400,      -- Trigger suggestion 400ms after you stop typing
        request_timeout = 60, -- 60s timeout to allow Ollama to load the model on first run
        -- Bypass environment proxy for local connections to 127.0.0.1
        curl_extra_args = { "--noproxy", "127.0.0.1,localhost" },
      })

      -- Ensure that the auto-trigger is active for all loaded buffers immediately
      vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
        pattern = "*",
        callback = function()
          vim.b.minuet_virtual_text_auto_trigger = true
        end,
      })
    end,
  },

  -- Integrate Minuet AI's Tab acceptance into blink.cmp
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        -- Disable blink.cmp's ghost text to prevent it from mirroring the completion menu as ghost text
        ghost_text = {
          enabled = false,
        },
      },
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
