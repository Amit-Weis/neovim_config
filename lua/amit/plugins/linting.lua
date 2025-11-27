return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		lint.linters_by_ft = {
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			svelte = { "eslint_d" },
			python = { "pylint" },
			cpp = { "cpplint" },
			lua = { "luacheck" },
		}

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		-- Clear the default lint on events
		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				local bufnr = vim.api.nvim_get_current_buf()
				lint.try_lint()
				vim.diagnostic.reset(nil, bufnr)
			end,
		})

		vim.keymap.set("n", "<leader>L", function()
			lint.try_lint()
		end, { desc = "Trigger linting for current file" })

		-- CUSTOM DIAGNOSTIC DISPLAY RULES
		local signs = {
			Error = " ",
			Warn = " ",
			Hint = " ",
			Info = " ",
		}

		for t, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. t
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		-- Custom namespace for filtered diagnostics
		local ns = vim.api.nvim_create_namespace("filtered_diagnostics")
		local last_cursor_line = -1

		-- Function to update virtual text based on cursor position
		local function update_virtual_text()
			if vim.api.nvim_get_mode().mode == "i" then
				return
			end

			local bufnr = vim.api.nvim_get_current_buf()
			local cursor_line = vim.api.nvim_win_get_cursor(0)[1] - 1

			if cursor_line == last_cursor_line then
				return
			end
			last_cursor_line = cursor_line

			vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

			local diagnostics = vim.diagnostic.get(bufnr)

			for _, diag in ipairs(diagnostics) do
				local should_show = false

				if diag.severity == vim.diagnostic.severity.ERROR then
					should_show = true
				elseif diag.lnum == cursor_line then
					should_show = true
				end

				if should_show then
					local hl_map = {
						[vim.diagnostic.severity.ERROR] = "DiagnosticVirtualTextError",
						[vim.diagnostic.severity.WARN] = "DiagnosticVirtualTextWarn",
						[vim.diagnostic.severity.INFO] = "DiagnosticVirtualTextInfo",
						[vim.diagnostic.severity.HINT] = "DiagnosticVirtualTextHint",
					}

					local prefix_map = {
						[vim.diagnostic.severity.ERROR] = " ",
						[vim.diagnostic.severity.WARN] = " ",
						[vim.diagnostic.severity.INFO] = " ",
						[vim.diagnostic.severity.HINT] = " ",
					}

					local hl = hl_map[diag.severity] or "DiagnosticVirtualTextError"
					local prefix = prefix_map[diag.severity] or ""
					local message = string.format("%s%s", prefix, diag.message)

					pcall(vim.api.nvim_buf_set_extmark, bufnr, ns, diag.lnum, 0, {
						virt_text = { { message, hl } },
						virt_text_pos = "eol",
						hl_mode = "combine",
					})
				end
			end
		end

		-- Configure diagnostics: disable default virtual_text, keep everything else
		vim.diagnostic.config({
			virtual_text = false,
			signs = true,
			underline = true,
			update_in_insert = false,
			severity_sort = true,
		})

		-- Create autocmd group for our custom virtual text
		local diag_group = vim.api.nvim_create_augroup("CustomDiagnostics", { clear = true })

		-- Update on cursor movement (only in normal mode)
		vim.api.nvim_create_autocmd("CursorMoved", {
			group = diag_group,
			callback = function()
				pcall(update_virtual_text)
			end,
		})

		-- Update when diagnostics change (after linting)
		vim.api.nvim_create_autocmd("DiagnosticChanged", {
			group = diag_group,
			callback = function()
				-- Reset cursor line tracker to force update
				last_cursor_line = -1
				pcall(update_virtual_text)
			end,
		})

		-- Initial update on buffer enter
		vim.api.nvim_create_autocmd("BufEnter", {
			group = diag_group,
			callback = function()
				local bufnr = vim.api.nvim_get_current_buf()

				vim.diagnostic.reset(nil, bufnr)
				vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

				last_cursor_line = -1

				-- Re-run update shortly after (if diagnostics appear)
				vim.defer_fn(function()
					pcall(update_virtual_text)
				end, 50)
			end,
		})

		-- Hide all diagnostics when entering insert mode
		vim.api.nvim_create_autocmd("InsertEnter", {
			group = diag_group,
			callback = function()
				local bufnr = vim.api.nvim_get_current_buf()
				vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
				vim.diagnostic.hide(nil, bufnr)
			end,
		})

		-- Show diagnostics again when leaving insert mode
		vim.api.nvim_create_autocmd("InsertLeave", {
			group = diag_group,
			callback = function()
				local bufnr = vim.api.nvim_get_current_buf()
				vim.diagnostic.show(nil, bufnr)
				last_cursor_line = -1
				-- Don't call update_virtual_text() here CursorMoved will handle it
			end,
		})
	end,
}
