run:
	bash -x launch-fusion.sh

kill:
	pkill -f 'Fusion360|AdskIdentity|ADPClientService|msedgewebview2|adexmtsv|proton run /home/aaa/.fusion360-proton2|steam.exe .*Fusion360'

ps:
	pgrep -af 'Fusion360|AdskIdentity|ADPClientService|msedgewebview2|adexmtsv|proton run /home/aaa/.fusion360-proton2|steam.exe .*Fusion360' || true
