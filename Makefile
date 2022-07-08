CONFIG_DIR := /etc
SYSTEMD_UNIT_DIR := /etc/systemd/system

PROJECT_DIR = scream/Receivers/unix
PROJECT_BUILD_DIR = build

update:
	git submodule update --init --recursive

build/receiver/unix:
	mkdir -p $(PROJECT_BUILD_DIR) && cd $(PROJECT_BUILD_DIR)	\
		&& cmake $(realpath $(PROJECT_DIR))	\
		&& $(MAKE)

install/receiver/unix: build/receiver/unix
	cd $(PROJECT_BUILD_DIR)	\
		&& sudo $(MAKE) install

configure/receiver/unix: install/receiver/unix
	sudo adduser --system --no-create-home --disabled-login --group screamd
	sudo cp --interactive --recursive scream.conf scream.d $(CONFIG_DIR)
	sudo cp --force scream@.service $(SYSTEMD_UNIT_DIR)

deploy/receiver/unix: configure/receiver/unix
	-sudo systemctl stop --all 'scream@*'
	sudo systemctl daemon-reload

build: build/receiver/unix
install: install/receiver/unix
configure: configure/receiver/unix
deploy: deploy/receiver/unix

deploy-pulse: deploy
	sudo usermod -a -G pulse-access screamd
	sudo systemctl enable --now scream@default
	sudo systemctl status 'scream@*'
