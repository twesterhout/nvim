local config = { }
if vim.fn.executable('python') == 1 then
  -- local python = vim.fn.fnamemodify(vim.trim(vim.fn.system({ 'python', '-c', 'import site; print(site.getsitepackages()[0])' })), ':h')
  local python = vim.fn.exepath('python')
  config['environment'] = { python = python }
end

return {
  cmd = { 'ty', 'server' },
  filetypes = { 'python' },
  -- root_markers = { 'ty.toml', 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', '.git' },
  settings = { configuration = config },
}
