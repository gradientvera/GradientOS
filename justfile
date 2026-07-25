@default $JUST_CHOOSER="nix run nixpkgs#fzf":
    just --choose

run HOST *COMMAND:
    #! /usr/bin/env bash
    IP=$(nix eval --quiet --raw .#nixosConfigurations.{{HOST}}.config.deployment.targetHost)
    ssh -t $IP "{{COMMAND}}"

logs HOST UNIT: (run HOST "sudo journalctl -xefu" UNIT)

check:
    nix flake check --keep-going --show-trace

# funny hehe
vacuum:
    rsync -e 'ssh -p 222' -avzP --chmod=0760 --chown=root:root ./misc/vacuum/ root@vacuum-angela:/data
    rsync -e 'ssh -p 222' -avzP --chmod=0760 --chown=root:root ./misc/vacuum/ root@vacuum-roland:/data

vacuum-local:
    rsync -e 'ssh -p 222' -avzP --chmod=0760 --chown=root:root ./misc/vacuum/ root@valetudo-leanunfinishedjellyfish.local:/data
    rsync -e 'ssh -p 222' -avzP --chmod=0760 --chown=root:root ./misc/vacuum/ root@valetudo-ironcladrashmink.local:/data

vacuumstreamer IP:
    #! /usr/bin/env nix-shell
    #! nix-shell -i bash -p git podman openssh gnused
    rm -rf ./vacuumstreamer
    git clone "https://github.com/brunsy/vacuumstreamer.git"
    cd vacuumstreamer
    git reset --hard "83d99b8d151190f8e860415eab735401f552b33c"
    podman build -t vacuumstreamer .
    sed -i -e 's/vacuumstreamer sh/localhost\/vacuumstreamer:latest sh/g' -e 's/docker/podman/g' build.sh
    VACUUM_ROBOT_IP={{IP}} ./build.sh
    ssh -p 222 root@{{IP}} 'mkdir -p /data/vacuumstreamer/video_monitor-conf' 
    cp -r "./dist/ava/conf/video_monitor" "./video_monitor-conf"
    scp -P 222 -r "./video_monitor-conf" "root@{{IP}}:/data/vacuumstreamer"
    scp -P 222 "./video_monitor" "root@{{IP}}:/data/vacuumstreamer/video_monitor"
    scp -P 222 "./vacuumstreamer.so" "root@{{IP}}:/data/vacuumstreamer/vacuumstreamer.so"
    ssh -p 222 root@{{IP}} 'chmod +x /data/vacuumstreamer/video_monitor'
    cd ..
    rm -rf ./vacuumstreamer

[group('deployment')]
update-inputs:
    nix flake update
    just check

[group('deployment')]
switch HOST:
    @just apply switch {{HOST}}

[group('deployment')]
apply OPERATION HOST:
    @if [ "{{HOST}}" = "local" ]; then \
        just apply-local {{OPERATION}}; \
    else \
        colmena apply {{OPERATION}} --on={{HOST}} --evaluator=streaming --build-on-target; \
    fi;

[group('deployment')]
apply-local OPERATION:
    @sudo colmena apply-local {{OPERATION}} --sudo --show-trace

[group('secrets')]
edit-secret HOST $EDITOR="code --wait":
    sops ./hosts/{{HOST}}/secrets/secrets.yml

[group('secrets')]
edit-secret-kanidm $EDITOR="code --wait":
    sops --input-type=binary ./hosts/asiyah/secrets/kanidm-provisioning.encjson

[group('secrets')]
edit-secret-core $EDITOR="code --wait":
    sops ./core/secrets/secrets.yml

[group('secrets')]
edit-secret-headscale $EDITOR="code --wait":
    sops --input-type=binary ./hosts/briah/secrets/headscale.encsql

[group('secrets')]
edit-secret-vacuum $EDITOR="code --wait":
    sops ./misc/vacuum/secrets/secrets.yml

[group('secrets')]
edit-secret-asiyah:
    just edit-secret asiyah

[group('secrets')]
edit-secret-briah:
    just edit-secret briah

[group('secrets')]
edit-secret-atziluth:
    just edit-secret atziluth

[group('secrets')]
edit-secret-bernkastel:
    just edit-secret bernkastel

[group('secrets')]
edit-secret-erika:
    just edit-secret erika

[group('secrets')]
edit-secret-featherine:
    just edit-secret featherine

[group('secrets')]
edit-secret-roland:
    just edit-secret roland

[group('secrets')]
edit-secret-neith-deck:
    just edit-secret neith-deck

[group("editing")]
edit-remote HOST PATH:
    code sftp://root@{{HOST}}{{PATH}}