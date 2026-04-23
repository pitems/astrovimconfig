return {
  "robitx/gp.nvim",
  config = function()
    require("gp").setup {
      providers = {
        googleai = {
          endpoint = "https://generativelanguage.googleapis.com/v1beta/models/{{model}}:streamGenerateContent?key={{secret}}",
          secret = os.getenv "GEMINI_API_KEY",
        },
      },

      agents = {
        {
          name = "flash",
          provider = "googleai",
          model = "gemini-flash-latest", -- 🔥 IMPORTANT FIX
          system_prompt = "You are a helpful AI assistant specialized in programming.",
        },
        {
          name = "pro",
          provider = "googleai",
          model = "gemini-pro", -- fallback if available
          system_prompt = "You are a senior software engineer. Be concise and focus on debugging and improving code.",
        },
      },

      default_agent = "flash",
    }
  end,
}
