help:
	@echo "make podman  -> create podman image"
	@echo "make docker  -> create docker image (probably needs sudo)"
	@echo 'make podman-run -> run podman image, mounting RNO_G_WORKSPACE to /rno-g and RNO_G_DATA to /data if it exists'
	@echo 'make docker-run -> run docker image, mounting RNO_G_WORKSPACE to /rno-g and RNO_G_DATA to /data if it exists (probably needs sudo)'
	@echo 'make run-podman -> alias for podman-run'
	@echo 'make run-docker -> alias for docker-run'


WORKSPACE_MOUNT := $(shell [ -d "$(RNO_G_WORKSPACE)" ] && echo "-v $(RNO_G_WORKSPACE):/rno-g:z")
DATA_MOUNT := $(shell [ -d "$(RNO_G_DATA)" ] && echo "-v $(RNO_G_DATA):/data:z")

podman: setup-mount.sh Containerfile
	podman build -t rno-g-cvmfs .

docker: setup-mount.sh Containerfile
	docker build -t rno-g-cvmfs -f Containerfile .

podman-run:
	podman run -it --rm \
	--device /dev/fuse \
	--user root\
	--cap-add SYS_ADMIN \
	--security-opt label=disable \
	--hostname rno-g-cvmfs-el9 \
	-e HOST_UID=$$(id -u) \
	-e HOST_GID=$$(id -g) \
	$(WORKSPACE_MOUNT) \
	$(DATA_MOUNT) \
	rno-g-cvmfs

docker-run:
	docker run -it --rm \
	--device /dev/fuse \
	--user root\
	--cap-add SYS_ADMIN \
	--security-opt label=disable \
	--hostname rno-g-cvmfs-el9 \
	-e HOST_UID=$${SUDO_UID:-$$(id -u)} \
	-e HOST_GID=$${SUDO_GID:-$$(id -g)} \
	$(WORKSPACE_MOUNT) \
	$(DATA_MOUNT) \
	rno-g-cvmfs


run-podman: podman-run
run-docker: docker-run


