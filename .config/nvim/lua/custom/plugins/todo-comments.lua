-- todo-comments.nvim comes from Kickstart. Setting it up again replaces Kickstart's
-- options, so `signs = false` is repeated. Custom keywords merge with the defaults.
require('todo-comments').setup {
  signs = false,
  -- Header tags in LeetCode solutions.
  keywords = {
    DIFFICULTY = { icon = 'D', color = 'test' },
    SOURCE = { icon = 'S', color = 'default' },
    SPACE = { icon = 'O', color = 'info' },
    TIME = { icon = 'O', color = 'info' },
    TOPICS = { icon = 'T', color = 'hint' },
    VERDICT = { icon = 'V', color = 'warning' },
  },
}
