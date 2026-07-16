-- Ansible vs. plain YAML
--
-- Neovim's LSP filetype matching is exact: a `yaml.ansible` buffer attaches
-- ansiblels (and NOT yamlls), while a plain `yaml` buffer attaches yamlls. So
-- the only thing required to "differentiate" Ansible from regular YAML is to
-- give Ansible files the `yaml.ansible` filetype. Neovim does not do this on its
-- own for plain .yml/.yaml files, so we detect them here.
--
-- Detection is deliberately conservative so it never mislabels unrelated YAML
-- (e.g. the many *-stsconfig.yaml / startup configs): a file is treated as
-- Ansible only when an Ansible project marker (ansible.cfg / .ansible-lint)
-- exists somewhere above it AND either its path matches a standard Ansible
-- layout or its contents look like Ansible.

-- Is there an Ansible project marker at or above `path`?
local function in_ansible_project(path)
	return #vim.fs.find({ "ansible.cfg", ".ansible-lint" }, { path = path, upward = true }) > 0
end

-- Standard Ansible directory conventions.
local ansible_dirs = {
	"/playbooks/",
	"/roles/",
	"/tasks/",
	"/handlers/",
	"/group_vars/",
	"/host_vars/",
}

local function path_looks_ansible(path)
	for _, frag in ipairs(ansible_dirs) do
		if path:find(frag, 1, true) then
			return true
		end
	end
	local name = vim.fs.basename(path) or ""
	return name:match("^site%.ya?ml$") ~= nil or name:match("^playbook.*%.ya?ml$") ~= nil
end

-- Cheap content sniff so root-level playbooks (not under a conventional dir) are
-- still caught. Only the first lines are inspected.
local function content_looks_ansible(bufnr)
	if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
		return false
	end
	for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, 60, false)) do
		if
			line:find("ansible%.builtin%.")
			or line:find("^%s*hosts:%s")
			or line:find("^%s*become:%s")
			or line:find("^%s*tasks:%s*$")
			or line:find("^%s*roles:%s*$")
		then
			return true
		end
	end
	return false
end

vim.filetype.add({
	-- Compose files -> `yaml.docker-compose` so docker_language_server attaches.
	-- Neovim does not detect these on its own. Exact filenames beat patterns.
	filename = {
		["docker-compose.yml"] = "yaml.docker-compose",
		["docker-compose.yaml"] = "yaml.docker-compose",
		["compose.yml"] = "yaml.docker-compose",
		["compose.yaml"] = "yaml.docker-compose",
	},
	pattern = {
		-- Variants like docker-compose.prod.yml / compose.override.yaml. Higher
		-- priority than the Ansible catch-all below so they always win.
		[".*/docker%-compose%..*%.ya?ml"] = { "yaml.docker-compose", { priority = 10 } },
		[".*/compose%..*%.ya?ml"] = { "yaml.docker-compose", { priority = 10 } },

		-- Ansible catch-all at default priority (the compose patterns above use a
		-- higher priority so they win for compose files). Returning nil falls
		-- through to Neovim's default `yaml`.
		[".*%.ya?ml"] = function(path, bufnr)
			if in_ansible_project(path) and (path_looks_ansible(path) or content_looks_ansible(bufnr)) then
				return "yaml.ansible"
			end
		end,
	},
})
