-- Svelte/SvelteKit File Templates
return {
	-- This is a virtual plugin - just sets up commands for file templates
	dir = vim.fn.stdpath("config"),
	lazy = false,
	config = function()
		local templates = {
			component = {
				extension = ".svelte",
				content = function(name)
					return string.format([[<script lang="ts">
	// Component: %s
</script>

<div>
	<!-- Component content -->
</div>

<style>
	/* Component styles */
</style>
]], name)
				end,
			},
			
			page = {
				extension = "+page.svelte",
				content = function(name)
					return [[<script lang="ts">
	import type { PageData } from './$types';
	
	export let data: PageData;
</script>

<div>
	<h1>Welcome</h1>
</div>

<style>
	/* Page styles */
</style>
]]
				end,
			},
			
			layout = {
				extension = "+layout.svelte",
				content = function(name)
					return [[<script lang="ts">
	import type { LayoutData } from './$types';
	
	export let data: LayoutData;
</script>

<slot />

<style>
	/* Layout styles */
</style>
]]
				end,
			},
			
			server = {
				extension = "+page.server.ts",
				content = function(name)
					return [[import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ params, locals }) => {
	return {
		// Your data here
	};
};
]]
				end,
			},
			
			load = {
				extension = "+page.ts",
				content = function(name)
					return [[import type { PageLoad } from './$types';

export const load: PageLoad = async ({ params, fetch }) => {
	return {
		// Your data here
	};
};
]]
				end,
			},
			
			actions = {
				extension = "+page.server.ts",
				content = function(name)
					return [[import type { Actions, PageServerLoad } from './$types';
import { fail } from '@sveltejs/kit';

export const load: PageServerLoad = async () => {
	return {};
};

export const actions: Actions = {
	default: async ({ request }) => {
		const data = await request.formData();
		
		// Process form data
		
		return { success: true };
	}
};
]]
				end,
			},
		}

		-- Helper function to create file with template
		local function create_file_from_template(template_type, name)
			local template = templates[template_type]
			if not template then
				vim.notify("Unknown template type: " .. template_type, vim.log.levels.ERROR)
				return
			end

			-- Generate content
			local content = template.content(name)
			
			-- Determine file path
			local filename
			if template_type == "component" then
				filename = name .. template.extension
			else
				filename = name .. "/" .. template.extension
			end
			
			-- Create directory if needed
			local dir = vim.fn.fnamemodify(filename, ":h")
			if dir ~= "." and vim.fn.isdirectory(dir) == 0 then
				vim.fn.mkdir(dir, "p")
			end
			
			-- Check if file exists
			if vim.fn.filereadable(filename) == 1 then
				vim.notify("File already exists: " .. filename, vim.log.levels.WARN)
				return
			end
			
			-- Write file
			local file = io.open(filename, "w")
			if file then
				file:write(content)
				file:close()
				
				-- Open the new file
				vim.cmd("edit " .. filename)
				vim.notify("Created: " .. filename, vim.log.levels.INFO)
			else
				vim.notify("Failed to create file: " .. filename, vim.log.levels.ERROR)
			end
		end

		-- Create commands
		vim.api.nvim_create_user_command("SvelteComponent", function(opts)
			local name = opts.args
			if name == "" then
				vim.notify("Usage: :SvelteComponent ComponentName", vim.log.levels.ERROR)
				return
			end
			create_file_from_template("component", name)
		end, { nargs = 1, desc = "Create new Svelte component" })

		vim.api.nvim_create_user_command("SveltePage", function(opts)
			local name = opts.args
			if name == "" then
				name = "."
			end
			create_file_from_template("page", name)
		end, { nargs = "?", desc = "Create new SvelteKit page" })

		vim.api.nvim_create_user_command("SvelteLayout", function(opts)
			local name = opts.args
			if name == "" then
				name = "."
			end
			create_file_from_template("layout", name)
		end, { nargs = "?", desc = "Create new SvelteKit layout" })

		vim.api.nvim_create_user_command("SvelteServer", function(opts)
			local name = opts.args
			if name == "" then
				name = "."
			end
			create_file_from_template("server", name)
		end, { nargs = "?", desc = "Create new SvelteKit server load" })

		vim.api.nvim_create_user_command("SvelteLoad", function(opts)
			local name = opts.args
			if name == "" then
				name = "."
			end
			create_file_from_template("load", name)
		end, { nargs = "?", desc = "Create new SvelteKit load function" })

		vim.api.nvim_create_user_command("SvelteActions", function(opts)
			local name = opts.args
			if name == "" then
				name = "."
			end
			create_file_from_template("actions", name)
		end, { nargs = "?", desc = "Create new SvelteKit form actions" })

		-- Optional: Add keybindings for quick access
		local keymap = vim.keymap
		keymap.set("n", "<leader>sc", function()
			vim.ui.input({ prompt = "Component name: " }, function(input)
				if input then
					vim.cmd("SvelteComponent " .. input)
				end
			end)
		end, { desc = "New Svelte component" })
		
		keymap.set("n", "<leader>sp", function()
			vim.cmd("SveltePage .")
		end, { desc = "New SvelteKit page" })
		
		keymap.set("n", "<leader>sl", function()
			vim.cmd("SvelteLayout .")
		end, { desc = "New SvelteKit layout" })
	end,
}
