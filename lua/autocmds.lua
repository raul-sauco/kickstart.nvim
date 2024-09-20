vim.notify 'convert PHP Doc initialized'
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    print 'convert PHP Doc initialized'
  end,
})

-- Function to convert PHP doc block format
local function convert_php_doc()
  -- Get the current buffer and its content
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  local converted_lines = {}
  local inside_phpdoc = false

  for _, line in ipairs(lines) do
    -- Check if the line starts the PHP doc block
    if line:match '/%*%*?' then
      inside_phpdoc = true
      table.insert(converted_lines, '/**')
    elseif inside_phpdoc then
      -- If inside the doc block, replace each line
      local var_line = line:match '%s*%*%s*@var%s+([^%s]+)%s+%$([^%s]+)'
      if var_line then
        local type_, var = line:match '%s*%*%s*@var%s+([^%s]+)%s+%$([^%s]+)'
        table.insert(converted_lines, ' * @var ' .. type_ .. ' $' .. var)
      elseif line:match '%s*%*/' then
        -- Close the doc block
        table.insert(converted_lines, ' */')
        inside_phpdoc = false
      end
    else
      -- If not in a doc block, keep the line as is
      table.insert(converted_lines, line)
    end
  end

  -- Replace the buffer content with the converted lines
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, converted_lines)
end

-- Mapping to run the conversion function
vim.keymap.set('n', '<leader>pd', ':lua convert_php_doc()<CR>', {
  noremap = true,
  silent = true,
  desc = '[P]HP convert [D]oc to PHPDoc',
})
