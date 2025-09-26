# resume-pipeline

This repository provides a reproducible pipeline for building resumes using [RenderCV](https://github.com/rendercv/rendercv) and Nix.

It automates the process of converting a YAML resume into multiple output formats (PDF, ANSI, cleaned YAML) using customizable themes and templates.
The included shell script orchestrates the conversion, theme management, and output generation, making resume creation streamlined and reproducible.

## Pipeline Overview

```mermaid
flowchart LR
    %% Inputs grouped
    subgraph IN[Inputs]
        direction TB
        N_INPUT[resume.yaml]:::data
        N_THEMES[(themes dir)]:::internal
    end

    %% Process nodes
    P_RenderCV([RenderCV]):::process
    P_JSON2ANSI([json2ansi]):::process
    P_YQ([yq]):::process

    %% Internal pipeline under RenderCV
    subgraph RCV[RenderCV internals]
        direction LR
        J2([Jinja2]):::internalProcess
        TYP([Typst]):::internalProcess
        J2 -- ".typ" --> TYP
    end

    %% Outputs grouped
    subgraph OUT[Outputs]
        direction TB
        OUT_PDF[resume.pdf]:::data
        OUT_ANSI[resume.ansi]:::data
        OUT_YAML[resume.yaml]:::data
    end

    %% Flows
    N_INPUT -- "input" --> P_RenderCV
    N_THEMES -. "internal use" .-> P_RenderCV

    %% Show RenderCV using internals
    P_RenderCV --> J2
    TYP --> OUT_PDF
    J2 -- ".md (as a workaround)" --> C[resume.ansi.json]:::data

    C --> P_JSON2ANSI
    P_JSON2ANSI --> OUT_ANSI
    N_INPUT --> P_YQ
    P_YQ -- "removing comments & design section" --> OUT_YAML

```

## Usage

To build your resume, run:

```sh
nix run github:zyasserd/resume-pipeline <resume.yaml>
```

## Output

After running the pipeline, an `output` directory will be created in your working directory. This folder will contain:

- `resume.pdf` (PDF version)
- `resume.ansi` (ANSI text)
- `resume.yaml` (Cleaned YAML)

You can customize themes and templates by editing files in the `themes/` directory.

<br>
<br>
<br>

# TODOs

## TODO: RenderCV To-Improve
- Add a themes directory flag
- Support different `.j2.ext` formats (e.g., json) as an output target, with themes.
    - having that combined with json2ansi, would allow RenderCV to have an ANSI target.
- Make resume.yaml path detection automatic (CLI should compute the path)
- Allow specifying the typst executable

## TODO: Typst Extensions and Nix
**Goal:**  
Achieve fully reproducible builds by ensuring Typst extensions are managed by Nix, not downloaded at runtime.

**Current Issue:**  
RenderCV uses `messense/typst-py`, which bundles its own Typst binary. This makes it difficult to inject extensions managed by Nix.

**Options:**  
1. Dynamically load extensions from Nixpkgs into the Typst used by `messense/typst-py`.
2. Replace the Typst binary in RenderCV with a Nix-built Typst that includes required extensions.
3. Disable PDF rendering in RenderCV and manually render with a Nix-built Typst (using `typst.withPackages`).

**Note:**
Currently, Nix only builds the script. At runtime (when building the resume), Typst can access the internet, so extensions may still be fetched dynamically.

## TODO: Others
- Should you separate content YAML from design YAML?

