#!/usr/bin/env node
// Opens the .NET user-secrets file (secrets.json) of the current project in Neovim.
// - Inside a project folder: opens that project's secrets.
// - Inside a solution/repo with several projects: asks which one to open.
// Only projects that declare <UserSecretsId> are considered.
import { existsSync, mkdirSync, readdirSync, readFileSync, writeFileSync } from 'node:fs';
import { homedir } from 'node:os';
import { basename, dirname, extname, join, resolve } from 'node:path';
import { execFileSync, spawnSync } from 'node:child_process';
import { createInterface } from 'node:readline/promises';
import { pathToFileURL } from 'node:url';

const PROJECT_EXTENSIONS = new Set(['.csproj', '.fsproj', '.vbproj']);
const SOLUTION_EXTENSIONS = new Set(['.sln', '.slnx']);
const PRUNED_DIRS = new Set(['bin', 'obj', 'node_modules', '.git', '.vs', '.idea', '.claude', 'dist', 'packages']);

export function extractUserSecretsId(xml) {
  const match = /<UserSecretsId>\s*([^<\s]+)\s*<\/UserSecretsId>/.exec(xml);
  return match ? match[1] : null;
}

export function secretsFilePath(id, { platform = process.platform, env = process.env, home = homedir() } = {}) {
  const base = platform === 'win32'
    ? join(env.APPDATA, 'Microsoft', 'UserSecrets')
    : join(home, '.microsoft', 'usersecrets');
  return join(base, id, 'secrets.json');
}

function listDir(dir) {
  try {
    return readdirSync(dir, { withFileTypes: true });
  } catch {
    return [];
  }
}

function toProject(file) {
  let id = null;
  try {
    id = extractUserSecretsId(readFileSync(file, 'utf8'));
  } catch {
    return null;
  }
  return id ? { name: basename(file, extname(file)), file, id } : null;
}

function withSecrets(files) {
  return files
    .map(toProject)
    .filter(Boolean)
    .sort((a, b) => a.name.localeCompare(b.name));
}

// Recursive walk that skips heavy folders and nested git repos/worktrees before entering them.
function walkProjectFiles(dir, out = []) {
  for (const entry of listDir(dir)) {
    const full = join(dir, entry.name);
    if (entry.isDirectory()) {
      if (PRUNED_DIRS.has(entry.name) || existsSync(join(full, '.git'))) continue;
      walkProjectFiles(full, out);
    } else if (PROJECT_EXTENSIONS.has(extname(entry.name))) {
      out.push(full);
    }
  }
  return out;
}

// In a git repo, git already knows the files: fast, honours .gitignore, ignores nested worktrees.
function gitProjectFiles(root) {
  try {
    const output = execFileSync(
      'git',
      ['ls-files', '--cached', '--others', '--exclude-standard', '--', '*.csproj', '*.fsproj', '*.vbproj'],
      { cwd: root, encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] },
    );
    return [...new Set(output.split('\n').filter(Boolean))]
      .map((rel) => join(root, rel))
      .filter((file) => existsSync(file));
  } catch {
    return null;
  }
}

function isSearchRoot(dir, entries) {
  return entries.some((e) => e.name === '.git' || (e.isFile() && SOLUTION_EXTENSIONS.has(extname(e.name))));
}

// Walk up from `start`: the nearest project with secrets wins; otherwise stop at the
// first solution or repository root and return every project with secrets below it.
export function findProjects(start) {
  let dir = resolve(start);
  for (;;) {
    const entries = listDir(dir);
    const here = withSecrets(
      entries.filter((e) => e.isFile() && PROJECT_EXTENSIONS.has(extname(e.name))).map((e) => join(dir, e.name)),
    );
    if (here.length) return here;

    if (isSearchRoot(dir, entries)) {
      const files = (existsSync(join(dir, '.git')) && gitProjectFiles(dir)) || walkProjectFiles(dir);
      return withSecrets(files);
    }

    const parent = dirname(dir);
    if (parent === dir) return [];
    dir = parent;
  }
}

async function choose(projects) {
  if (projects.length === 1) return projects[0];
  console.log('\x1b[36mProjects with user secrets:\x1b[0m');
  projects.forEach((p, i) => console.log(`  ${String(i + 1).padStart(2)}) ${p.name}`));
  const rl = createInterface({ input: process.stdin, output: process.stdout });
  try {
    for (;;) {
      const answer = (await rl.question('Choose a number (empty to cancel): ')).trim();
      if (!answer) return null;
      const n = Number(answer);
      if (Number.isInteger(n) && n >= 1 && n <= projects.length) return projects[n - 1];
      console.log('\x1b[31mInvalid option.\x1b[0m');
    }
  } finally {
    rl.close();
  }
}

async function fail(message) {
  console.log(`\x1b[33m${message}\x1b[0m`);
  const rl = createInterface({ input: process.stdin, output: process.stdout });
  await rl.question('Press Enter to close...');
  rl.close();
  process.exit(1);
}

async function main() {
  const start = process.argv[2] || process.env.HERDR_ACTIVE_PANE_CWD || process.cwd();
  console.log(`\x1b[90mSearching projects with user secrets from ${start} ...\x1b[0m`);

  const projects = findProjects(start);
  if (!projects.length) {
    await fail(`No project with <UserSecretsId> found from ${start}. Run 'dotnet user-secrets init' in the project first.`);
  }

  const selected = await choose(projects);
  if (!selected) return;

  const file = secretsFilePath(selected.id);
  if (!existsSync(file)) {
    mkdirSync(dirname(file), { recursive: true });
    writeFileSync(file, '{\n}\n');
  }

  const result = spawnSync(process.env.USER_SECRETS_EDITOR || 'nvim', [file], { stdio: 'inherit' });
  if (result.error) await fail(`Could not start the editor: ${result.error.message}`);
  process.exit(result.status ?? 0);
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  await main();
}
