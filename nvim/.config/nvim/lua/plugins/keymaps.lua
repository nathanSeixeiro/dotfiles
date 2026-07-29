return {
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        {
          mode = { "n" },
          { "<leader>t", group = "terminal" },
          { "<leader>k", group = "kubernetes" },
          { "<leader>i", group = "infra/terraform" },
        },
      },
    },
  },

  {
    "LazyVim/LazyVim",
    keys = {
      -- Terminal
      {
        "<leader>tt",
        "<cmd>terminal<cr>",
        desc = "Open terminal",
      },

      -- Kubernetes
      {
        "<leader>ka",
        "<cmd>!kubectl apply -f %<cr>",
        desc = "Kubectl apply current file",
      },

      -- Terraform
      {
        "<leader>ti",
        "<cmd>!terraform init<cr>",
        desc = "Terraform init",
      },
      {
        "<leader>tp",
        "<cmd>!terraform plan<cr>",
        desc = "Terraform plan",
      },
      {
        "<leader>tf",
        "<cmd>!terraform fmt<cr>",
        desc = "Terraform fmt",
      },
    },
  },
}
