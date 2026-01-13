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
  check_whitespace = true,  -- Only auto-close if next char is whitespace/blank
}

-- Setup function to configure the plugin
function M.setup(opts)
  opts = opts or {}
  M.config.pairs = opts.pairs or default_pairs
  M.config.enabled = opts.enabled ~= false
  M.config.check_whitespace = opts.check_whitespace ~= false  -- Default true

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

-- Check if character is whitespace
local function is_whitespace(char)
  return char == ' ' or char == '\t' or char == '\n' or char == '\r'
end

-- Main auto-close function
function M.autoclose(open_char, close_char)
  if not M.config.enabled then
    return open_char
  end

  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local next_char = col < #line and line:sub(col + 1, col + 1) or ''

  -- For symmetric pairs (like quotes), check if we should skip closing
  if open_char == close_char then
    -- If next char is the closing char, skip it instead of inserting
    if next_char == close_char then
      return '<Right>'
    end
  end

  -- If whitespace checking is enabled, only auto-close in appropriate contexts
  if M.config.check_whitespace then
    -- Only auto-close if next character is whitespace or end of line
    if next_char == '' or is_whitespace(next_char) then
      return open_char .. close_char .. '<Left>'
    end

    -- Don't auto-close, just insert the opening character
    return open_char
  else
    -- Always auto-close if whitespace checking is disabled
    return open_char .. close_char .. '<Left>'
  end
end

-- Toggle the plugin on/off
function M.toggle()
  M.config.enabled = not M.config.enabled
  local status = M.config.enabled and "enabled" or "disabled"
  print("Auto-close " .. status)
end

return M
