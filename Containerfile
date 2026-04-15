# Use AlmaLinux 9 minimal as the EL9 base
FROM almalinux:9-minimal

# Create an RNO-G User
RUN groupadd -g 1000 rno-g && useradd -u 1000 -g 1000 -m -s /bin/bash rno-g

# We need FUSE and wget (use microdnf since no dnf in minimal)
RUN microdnf -y install epel-release wget fuse vim-minimal vim glibc-devel && \
    microdnf clean all

# Install the CVMFS release package and the CVMFS client
RUN rpm -Uvh https://ecsft.cern.ch/dist/cvmfs/cvmfs-release/cvmfs-release-latest.noarch.rpm && \
    microdnf -y install cvmfs && \
    microdnf clean all

# Configure CVMFS for RNO-G
RUN mkdir -p /etc/cvmfs && \
    echo "CVMFS_REPOSITORIES=rnog.opensciencegrid.org" > /etc/cvmfs/default.local && \
    echo "CVMFS_CLIENT_PROFILE=single" >> /etc/cvmfs/default.local && \
    echo "CVMFS_HTTP_PROXY=DIRECT" >> /etc/cvmfs/default.local

# Create the mount target (autofs is tricky in a container)
RUN mkdir -p /cvmfs/rnog.opensciencegrid.org
RUN mkdir -p /rno-g && chown rno-g:rno-g /rno-g
RUN mkdir -p /data && chown rno-g:rno-g /data

RUN  echo "If you have an environmental variable named RNO_G_WORKSPACE, that folder will get mounted on top of here" > /rno-g/HOWTOPERSIST
RUN  echo "If you have an environmental variable named RNO_G_DATA , that folder will get mounted on top of here" > /data/HUH

# Add script as workaround for autofs
COPY setup-mount.sh /setup-mount.sh
RUN chmod +x /setup-mount.sh

# Use the script to mount FUSE before dropping into the shell
ENTRYPOINT ["/setup-mount.sh"]
