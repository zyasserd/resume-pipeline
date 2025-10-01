# ROADMAP


## Core Pipeline Improvements
- separate data from representation
	- another yaml file that specifies the design

- option to override (last updated) or at least remove it

- define different ANSI themes

- html output
	- Would you need a html or md for the website?
		- check out jsonresume style websites
			- https://github.com/rbardini/resumed

- ATS (Applicant Tracking System) Optimization
	- why is it important?
	- implement an automatic checker
	- sth like what `jobscan.co` do

- versioned resumes
	- "tailor the resume to each job application"
	- "make couple of resume for different domains"

- LLM integration
	- for feedback
	- versioned resumes
	- bulk cover letter writing program/hiring manager finder



## RenderCV Enhancements
- Add a themes directory flag
    - would be best if you could specify the theme for each extension/target i.e. `--ansi themes/ANSI --typst themes/sb2nov`
- Support different `.j2.ext` formats (e.g., json) as an output target, with themes.
    - having that combined with json2ansi, would allow RenderCV to have an ANSI target.
    - allow passing arguments to the ANSI theme in the YAML file
        - `terminal width`
- Make resume.yaml path detection automatic (CLI should compute the path)
    - Currently, you have to run `rendercv` with the YAML file in the current directory.
- Allow specifying the typst executable



## Reproducible Typst Builds
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



