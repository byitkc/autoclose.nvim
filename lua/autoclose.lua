-- Simple auto-close plugin for Neovim
local M = {}

-- Default pairs to auto-close
local default_pairs = {
  ['('] = ')',
  ['['] = ']',
  ['{'] = '}',
  ['"'] = '"',
  ["'"] = "'",
  ['`'] = '`',
}

-- Configuration
M.config = {
  pairs = default_pairs,
  enabled = true,
}

-- Setup function to configure the plugin
function M.setup(opts)
  opts = opts or {}
  M.config.pairs = opts.pairs or default_pairs
  M.config.enabled = opts.enabled ~= false

  -- Set up the keymaps for each opening character
  M.create_mappings()
end

-- Create insert mode mappings for each opening character
function M.create_mappings()
  for open_char, close_char in pairs(M.config.pairs) do
    vim.keymap.set('i', open_char, function()
      return M.autoclose(open_char, close_char)
    end, { expr = true, noremap = true })
  end
end

-- Main auto-close function
function M.autoclose(open_char, close_char)
  if not M.config.enabled then
    return open_char
  end

  -- For symmetric pairs (like quotes), check if we should skip closing
  if open_char == close_char then
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]

    -- If next char is the closing char, skip it instead of inserting
    if col < #line and line:sub(col + 1, col + 1) == close_char then
      return '<Right>'
    end
  end

 -- Insert both characters and move cursor between them
  return open_char .. close_char .. '<Left>'
end

-- Toggle the plugin on/off
function M.toggle()
  M.config.enabled = not M.config.enabled
  local status = M.config.enabled and "enabled" or "disabled"
  print("Auto-close " .. status)
end

return M
