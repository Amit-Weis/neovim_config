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

		-- Function to update which virtual texts are shown based on cursor position
		local function update_virtual_text_visibility()
			local bufnr = vim.api.nvim_get_current_buf()
			local cursor_line = vim.api.nvim_win_get_cursor(0)[1] - 1

			-- Get all diagnostics for current buffer
			local all_diagnostics = vim.diagnostic.get(bufnr)

			-- Clear our custom namespace
			local ns = vim.api.nvim_create_namespace("custom_lint_virtual_text")
			vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

			-- Add virtual text only where appropriate
			for _, diag in ipairs(all_diagnostics) do
				local should_show = false

				-- Always show errors
				if diag.severity == vim.diagnostic.severity.ERROR then
					should_show = true
				-- Only show warnings/hints on current line
				elseif
					(diag.severity == vim.diagnostic.severity.WARN or diag.severity == vim.diagnostic.severity.HINT)
					and diag.lnum == cursor_line
				then
					should_show = true
				-- Show info diagnostics
				elseif diag.severity == vim.diagnostic.severity.INFO then
					should_show = true
				end

				if should_show then
					local prefix = "● "
					local severity_name = vim.diagnostic.severity[diag.severity]
					local hl_group = "Diagnostic" .. severity_name:sub(1, 1):upper() .. severity_name:sub(2):lower()

					-- Create custom highlight group with background
					local hl_with_bg = hl_group .. "WithBg"
					local existing_hl = vim.api.nvim_get_hl(0, { name = hl_group })
					vim.api.nvim_set_hl(0, hl_with_bg, {
						fg = existing_hl.fg,
						bg = "#363646",
					})

					-- Determine position: warnings/hints on current line at col 80, errors at eol
					local virt_text_opts = {
						virt_text = { { prefix .. diag.message, hl_with_bg } },
					}

					if diag.severity == vim.diagnostic.severity.ERROR then
						-- Errors always at end of line
						virt_text_opts.virt_text_pos = "eol"
					elseif
						diag.lnum == cursor_line
						and (
							diag.severity == vim.diagnostic.severity.WARN
							or diag.severity == vim.diagnostic.severity.HINT
						)
					then
						-- Warnings/hints on current line at column 80
						virt_text_opts.virt_text_pos = "overlay"
						virt_text_opts.virt_text_win_col = 101
					else
						-- Everything else at end of line
						virt_text_opts.virt_text_pos = "eol"
					end

					pcall(vim.api.nvim_buf_set_extmark, bufnr, ns, diag.lnum, diag.col or 0, virt_text_opts)
				end
			end
		end

		-- Debounce helper
		local function debounce(fn, delay)
			local timer = nil
			return function(...)
				local args = { ... }
				if timer then
					vim.loop.timer_stop(timer)
					timer:close()
				end
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
		end

		-- Debounced lint with virtual text update
		local debounced_lint = debounce(function()
			lint.try_lint()
			vim.defer_fn(update_virtual_text_visibility, 100)
		end, 300)

		-- Create autocommands
		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		-- Lint on save and file open
		vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
			group = lint_augroup,
			callback = function()
				lint.try_lint()
				vim.defer_fn(update_virtual_text_visibility, 100)
			end,
		})

		-- Debounced linting on text changes
		vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
			group = lint_augroup,
			callback = debounced_lint,
		})

		-- Update virtual text when cursor moves
		vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
			group = lint_augroup,
			callback = update_virtual_text_visibility,
		})

		-- Also update when diagnostics change
		vim.api.nvim_create_autocmd("DiagnosticChanged", {
			group = lint_augroup,
			callback = function()
				vim.defer_fn(update_virtual_text_visibility, 50)
			end,
		})

		-- Manual lint trigger
		vim.keymap.set("n", "<leader>L", function()
			lint.try_lint()
			vim.defer_fn(update_virtual_text_visibility, 100)
		end, { desc = "Trigger linting for current file" })

		-- Customize diagnostic signs
		local signs = {
			Error = "✘",
			Warn = "▲",
			Hint = "⚑",
			Info = "»",
		}
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
		end
	end,
}
