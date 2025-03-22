@default $JUST_CHOOSER="nix run nixpkgs#fzf":
    just --choose

[group('deployment')]
switch HOST:
    colmena apply switch --on={{HOST}} --evaluator=streaming

[group('secrets')]
edit-secret HOST $EDITOR="code --wait":
    sops ./hosts/{{HOST}}/secrets/secrets.yml

[group('secrets')]
edit-secret-kanidm $EDITOR="code --wait":
    sops --input-type=binary ./hosts/asiyah/secrets/kanidm-provisioning.json

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