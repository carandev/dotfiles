-- Headless tests for lua/user_secrets.lua. Run from anywhere: nvim --clean -l tests/user_secrets_spec.lua
local config = vim.fs.dirname(vim.fs.dirname(vim.fs.abspath(debug.getinfo(1, "S").source:sub(2))))
package.path = config .. "/lua/?.lua;" .. package.path
local us = require("user_secrets")

local failures = 0
local function test(name, fn)
  local ok, err = pcall(fn)
  print((ok and "PASS " or "FAIL ") .. name .. (ok and "" or ("\n     " .. tostring(err))))
  if not ok then failures = failures + 1 end
end
local function eq(actual, expected)
  if not vim.deep_equal(actual, expected) then
    error(("expected %s, got %s"):format(vim.inspect(expected), vim.inspect(actual)), 2)
  end
end

local root = vim.fs.joinpath(vim.fn.tempname(), "fixtures")
local function write(rel, content)
  local path = vim.fs.joinpath(root, rel)
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  local f = assert(io.open(path, "w"))
  f:write(content)
  f:close()
end
local function proj(id)
  return id and ("<Project><PropertyGroup>\n  <UserSecretsId> %s </UserSecretsId>\n</PropertyGroup></Project>"):format(id)
    or "<Project></Project>"
end
local function names(projects)
  return vim.tbl_map(function(p) return p.name .. "=" .. p.id end, projects)
end

-- Plain solution (no git): the filesystem walk must prune bin/obj and nested repositories.
write("sol/App.sln", "")
write("sol/src/Web/Web.csproj", proj("web-id"))
write("sol/src/Data/Data.fsproj", proj("data-id"))
write("sol/src/Lib/Lib.csproj", proj(nil))
write("sol/src/Web/bin/Debug/Copy.csproj", proj("bin-id"))
write("sol/nested/.git", "gitdir: elsewhere")
write("sol/nested/Other.csproj", proj("nested-id"))

-- Git repository: the project list comes from git and honours .gitignore.
write("repo/.gitignore", "ignored/\n")
write("repo/Api/Api.csproj", proj("api-id"))
write("repo/ignored/Hidden.csproj", proj("hidden-id"))
vim.system({ "git", "init", "-q" }, { cwd = vim.fs.joinpath(root, "repo") }):wait()

test("extract_id trims whitespace", function()
  eq(us.extract_id(proj("abc-123")), "abc-123")
end)

test("extract_id returns nil without UserSecretsId", function()
  eq(us.extract_id(proj(nil)), nil)
end)

test("secrets_path matches dotnet user-secrets location", function()
  local expected = vim.fn.has("win32") == 1
      and vim.fs.joinpath(vim.env.APPDATA, "Microsoft", "UserSecrets", "abc", "secrets.json")
    or vim.fs.joinpath(vim.uv.os_homedir(), ".microsoft", "usersecrets", "abc", "secrets.json")
  eq(vim.fs.normalize(us.secrets_path("abc")), vim.fs.normalize(expected))
end)

test("inside a project with secrets only that project is returned", function()
  eq(names(us.find_projects(vim.fs.joinpath(root, "sol/src/Web"))), { "Web=web-id" })
end)

test("without secrets nearby it lists the solution, sorted, pruning bin and nested repos", function()
  eq(names(us.find_projects(vim.fs.joinpath(root, "sol/src/Lib"))), { "Data=data-id", "Web=web-id" })
end)

test("in a git repository ignored projects are skipped", function()
  eq(names(us.find_projects(vim.fs.joinpath(root, "repo"))), { "Api=api-id" })
end)

test("returns the absolute project file", function()
  local p = us.find_projects(vim.fs.joinpath(root, "repo"))[1]
  eq(vim.fs.normalize(p.file), vim.fs.normalize(vim.fs.joinpath(root, "repo/Api/Api.csproj")))
end)

print(failures == 0 and "ALL PASSED" or (failures .. " FAILED"))
os.exit(failures == 0 and 0 or 1)
