local repo = require("bookmarks.repo")
local utils = require("bookmarks.utils")
local common = require("bookmarks.adapter.common")
local api = require("bookmarks.api")

local function add_list()
	vim.ui.input({ prompt = "Enter BookmarkList name" }, function(input)
		input = input or utils.trim(input)
		if not input or input == "" then
			return vim.notify("Require a valid name")
		end
		require("bookmarks.api").add_list({ name = input })
	end)
end

local function mark()
	vim.ui.input({ prompt = "Enter Bookmark name" }, function(input)
		require("bookmarks.api").mark({ name = (input or "") })
	end)
end

local function goto_bookmark()
	local bookmark_list = repo.find_or_set_active_bookmark_list()

	vim.ui.select(bookmark_list.bookmarks, {
		prompt = "Selete bookmark from active list: " .. bookmark_list.name,
		format_item = function(item)
			---@cast item Bookmarks.Bookmark
			return common.format(item, bookmark_list.bookmarks)
		end,
	}, function(choice)
		if not choice then
			return
		end
		---@cast choice Bookmarks.Bookmark
		vim.api.nvim_exec2("e" .. " " .. choice.location.path, {})
		vim.api.nvim_win_set_cursor(0, { choice.location.line, choice.location.col })
	end)
end

local function set_active_list()
	local bookmark_lists = repo.get_domains()

	vim.ui.select(bookmark_lists, {
		prompt = "Set active list",
		format_item = function(item)
			---@cast item Bookmarks.BookmarkList
			if item.is_active then
				return "Active: " .. item.name
			end
			return item.name
		end,
	}, function(choice)
		if not choice then
			return
		end
		---@cast choice Bookmarks.BookmarkList
		api.set_active_list(choice.name)
	end)
end

return {
	add_list = add_list,
	mark = mark,
	goto_bookmark = goto_bookmark,
	set_active_list = set_active_list,
}
