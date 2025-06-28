@default $JUST_CHOOSER="nix run nixpkgs#fzf":
    just --choose

run HOST *COMMAND:
    #! /usr/bin/env bash
    IP=$(nix eval --quiet --raw .#nixosConfigurations.{{HOST}}.config.deployment.targetHost)
    ssh -t $IP "{{COMMAND}}"

logs HOST UNIT: (run HOST "sudo journalctl -xefu" UNIT)

check:
    nix flake check --keep-going --show-trace

playbook:
    nix run .\#ansible-playbook

[group('deployment')]
update-inputs:
    nix flake update
    nix flake check --keep-going --show-trace

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
edit-secret-asiyah:
    just edit-secret asiyah

[group('secrets')]
edit-secret-briah:
    just edit-secret briah

[group('secrets')]
edit-secret-atziluth:
    just edit-secret atziluth

[group('secrets')]
edit-secret-beatrice:
    just edit-secret beatrice

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
edit-secret-neith-deck:
    just edit-secret neith-deck

[group("editing")]
edit-remote HOST PATH:
    code sftp://root@{{HOST}}{{PATH}}