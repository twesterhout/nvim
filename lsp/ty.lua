local config = { }
if vim.fn.executable('python') == 1 then
  config['environment'] = { python = vim.fn.exepath('python') }
end

return {
  cmd = { 'ty', 'server' },
  filetypes = { 'python' },
  root_markers = { 'ty.toml', 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', '.git' },
  settings = { configuration = config },
}
