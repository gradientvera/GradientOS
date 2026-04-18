# Taken and modified from https://github.com/NixOS/nixpkgs/blob/nixos-25.11/pkgs/by-name/ry/ryubing/package.nix at cca3b04b44a5c57502fe2440cc3d2114779cc40c
# nixpkgs is licensed under the MIT license, see here: https://github.com/NixOS/nixpkgs/blob/master/COPYING
# ---
# Update instructions:
# 1. Change version and src.tag to latest canary
# 2. Set src.hash to an empty string
# 3. Run `nix build <self>#ryubing-canary`, replace empty src.hash by correct hash
# 4. Run `nix run <self>#ryubing-canary.fetch-deps -- ./pkgs/ryubing-canary-deps.json`
# 5. Confirm `nix run <self>#ryubing-canary` works and you're done!
{
  lib,
  ryubing,
  buildDotnetModule,
  cctools,
  darwin,
  dotnetCorePackages,
  fetchgit,
  libX11,
  libgdiplus,
  moltenvk,
  ffmpeg,
  openal,
  libsoundio,
  sndio,
  stdenv,
  pulseaudio,
  vulkan-loader,
  glew,
  libGL,
  libICE,
  libSM,
  libXcursor,
  libXext,
  libXi,
  libXrandr,
  udev,
  sdl3,
  SDL2,
  SDL2_mixer,
  gtk3,
  wrapGAppsHook3,
}:

buildDotnetModule rec {
  pname = "ryubing";
  version = "1.3.271";

  src = fetchgit {
    url = "https://git.ryujinx.app/projects/Ryubing.git";
    tag = "Canary-1.3.271";
    hash = "sha256-klmhC75a21/wlaZEU0ZRV59+Bxw5zVp7fJbHRP2seZk=";
  };

  nativeBuildInputs =
    lib.optional stdenv.hostPlatform.isLinux [
      wrapGAppsHook3
    ]
    ++ lib.optional stdenv.hostPlatform.isDarwin [
      cctools
      darwin.sigtool
    ];

  enableParallelBuilding = false;

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;

  nugetDeps = ./ryubing-canary-deps.json;

  runtimeDeps = [
    libX11
    libgdiplus
    sdl3
    SDL2_mixer
    openal
    libsoundio
    sndio
    vulkan-loader
    ffmpeg

    # Avalonia UI
    glew
    libICE
    libSM
    libXcursor
    libXext
    libXi
    libXrandr
    gtk3

    # Headless executable
    libGL
    SDL2
  ]
  ++ lib.optional (!stdenv.hostPlatform.isDarwin) [
    udev
    pulseaudio
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin [ moltenvk ];

  projectFile = "Ryujinx.sln";
  testProjectFile = "src/Ryujinx.Tests/Ryujinx.Tests.csproj";

  # Sue me, I want fast compile times >:)
  doCheck = false;

  dotnetFlags = [
    "/p:ExtraDefineConstants=DISABLE_UPDATER%2CFORCE_EXTERNAL_BASE_DIR"
  ];

  executables = [
    "Ryujinx"
  ];

  makeWrapperArgs = lib.optional stdenv.hostPlatform.isLinux [
    # Without this Ryujinx fails to start on wayland. See https://github.com/Ryujinx/Ryujinx/issues/2714
    "--set SDL_VIDEODRIVER x11"
  ];

  preInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
    # workaround for https://github.com/Ryujinx/Ryujinx/issues/2349
    mkdir -p $out/lib/sndio-6
    ln -s ${sndio}/lib/libsndio.so $out/lib/sndio-6/libsndio.so.6
  '';

  preFixup = ''
    ${lib.optionalString stdenv.hostPlatform.isLinux ''
      mkdir -p $out/share/{applications,icons/hicolor/scalable/apps,mime/packages}

      pushd ${src}/distribution/linux

      install -D ./Ryujinx.desktop  $out/share/applications/Ryujinx.desktop
      install -D ./Ryujinx.sh       $out/bin/Ryujinx.sh
      install -D ./mime/Ryujinx.xml $out/share/mime/packages/Ryujinx.xml
      install -D ../misc/Logo.svg   $out/share/icons/hicolor/scalable/apps/Ryujinx.svg

      substituteInPlace $out/share/applications/Ryujinx.desktop \
        --replace-fail "Name=Ryujinx" "Name=Ryujinx (canary)"

      mv $out/share/applications/Ryujinx.desktop $out/share/applications/Ryujinx-canary.desktop

      popd
    ''}

    # Don't make a softlink on OSX because of its case insensitivity
    ${lib.optionalString (!stdenv.hostPlatform.isDarwin) "ln -s $out/bin/Ryujinx $out/bin/ryujinx"}
  '';

  passthru.updateScript = ryubing.updateScript;

  meta = {
    homepage = "https://ryujinx.app";
    changelog = "https://git.ryujinx.app/ryubing/ryujinx/-/wikis/changelog";
    description = "Experimental Nintendo Switch Emulator written in C# (community fork of Ryujinx)";
    longDescription = ''
      Ryujinx is an open-source Nintendo Switch emulator, created by gdkchan,
      written in C#. This emulator aims at providing excellent accuracy and
      performance, a user-friendly interface and consistent builds. It was
      written from scratch and development on the project began in September
      2017. The project has since been abandoned on October 1st 2024 and QoL
      updates are now managed under a fork.
    '';
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      jk
      artemist
      willow
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
    mainProgram = "Ryujinx";
  };
}