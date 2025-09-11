build:
	./build.sh

deploy:
	./deploy.sh

dev:
	@echo "[*] Building in development mode"
	@while true; do ./build.sh; sleep 5; done
