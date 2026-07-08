Output docs/assets/demo.gif

Require bash
Require git
Require mkdir

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

Hide
Type "DEMO_REPO=$PWD; rm -rf /tmp/fable5-demo-app; mkdir -p /tmp/fable5-demo-app; cd /tmp/fable5-demo-app" Enter
Type "curl() { cat $DEMO_REPO/install.sh; }; export FABLE5_OPTIMIZER_REPO_URL=file://$DEMO_REPO" Enter
Type "claude() { echo Claude Code 2.1.204; echo Loading project instructions from .claude/CLAUDE.md; echo Skills loaded: codex-review, codex-implementation, codex-computer-use; echo; printf '> '; IFS= read -r request; echo; echo Matched skill: codex-computer-use; echo Route: Fable 5 steers, Codex/GPT-5.5 verifies runtime behavior.; }" Enter
Type "clear" Enter
Show

Type "curl -fsSL https://raw.githubusercontent.com/nyldn/fable5-optimizer/main/install.sh | bash" Enter
Sleep 1600ms

Type "claude" Enter
Sleep 800ms

Type "/codex-computer-use verify the running app UI and capture screenshots" Enter
Sleep 2200ms
