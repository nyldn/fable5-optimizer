.PHONY: test validate test-hooks render-demo help

test: validate test-hooks

validate:
	@python3 scripts/validate-release.py

test-hooks:
	@tests/test-codex-exec-guard.sh

render-demo:
	@vhs docs/assets/demo.tape

help:
	@echo "Fable 5 Optimizer"
	@echo ""
	@echo "Targets:"
	@echo "  make test        Validate the public release package"
	@echo "  make validate    Same as make test"
	@echo "  make test-hooks  Test packaged Claude Code hooks"
	@echo "  make render-demo Regenerate docs/assets/demo.gif from demo.tape"
