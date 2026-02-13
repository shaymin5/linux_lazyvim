-- utils/open_terminal.lua
local M = {}

-- 存储目录到终端实例的映射
M.terminals = {}
M.ready = {} -- 跟踪终端是否已准备就绪
M.id_counter_base = 1000 -- 终端 ID 的起始值，避免与其他手动终端冲突

-- 获取当前工作目录（优先使用当前文件的目录）
function M.get_current_dir()
  local file_path = vim.fn.expand("%:p")
  if file_path and file_path ~= "" then
    return vim.fn.fnamemodify(file_path, ":h") -- 文件所在目录
  else
    return vim.fn.getcwd() -- 无文件时使用当前工作目录
  end
end

-- 为目录生成一个固定的终端 ID (1000-1999 范围内)
function M.get_dir_id(dir)
  local hash = 5381
  for i = 1, #dir do
    hash = ((hash * 33) + dir:byte(i)) % 1000
  end
  return 1000 + (hash % 1000) -- 返回 1000-1999 之间的 ID
end

-- 确保进入终端模式（插入模式）
function M.ensure_terminal_mode(term_id)
  vim.defer_fn(function()
    local term = require("toggleterm.terminal").get(term_id)
    if term and term:is_open() then
      vim.cmd("startinsert!") -- 强制进入插入模式
      -- 再次检查以确保成功
      vim.defer_fn(function()
        local mode = vim.api.nvim_get_mode().mode
        if mode ~= "t" and mode ~= "i" then
          vim.cmd("startinsert!")
        end
      end, 20)
    end
  end, 30)
end

-- 获取（或创建）指定目录对应的终端实例
function M.get_terminal_for_dir(dir)
  -- 如果已存在该目录的终端实例，直接返回
  if M.terminals[dir] then
    local term = M.terminals[dir]
    if term and type(term) == "table" and term.toggle then
      return term
    else
      M.terminals[dir] = nil -- 无效实例，清空后重建
    end
  end

  local Terminal = require("toggleterm.terminal").Terminal
  local term_id = M.get_dir_id(dir)

  -- 检查 ID 是否被其他目录占用（极少数情况）
  for stored_dir, stored_term in pairs(M.terminals) do
    if stored_dir ~= dir and stored_term.id == term_id then
      -- 发生冲突，递增 ID 直到找到空闲值
      for i = 1, 999 do
        local new_id = 1000 + ((term_id - 1000 + i) % 1000)
        local conflict = false
        for _, other_term in pairs(M.terminals) do
          if other_term.id == new_id then
            conflict = true
            break
          end
        end
        if not conflict then
          term_id = new_id
          break
        end
      end
      break
    end
  end

  -- 创建终端实例
  local term = Terminal:new({
    cmd = vim.o.shell, -- 使用用户的默认 shell
    dir = dir, -- 设置终端初始目录
    id = term_id,
    direction = "float", -- 浮动窗口
    float_opts = {
      border = "rounded",
      width = function()
        return math.floor(vim.o.columns * 0.8)
      end,
      height = function()
        return math.floor(vim.o.lines * 0.8)
      end,
    },
    auto_scroll = true,
    close_on_exit = false, -- 退出命令后不关闭窗口
    on_open = function(term_obj)
      M.ready[dir] = true
      M.ensure_terminal_mode(term_obj.id)
    end,
    on_close = function()
      M.ready[dir] = false
    end,
  })

  M.terminals[dir] = term
  return term
end

-- 打开/聚焦当前目录的终端
function M.open_terminal()
  local dir = M.get_current_dir()
  local term = M.get_terminal_for_dir(dir)

  local was_open = term:is_open()
  if not was_open then
    term:open() -- 打开终端
  else
    -- 如果已打开，确保窗口获得焦点
    if term.window and vim.api.nvim_win_is_valid(term.window) then
      vim.api.nvim_set_current_win(term.window)
    end
  end

  -- 确保进入终端模式
  M.ensure_terminal_mode(term.id)
end

-- 切换终端（打开/关闭）
function M.toggle_terminal()
  local dir = M.get_current_dir()
  local term = M.get_terminal_for_dir(dir)

  term:toggle()
  if term:is_open() then
    M.ensure_terminal_mode(term.id)
  end
end

-- 关闭当前目录的终端
function M.close_terminal()
  local dir = M.get_current_dir()
  local term = M.terminals[dir]
  if term and term:is_open() then
    term:close()
  end
end

-- 获取当前目录的终端对象（可用于手动操作）
function M.get_terminal()
  local dir = M.get_current_dir()
  return M.get_terminal_for_dir(dir)
end

-- 获取终端状态
function M.get_status()
  local dir = M.get_current_dir()
  local term = M.terminals[dir]
  return {
    is_open = term and term:is_open() or false,
    terminal_id = term and term.id or nil,
    current_dir = dir,
  }
end

return M
