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
            -- Fix: The transform function receives and returns a single table containing end_point, headers, and body
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
        -- Enable detailed notifications for debugging
        notify = "debug",
        throttle = 0,        -- Disable throttling
        debounce = 100,      -- Trigger quickly after 100ms pause
        request_timeout = 60, -- Increase timeout to 60s to allow Ollama to load the model
        -- Fix: Bypass environment proxy for local connections to 127.0.0.1
        curl_extra_args = { "--noproxy", "127.0.0.1,localhost" },
      })

      -- Ensure that the auto-trigger is active for all loaded buffers immediately
      vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
        pattern = "*",
        callback = function()
          vim.b.minuet_virtual_text_auto_trigger = true
        end,
      })

      -- Register a debugging command to check if Minuet is initialized properly
      vim.api.nvim_create_user_command("MinuetDebug", function()
        local config = require("minuet").config
        print("--- Minuet Debug Info ---")
        print("Minuet is loaded successfully!")
        print("Active Provider: " .. tostring(config.provider))
        print("Auto Trigger Enabled for Buf: " .. tostring(vim.b.minuet_virtual_text_auto_trigger))
        if config.provider_options and config.provider_options.openai_compatible then
          print("Model: " .. tostring(config.provider_options.openai_compatible.model))
          print("Endpoint: " .. tostring(config.provider_options.openai_compatible.end_point))
        else
          print("openai_compatible configuration not found under provider_options!")
        end
      end, {})
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
