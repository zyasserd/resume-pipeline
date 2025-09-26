{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    json2ansi.url = "github:zyasserd/json2ansi";
  };

  outputs = { self, nixpkgs, json2ansi }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
      };

      scriptName = "resume-pipeline";
      resumeFileName = "Zyad_Yasser_CV";

      # Idiomatic: reference the themes directory directly
      themesDir = ./themes;

      buildInputs = with pkgs; [
        rendercv
        yq-go # Command-line yaml processor
        json2ansi.packages.${system}.default
      ];

      # # Typst with extensions
      # typst_custom = pkgs.typst.withPackages (p: with p; [
      #   fontawesome
      # ]);

      # # Overriding RenderCV to include a different rev
      # rendercv_custom = pkgs.rendercv.overridePythonAttrs (old: {
      #   src = pkgs.fetchFromGitHub {
      #     owner = "rendercv";
      #     repo = "rendercv";
      #     rev = "e16eb7b";
      #     sha256 = "sha256-QRQC325cOVs0IqTZvetxWXYdQXERDBDsBIwVeYDoxls=";
      #   };
      #   disabledTests = old.disabledTests ++ [
      #     "test_create_a_pdf_from_a_yaml_string"
      #     "test_create_a_pdf_from_a_python_dictionary"
      #   ];
      # });

    in
    {
      devShells.${system}.default = pkgs.mkShell {
        inherit buildInputs;
      };

      packages.${system}.default = pkgs.writeShellApplication {
        name = scriptName;
        runtimeInputs = buildInputs;
        text = ''
        set -euo pipefail

        # ------------------------------
        #   DIRECTORIES SETUP
        # ------------------------------
        INPUT_YAML="$(realpath "$1")"
        OUTPUT_DIR="$(pwd)/result"
        mkdir -p "$OUTPUT_DIR"
        TMPDIR="$(mktemp -d)"


        # ------------------------------
        #   PROCESSING
        # ------------------------------
        
        # [[ copy the themes dir ]]
        cp -r "${themesDir}" "$TMPDIR/themes"
        chmod -R u+w "$TMPDIR/themes"

        # [[ RUNNING RenderCV ]]
        yq 'del(.design.ansi)' "$INPUT_YAML" > "$TMPDIR/themes/resume.yaml"
        cd "$TMPDIR/themes"
        rendercv render resume.yaml -nopng -nohtml --pdf-path "../resume.pdf" --markdown-path "../resume.ansi.json"

        # [[ ANSI PROCESSING ]]
        json2ansi "../resume.ansi.json" \
            --output "../resume.ansi" \
            --width "$(yq '.design.ansi.width // 100' "$INPUT_YAML")"

        # [[ YAML PROCESSING ]]
        # removes the 'design' section, and all the comments
        yq 'del(.design) | ... comments=""' "$INPUT_YAML" > "$TMPDIR/resume.yaml"



        # ------------------------------
        #   OUTPUT
        # ------------------------------
        
        # pdf <- (RenderCV: internally using j2 and typst) <- yaml
        cp "$TMPDIR/resume.pdf" "$OUTPUT_DIR/${resumeFileName}.pdf"

        # ansi <- json2ansi <- .ansi.json <- (RenderCV: using the markdown template as a work around for now) <- yaml
        cp "$TMPDIR/resume.ansi" "$OUTPUT_DIR/${resumeFileName}.ansi"

        # cleaned yaml <- (yq) <- yaml
        cp "$TMPDIR/resume.yaml" "$OUTPUT_DIR/${resumeFileName}.yaml"

        # .ansi.json
        # cp "$TMPDIR/resume.ansi.json" "$OUTPUT_DIR/${resumeFileName}.ansi.json"



        # ------------------------------
        #   CLEAN UP
        # ------------------------------
        chmod -R u+w "$TMPDIR"
        rm -rf "$TMPDIR"

        '';

      };
    };
}
