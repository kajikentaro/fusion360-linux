.PHONY: run kill ps log

FUSION_PATTERN := [F]usion360|[A]dskIdentity|[A]DPClientService|[m]sedgewebview2|[a]dexmtsv|[p]roton run $(HOME)/.fusion360-proton2|[s]team.exe .*[F]usion360

NEUTRON_LOG_DIR := $(HOME)/.fusion360-proton2/pfx/drive_c/users/steamuser/AppData/Local/Autodesk/Neutron Platform/logs
FUSION_USER_LOG_DIR := $(HOME)/.fusion360-proton2/pfx/drive_c/users/steamuser/AppData/Local/Autodesk/Autodesk Fusion 360/C3WBQHDVEZAR/logs

run:
	bash -x ./launch-fusion.sh

kill:
	@pkill -f '$(FUSION_PATTERN)' || true

ps:
	@pgrep -af '$(FUSION_PATTERN)' || true

log:
	@latest="$$(ls -t "$(NEUTRON_LOG_DIR)"/*.log "$(FUSION_USER_LOG_DIR)"/*.log 2>/dev/null | head -n 1)"; \
	if [ -n "$$latest" ]; then \
		echo "Following: $$latest"; \
		tail -f "$$latest"; \
	else \
		echo "No log files found."; \
		exit 1; \
	fi

install:
	cd installer && bash -x ./install-fusion.sh

installer-logs:
	cd installer && tail -f logs/*

installer-kill:
	pkill -f 'Fusion Client Downloader.exe|streamer.exe'