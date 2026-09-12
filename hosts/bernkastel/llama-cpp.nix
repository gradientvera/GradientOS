{
  config,
  pkgs,
  ...
}:
let
  inherit (config.gradient.presets.llama-swap)
    mkCmd
    servers
    stateDir
    ;
  inherit (servers) rocm;
in
{

  gradient.presets.llama-swap = {
    enable = true;
    # Both repos are public/ungated; no HF token needed on this host.
    hfTokenPath = null;
    openFirewallInterfaces = [
      "gradientnet"
    ];

    models = {
      "Qwen3.8-27B" = {
        repo = "unsloth/Qwen3.8-27B-GGUF";
        includes = [ "Qwen3.8-27B-UD-IQ4_XS.gguf" ];

        settings.cmd = mkCmd {
          serverPath = rocm;
          port = "$1";
          model = "${stateDir}/Qwen3.8-27B/Qwen3.8-27B-UD-IQ4_XS.gguf";
          ctx-size = "49152";
          cache-type-k = "q4_0";
          cache-type-v = "q4_0";
          n-gpu-layers = "999";
          threads = "16";
          threads-batch = "16";
          jinja = true;
          reasoning = "off";
          temp = "0.6";
          top-p = "0.9";
          top-k = "40";
          slot-save-path = "${stateDir}/Qwen3.8-27B";
        };
      };

      "gpt-oss-20b" = {
        repo = "ggml-org/gpt-oss-20b-GGUF";
        includes = [ "gpt-oss-20b-MXFP4.gguf" ];

        settings.cmd = mkCmd {
          serverPath = rocm;
          port = "$1";
          model = "${stateDir}/gpt-oss-20b/gpt-oss-20b-MXFP4.gguf";
          ctx-size = "32768";
          cache-type-k = "q8_0";
          cache-type-v = "q8_0";
          n-gpu-layers = "999";
          threads = "16";
          threads-batch = "16";
          jinja = true;
          temp = "1.0";
          top-p = "1.0";
          top-k = "0";
          slot-save-path = "${stateDir}/gpt-oss-20b";
        };
      };
    };
  };

}
