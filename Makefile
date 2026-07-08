.PHONY: test validate render-demo help

test: validate

validate:
	@python3 scripts/validate-release.py

render-demo:
	@vhs docs/assets/demo.tape

help:
	@echo "Fable 5 Optimizer"
	@echo ""
	@echo "Targets:"
	@echo "  make test        Validate the public release package"
	@echo "  make validate    Same as make test"
	@echo "  make render-demo Regenerate docs/assets/demo.gif from demo.tape"
