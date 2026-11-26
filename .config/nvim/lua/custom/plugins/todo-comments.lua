-- todo-comments.nvim comes from Kickstart. Setting it up again replaces Kickstart's
-- options, so `signs = false` is repeated. Custom keywords merge with the defaults.
require('todo-comments').setup {
  signs = false,
  -- Header tags in LeetCode solutions.
  keywords = {
    difficulty = { icon = 'D', color = 'test' },
    source = { icon = 'S', color = 'default' },
    space = { icon = 'O', color = 'info' },
    time = { icon = 'O', color = 'info' },
    topics = { icon = 'T', color = 'hint' },
    verdicts = { icon = 'V', color = 'warning' },
  },
}
