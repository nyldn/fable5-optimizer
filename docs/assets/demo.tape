Output docs/assets/demo.gif

Require bash
Require find
Require grep
Require sed

Set Shell "bash"
Set FontSize 22
Set Width 960
Set Height 540
Set Theme "Catppuccin Mocha"
Set Padding 18
Set WindowBar Colorful
Set TypingSpeed 18ms

Type "clear" Enter
Sleep 300ms

Type "echo 'Fable 5 Optimizer'; echo 'Fable 5 steers. Codex handles cheap execution.'; echo" Enter
Sleep 900ms

Type "find .claude -maxdepth 3 -type f | sort" Enter
Sleep 1200ms

Type "ls .claude/skills" Enter
Sleep 1200ms

Type "sed -n '25,52p' .claude/CLAUDE.md" Enter
Sleep 2400ms

Type "echo; echo 'Install into a project:'; echo '  rsync -av .claude/ /path/to/project/.claude/'; echo; echo 'Then start Claude Code and let Fable 5 steer.'" Enter
Sleep 2200ms
