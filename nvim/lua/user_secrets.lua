-- Opens the .NET user secrets (secrets.json) of the project you are working on.
local M = {}

local PROJECT_EXTENSIONS = { csproj = true, fsproj = true, vbproj = true }
local PRUNED_DIRS = { bin = true, obj = true, node_modules = true, [".git"] = true, [".vs"] = true, [".idea"] = true, dist = true, packages = true }

local function extension(name)
  return name:match("%.(%w+)$")
end

local function read(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local content = f:read("*a")
  f:close()
  return content
end

---@param xml string
---@return string?
function M.extract_id(xml)
  return xml:match("<UserSecretsId>%s*([^<%s]+)%s*</UserSecretsId>")
end

--- Same location `dotnet user-secrets` uses on each OS.
---@param id string
function M.secrets_path(id)
  local base = vim.fn.has("win32") == 1 and vim.fs.joinpath(vim.env.APPDATA, "Microsoft", "UserSecrets")
    or vim.fs.joinpath(vim.uv.os_homedir(), ".microsoft", "usersecrets")
  return vim.fs.joinpath(base, id, "secrets.json")
end

---@param files string[]
---@return { name: string, file: string, id: string }[]
local function with_secrets(files)
  local projects = {}
  for _, file in ipairs(files) do
    local id = M.extract_id(read(file) or "")
    if id then
      table.insert(projects, { name = vim.fn.fnamemodify(file, ":t:r"), file = file, id = id })
    end
  end
  table.sort(projects, function(a, b) return a.name < b.name end)
  return projects
end

--- In a git repo, git already knows the files: fast, honours .gitignore, ignores nested worktrees.
local function git_project_files(root)
  local result = vim
    .system({ "git", "ls-files", "--cached", "--others", "--exclude-standard", "--", "*.csproj", "*.fsproj", "*.vbproj" }, { cwd = root, text = true })
    :wait()
  if result.code ~= 0 then return nil end
  local files, seen = {}, {}
  for rel in vim.gsplit(result.stdout, "\n", { trimempty = true }) do
    local file = vim.fs.joinpath(root, rel)
    if not seen[file] and vim.uv.fs_stat(file) then
      seen[file] = true
      table.insert(files, file)
    end
  end
  return files
end

--- Recursive walk that skips heavy folders and nested git repos/worktrees before entering them.
local function walk_project_files(root)
  local files = {}
  local skip = function(rel)
    return not PRUNED_DIRS[vim.fs.basename(rel)] and not vim.uv.fs_stat(vim.fs.joinpath(root, rel, ".git"))
  end
  for rel, type in vim.fs.dir(root, { depth = math.huge, skip = skip }) do
    if type == "file" and PROJECT_EXTENSIONS[extension(rel)] then
      table.insert(files, vim.fs.joinpath(root, rel))
    end
  end
  return files
end

--- Walks up from `start`: the nearest project with secrets wins; otherwise stops at the
--- first solution or repository root and returns every project with secrets below it.
---@param start string
function M.find_projects(start)
  local dir = vim.fs.normalize(vim.fs.abspath(start))
  while true do
    local here, is_root = {}, false
    for name, type in vim.fs.dir(dir) do
      local ext = extension(name)
      if type == "file" and PROJECT_EXTENSIONS[ext] then table.insert(here, vim.fs.joinpath(dir, name)) end
      if name == ".git" or (type == "file" and (ext == "sln" or ext == "slnx")) then is_root = true end
    end

    local projects = with_secrets(here)
    if #projects > 0 then return projects end

    if is_root then
      local files = vim.uv.fs_stat(vim.fs.joinpath(dir, ".git")) and git_project_files(dir) or walk_project_files(dir)
      return with_secrets(files)
    end

    local parent = vim.fs.dirname(dir)
    if parent == dir then return {} end
    dir = parent
  end
end

local function edit(project)
  local file = M.secrets_path(project.id)
  if not vim.uv.fs_stat(file) then
    vim.fn.mkdir(vim.fs.dirname(file), "p")
    vim.fn.writefile({ "{", "}" }, file)
  end
  vim.cmd.edit(vim.fn.fnameescape(file))
end

--- Starts from the current file's directory, falling back to the cwd for special buffers.
function M.open()
  local name = vim.api.nvim_buf_get_name(0)
  local dir = vim.bo.buftype == "" and name ~= "" and vim.fs.dirname(name) or nil
  local start = dir and vim.uv.fs_stat(dir) and dir or vim.uv.cwd()

  local projects = M.find_projects(start)
  if #projects == 0 then
    vim.notify("No project with <UserSecretsId> found from " .. start .. ". Run 'dotnet user-secrets init' first.", vim.log.levels.WARN)
  elseif #projects == 1 then
    edit(projects[1])
  else
    vim.ui.select(projects, {
      prompt = "Projects with user secrets",
      format_item = function(p) return p.name end,
    }, function(p)
      if p then edit(p) end
    end)
  end
end

return M
