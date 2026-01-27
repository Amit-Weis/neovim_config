return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		-- Configure linters by filetype
		lint.linters_by_ft = {
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			svelte = { "eslint_d" },
			python = { "pylint" },
			c = { "cpplint" },
			cpp = { "cpplint" },
			lua = { "luacheck" },
		}

		-- Guard: do nothing in insert mode
		local function not_in_insert()
			return vim.api.nvim_get_mode().mode ~= "i"
		end

		-- Function to update which virtual texts are shown
		local function update_virtual_text_visibility()
			if not not_in_insert() then
				return
			end

			local bufnr = vim.api.nvim_get_current_buf()
			local cursor_line = vim.api.nvim_win_get_cursor(0)[1] - 1
			local diagnostics = vim.diagnostic.get(bufnr)

			local ns = vim.api.nvim_create_namespace("custom_lint_virtual_text")
			vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

			for _, diag in ipairs(diagnostics) do
				local show = false

				if diag.severity == vim.diagnostic.severity.ERROR then
					show = true
				elseif
					(diag.severity == vim.diagnostic.severity.WARN or diag.severity == vim.diagnostic.severity.HINT)
					and diag.lnum == cursor_line
				then
					show = true
				elseif diag.severity == vim.diagnostic.severity.INFO then
					show = true
				end

				if show then
					local prefix = " "
					local severity_name = vim.diagnostic.severity[diag.severity]
					local hl_group = "Diagnostic" .. severity_name:sub(1, 1):upper() .. severity_name:sub(2):lower()

					local hl_with_bg = hl_group .. "WithBg"
					local existing = vim.api.nvim_get_hl(0, { name = hl_group })

					vim.api.nvim_set_hl(0, hl_with_bg, {
						fg = existing.fg,
						bg = "#363646",
					})

					local opts = {
						virt_text = { { prefix .. diag.message, hl_with_bg } },
					}

					if diag.severity == vim.diagnostic.severity.ERROR then
						opts.virt_text_pos = "eol"
					elseif
						diag.lnum == cursor_line
						and (
							diag.severity == vim.diagnostic.severity.WARN
							or diag.severity == vim.diagnostic.severity.HINT
						)
					then
						opts.virt_text_pos = "overlay"
						opts.virt_text_win_col = 80
					else
						opts.virt_text_pos = "eol"
					end

					pcall(vim.api.nvim_buf_set_extmark, bufnr, ns, diag.lnum, diag.col or 0, opts)
				end
			end
		end

		-- Debounce helper (returns fn + cancel)
		local function debounce(fn, delay)
			local timer = nil

			local function wrapped(...)
				if timer then
					timer:stop()
					timer:close()
				end

				local args = { ... }
				timer = vim.loop.new_timer()
				timer:start(
					delay,
					0,
					vim.schedule_wrap(function()
						fn(unpack(args))
						if timer then
							timer:close()
							timer = nil
						end
					end)
				)
			end

			local function cancel()
				if timer then
					timer:stop()
					timer:close()
					timer = nil
				end
			end

			return wrapped, cancel
		end

		-- Debounced lint (disabled in insert mode)
		local debounced_lint, cancel_debounced_lint = debounce(function()
			if not not_in_insert() then
				return
			end
			lint.try_lint()
			vim.defer_fn(update_virtual_text_visibility, 100)
		end, 300)

		local augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		-- Lint on open/save
		vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
			group = augroup,
			callback = function()
				if not not_in_insert() then
					return
				end
				lint.try_lint()
				vim.defer_fn(update_virtual_text_visibility, 100)
			end,
		})

		-- Lint on text change (normal mode only)
		vim.api.nvim_create_autocmd("TextChanged", {
			group = augroup,
			callback = debounced_lint,
		})

		-- Update virtual text on cursor move
		vim.api.nvim_create_autocmd("CursorMoved", {
			group = augroup,
			callback = update_virtual_text_visibility,
		})

		-- Insert mode: hide virtual text + cancel pending lint
		vim.api.nvim_create_autocmd("InsertEnter", {
			group = augroup,
			callback = function()
				local bufnr = vim.api.nvim_get_current_buf()
				local ns = vim.api.nvim_create_namespace("custom_lint_virtual_text")
				vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
				cancel_debounced_lint()
			end,
		})

		-- Restore virtual text after insert
		vim.api.nvim_create_autocmd("InsertLeave", {
			group = augroup,
			callback = update_virtual_text_visibility,
		})

		-- React to diagnostic changes
		vim.api.nvim_create_autocmd("DiagnosticChanged", {
			group = augroup,
			callback = function()
				if not not_in_insert() then
					return
				end
				vim.defer_fn(update_virtual_text_visibility, 50)
			end,
		})

		-- Manual lint trigger
		vim.keymap.set("n", "<leader>L", function()
			if not not_in_insert() then
				return
			end
			lint.try_lint()
			vim.defer_fn(update_virtual_text_visibility, 100)
		end, { desc = "Trigger linting for current file" })

		-- Diagnostic signs
		local signs = {
			Error = "",
			Warn = "",
			Hint = "",
			Info = "",
		}
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
		end
	end,
}
