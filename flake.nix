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

      dependencyDirs = {
        themes = ./themes;
        scripts = ./scripts;
      };

      python = (pkgs.python3.withPackages (p: with p; [
        pymupdf
        jinja2
      ]));

      buildInputs = with pkgs; [
        rendercv
        yq-go # Command-line yaml processor
        json2ansi.packages.${system}.default
        python
        tree
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

      packages.${system}.default = pkgs.writeShellApplication rec {
        name = "resume-pipeline";
        runtimeInputs = buildInputs;
        text = ''
        set -euo pipefail

        # ------------------------------
        #   DIRECTORIES SETUP
        # ------------------------------
        usage() {
          echo "Usage: ${name} <input_yaml> [output_basename]"
          echo "  <input_yaml>: Path to the input YAML file."
          echo "  [output_basename]: (Optional) Basename for output files (default: resume)"
        }

        if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
          usage
          exit 1
        fi

        if [ "$#" -ge 2 ]; then
          resumeFileName="$2"
        else
          resumeFileName="resume"
        fi

        INPUT_YAML="$(realpath "$1")"
        OUTPUT_DIR="$(pwd)/result"
        mkdir -p "$OUTPUT_DIR"
        TMPDIR="$(mktemp -d)"



        # ------------------------------
        #   PROCESSING
        # ------------------------------
        
        # [[ copy the themes dir ]]
        cp -r "${dependencyDirs.themes}" "$TMPDIR/themes"
        chmod -R u+w "$TMPDIR/themes"

        # [[ copy the scripts dir ]]
        cp -r "${dependencyDirs.scripts}" "$TMPDIR/scripts"
        chmod -R u+w "$TMPDIR/scripts"

        # [[ RUNNING RenderCV ]]
        yq 'del(.design.ansi)' "$INPUT_YAML" > "$TMPDIR/themes/resume.yaml"
        cd "$TMPDIR/themes"
        rendercv render resume.yaml -nopng -nohtml --pdf-path "../resume.pdf" --markdown-path "../resume.ansi.json"

        # [[ ANSI PROCESSING ]]
        json2ansi "../resume.ansi.json" \
            --output "../resume.ansi" \
            --width "$(yq '.design.ansi.width // 80' "$INPUT_YAML")"

        # [[ YAML PROCESSING ]]
        # removes the 'design' section, and all the comments
        yq 'del(.design) | ... comments=""' "$INPUT_YAML" > "$TMPDIR/resume.yaml"



        # ------------------------------
        #   OUTPUT
        # ------------------------------
        
        # pdf <- (RenderCV: internally using j2 and typst) <- yaml
        cp "$TMPDIR/resume.pdf" "$OUTPUT_DIR/$resumeFileName.pdf"

        # ansi <- json2ansi <- .ansi.json <- (RenderCV: using the markdown template as a work around for now) <- yaml
        cp "$TMPDIR/resume.ansi" "$OUTPUT_DIR/$resumeFileName.ansi"

        # cleaned yaml <- (yq) <- yaml
        cp "$TMPDIR/resume.yaml" "$OUTPUT_DIR/$resumeFileName.yaml"

        # .ansi.json
        # cp "$TMPDIR/resume.ansi.json" "$OUTPUT_DIR/$resumeFileName.ansi.json"


        # flattened_pdf_lost_links.html <- (extract_pdf_links.py) <- pdf
        ${python.interpreter} "$TMPDIR/scripts/extract_pdf_links.py" "$OUTPUT_DIR/$resumeFileName.pdf" > "$OUTPUT_DIR/flattened_pdf_lost_links.html"

        # create an index file
        cd "$OUTPUT_DIR" && tree -H "" -h -D --timefmt="%Y-%m-%d %z" -o index.html



        # ------------------------------
        #   CLEAN UP
        # ------------------------------
        chmod -R u+w "$TMPDIR"
        rm -rf "$TMPDIR"

        '';

      };
    };
}
