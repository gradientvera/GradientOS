{ fetchFromGitHub
, home-assistant
, buildHomeAssistantComponent
}:
let
  owner = "acon96";
  version = "0.4.9";
  pythonPkgs = home-assistant.python3Packages;
in buildHomeAssistantComponent {
  inherit version owner;
  domain = "llama_conversation";

  src = fetchFromGitHub {
    inherit owner;
    repo = "home-llm";
    rev = "v${version}";
    hash = "sha256-Rw6y0wZJdqcboxfCNorIuMney3VjvuIIacHa3mZHK5o=";
  };

  propagatedBuildInputs = with pythonPkgs; [
    huggingface-hub
    ollama
    openai
    anthropic
    webcolors
    # This derivation is ONLY used for this integration, so just keep it here
    (let
      pname = "fuzy-jon";
      owner = "livingbio";
      version = "0.2.1";
    in pythonPkgs.buildPythonPackage {
      inherit pname version;
      pyproject = true;
      src = fetchFromGitHub {
        inherit owner;
        repo = "fuzzy-json";
        rev = "${version}";
        hash = "sha256-SNu1UTAw5vY8xb839yUrJrk6sVkg60cIGbM8aXTE/Fw=";
      };

      build-system = [
        pythonPkgs.hatchling
      ];

      dependencies = with pythonPkgs; [
        json5
      ];
    })
  ];
}