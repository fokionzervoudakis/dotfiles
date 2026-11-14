load helpers

# Feed the status line the JSON in $1 and compare the color code and number of
# each percentage with $2; the labels and separators are left out, so rewording
# them does not fail this
statusline_colors() {
    same "$(.claude/statusline.jq <<<"$1" | grep -o $'\033\\[[0-9]*m[0-9]*%' | tr -d $'\033[' | paste -sd ' ' -)" "$2"
}

# Green (32) below 50, yellow (33) from 50, red (31) from 80, and the decimals
# are dropped; a broken script otherwise shows only as a blank status line
@test "statusline colors by percentage" {
    statusline_colors \
        '{"model":{"display_name":"M"},"context_window":{"used_percentage":49.9},"rate_limits":{"five_hour":{"used_percentage":50},"seven_day":{"used_percentage":80}}}' \
        '32m49% 33m50% 31m80%'
}

# A new session sends the model before any of the percentages; the line should
# still show the model instead of going blank
@test "statusline before usage is sent" {
    .claude/statusline.jq <<<'{"model":{"display_name":"M"}}' | grep -q M
}
