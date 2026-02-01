# Hawkins Terminal Makefile

INSTALL_DIR := $(HOME)/.local/share/hawkins-terminal
CONFIG_DIR := $(HOME)/.config/hawkins-terminal
BIN_DIR := $(HOME)/.local/bin

.PHONY: all install install-light install-rich uninstall link link-light link-rich test clean help

all: help

help:
	@echo "Hawkins Terminal - Stranger Things shell experience"
	@echo ""
	@echo "Usage:"
	@echo "  make install       - Install system-wide (all terminals)"
	@echo "  make install-local - Install on-demand only (hawkins-shell)"
	@echo "  make install-rich  - Install with rich mode (ASCII art, effects)"
	@echo "  make install-light - Install with light mode (minimal output)"
	@echo "  make uninstall     - Remove Hawkins Terminal"
	@echo "  make link          - Create symlink (for development)"
	@echo "  make test          - Run syntax checks"
	@echo "  make demo          - Show demo of startup effects"
	@echo "  make demo-success  - Show demo of success messages"
	@echo "  make demo-error    - Show demo of error messages"
	@echo "  make demo-light    - Show demo in light mode"
	@echo "  make demo-rich     - Show demo in rich mode"
	@echo "  make config        - Show configuration options"
	@echo ""

install:
	@echo "Installing Hawkins Terminal..."
	@mkdir -p $(INSTALL_DIR)
	@mkdir -p $(CONFIG_DIR)
	@mkdir -p $(BIN_DIR)
	@cp -r cli $(INSTALL_DIR)/
	@cp -r shell $(INSTALL_DIR)/
	@cp -r prompt $(INSTALL_DIR)/
	@chmod +x $(INSTALL_DIR)/cli/hawkins
	@ln -sf $(INSTALL_DIR)/cli/hawkins $(BIN_DIR)/hawkins
	@cp hawkins-shell $(INSTALL_DIR)/
	@chmod +x $(INSTALL_DIR)/hawkins-shell
	@ln -sf $(INSTALL_DIR)/hawkins-shell $(BIN_DIR)/hawkins-shell
	@echo "$(INSTALL_DIR)" > $(CONFIG_DIR)/path
	@# Auto-add to shell config if not already present
	@if [ -f "$(HOME)/.zshrc" ]; then \
		if ! grep -q 'hawkins-terminal/shell/hawkins.sh' "$(HOME)/.zshrc" 2>/dev/null; then \
			echo '' >> "$(HOME)/.zshrc"; \
			echo '# Hawkins Terminal' >> "$(HOME)/.zshrc"; \
			echo 'source "$(INSTALL_DIR)/shell/hawkins.sh"' >> "$(HOME)/.zshrc"; \
			echo "Added to ~/.zshrc"; \
		else \
			echo "Already configured in ~/.zshrc"; \
		fi; \
	elif [ -f "$(HOME)/.bashrc" ]; then \
		if ! grep -q 'hawkins-terminal/shell/hawkins.sh' "$(HOME)/.bashrc" 2>/dev/null; then \
			echo '' >> "$(HOME)/.bashrc"; \
			echo '# Hawkins Terminal' >> "$(HOME)/.bashrc"; \
			echo 'source "$(INSTALL_DIR)/shell/hawkins.sh"' >> "$(HOME)/.bashrc"; \
			echo "Added to ~/.bashrc"; \
		else \
			echo "Already configured in ~/.bashrc"; \
		fi; \
	else \
		echo "No .zshrc or .bashrc found. Add manually:"; \
		echo '  source "$(INSTALL_DIR)/shell/hawkins.sh"'; \
	fi
	@echo ""
	@echo "Installation complete! Restart your terminal or run: exec $$SHELL"

install-rich: install
	@echo "export HAWKINS_DISPLAY_MODE=rich" > $(CONFIG_DIR)/env
	@echo "Rich mode configured."

install-light: install
	@echo "export HAWKINS_DISPLAY_MODE=light" > $(CONFIG_DIR)/env
	@echo "Light mode configured."

install-local:
	@echo "Installing Hawkins Terminal (local/on-demand only)..."
	@mkdir -p $(INSTALL_DIR)
	@mkdir -p $(CONFIG_DIR)
	@mkdir -p $(BIN_DIR)
	@cp -r cli $(INSTALL_DIR)/
	@cp -r shell $(INSTALL_DIR)/
	@cp -r prompt $(INSTALL_DIR)/
	@chmod +x $(INSTALL_DIR)/cli/hawkins
	@ln -sf $(INSTALL_DIR)/cli/hawkins $(BIN_DIR)/hawkins
	@cp hawkins-shell $(INSTALL_DIR)/
	@chmod +x $(INSTALL_DIR)/hawkins-shell
	@ln -sf $(INSTALL_DIR)/hawkins-shell $(BIN_DIR)/hawkins-shell
	@echo "$(INSTALL_DIR)" > $(CONFIG_DIR)/path
	@echo ""
	@echo "Local install complete! Run 'hawkins-shell' to launch."
	@echo "Shell RC files were NOT modified."

uninstall:
	@echo "Uninstalling Hawkins Terminal..."
	@rm -rf $(INSTALL_DIR)
	@rm -rf $(CONFIG_DIR)
	@rm -f $(BIN_DIR)/hawkins
	@# Remove from shell config
	@if [ -f "$(HOME)/.zshrc" ] && grep -q 'hawkins-terminal/shell/hawkins.sh' "$(HOME)/.zshrc" 2>/dev/null; then \
		sed -i.bak '/# Hawkins Terminal/d; /hawkins-terminal\/shell\/hawkins.sh/d' "$(HOME)/.zshrc"; \
		rm -f "$(HOME)/.zshrc.bak"; \
		echo "Removed from ~/.zshrc"; \
	fi
	@if [ -f "$(HOME)/.bashrc" ] && grep -q 'hawkins-terminal/shell/hawkins.sh' "$(HOME)/.bashrc" 2>/dev/null; then \
		sed -i.bak '/# Hawkins Terminal/d; /hawkins-terminal\/shell\/hawkins.sh/d' "$(HOME)/.bashrc"; \
		rm -f "$(HOME)/.bashrc.bak"; \
		echo "Removed from ~/.bashrc"; \
	fi
	@echo "Uninstalled."

link:
	@echo "Creating development symlink..."
	@mkdir -p $(CONFIG_DIR)
	@mkdir -p $(BIN_DIR)
	@echo "$(CURDIR)" > $(CONFIG_DIR)/path
	@ln -sf $(CURDIR)/cli/hawkins $(BIN_DIR)/hawkins
	@# Auto-add to shell config if not already present
	@if [ -f "$(HOME)/.zshrc" ]; then \
		if ! grep -q 'hawkins-terminal/shell/hawkins.sh' "$(HOME)/.zshrc" 2>/dev/null; then \
			echo '' >> "$(HOME)/.zshrc"; \
			echo '# Hawkins Terminal' >> "$(HOME)/.zshrc"; \
			echo 'source "$(CURDIR)/shell/hawkins.sh"' >> "$(HOME)/.zshrc"; \
			echo "Added to ~/.zshrc"; \
		else \
			echo "Already configured in ~/.zshrc"; \
		fi; \
	elif [ -f "$(HOME)/.bashrc" ]; then \
		if ! grep -q 'hawkins-terminal/shell/hawkins.sh' "$(HOME)/.bashrc" 2>/dev/null; then \
			echo '' >> "$(HOME)/.bashrc"; \
			echo '# Hawkins Terminal' >> "$(HOME)/.bashrc"; \
			echo 'source "$(CURDIR)/shell/hawkins.sh"' >> "$(HOME)/.bashrc"; \
			echo "Added to ~/.bashrc"; \
		else \
			echo "Already configured in ~/.bashrc"; \
		fi; \
	else \
		echo "No .zshrc or .bashrc found. Add manually:"; \
		echo '  source "$(CURDIR)/shell/hawkins.sh"'; \
	fi
	@echo ""
	@echo "Development link created! Restart your terminal or run: exec $$SHELL"

link-rich: link
	@echo "export HAWKINS_DISPLAY_MODE=rich" > $(CONFIG_DIR)/env
	@echo "Rich mode configured."

link-light: link
	@echo "export HAWKINS_DISPLAY_MODE=light" > $(CONFIG_DIR)/env
	@echo "Light mode configured."

test:
	@echo "Running syntax checks..."
	@bash -n shell/hawkins.sh && echo "  shell/hawkins.sh: OK"
	@bash -n cli/hawkins && echo "  cli/hawkins: OK"
	@bash -n cli/lib/colors.sh && echo "  cli/lib/colors.sh: OK"
	@bash -n cli/lib/banner.sh && echo "  cli/lib/banner.sh: OK"
	@bash -n cli/lib/effects.sh && echo "  cli/lib/effects.sh: OK"
	@bash -n cli/lib/christmas.sh && echo "  cli/lib/christmas.sh: OK"
	@echo ""
	@if command -v zsh >/dev/null 2>&1; then \
		echo "Checking zsh compatibility..."; \
		zsh -n shell/hawkins.sh && echo "  zsh: OK"; \
	fi
	@echo ""
	@echo "All checks passed!"

demo:
	@echo "Running Hawkins Terminal demo..."
	@bash -c 'source shell/hawkins.sh && _hawkins_show_startup'

demo-success:
	@echo "Running success message demo..."
	@bash -c 'HAWKINS_SUPPRESS_BANNER=1 source shell/hawkins.sh && _hawkins_show_success'

demo-error:
	@echo "Running error message demo..."
	@bash -c 'HAWKINS_SUPPRESS_BANNER=1 source shell/hawkins.sh && _hawkins_show_error 127'

demo-light:
	@echo "Light mode demo..."
	@bash -c 'export HAWKINS_DISPLAY_MODE=light HAWKINS_SUPPRESS_BANNER=1; source shell/hawkins.sh && echo "Success:" && _hawkins_show_success && echo "" && echo "Error:" && _hawkins_show_error 127'

demo-rich:
	@echo "Rich mode demo..."
	@bash -c 'export HAWKINS_DISPLAY_MODE=rich HAWKINS_SUPPRESS_BANNER=1; source shell/hawkins.sh && echo "Success:" && _hawkins_show_success && echo "" && echo "Error:" && _hawkins_show_error 127'

config:
	@echo "Hawkins Terminal Configuration"
	@echo ""
	@echo "  HAWKINS_SUCCESS_THRESHOLD=N  Seconds before success msg (0=all, default: 0)"
	@echo "  HAWKINS_DISPLAY_MODE=MODE    Display mode: rich | light (default: rich)"
	@echo ""
	@echo "Add to ~/.zshrc or ~/.bashrc before sourcing hawkins.sh:"
	@echo '  export HAWKINS_SUCCESS_THRESHOLD=0'
	@echo '  export HAWKINS_DISPLAY_MODE=light'

clean:
	@echo "Cleaning temporary files..."
	@rm -f /tmp/.hawkins_lights_pid_*
	@rm -f /tmp/.hawkins_running_*
	@echo "Done."

reinstall: uninstall install
