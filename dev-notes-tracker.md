# Powershell Module MagicGester - Development Notes and Workflow Instructions

MagicGester is evolving from a simple SVG export script into a **professional-grade asset generation and management engine**. Following the **phellams-aa** architectural standards, the goal is to provide a zero-touch, high-performance pipeline for converting vector source assets into a variety of production-ready formats with a rich, TUI-driven feedback loop.

---

## **REPO INSTRUCTIONS**

**TASKS:** Work through task items in the **`dev-notes-tracker.md`** file. If a task is not in its proper category, move it to the correct section. The default categories are: **Bug Fixes (`priority-4`)**, **Issues Remaining (`priority-1`)**, **Features (`priority-3`)**, **Enhancements (`priority-2`)**, **Documentation (`priority-5`)**, **Refactoring (`priority-6`)**, and **Refine Features (`priority-7`)**, and **Refine Documentation (`priority-8`)**. If a task item is incomplete, relies on a temporary workaround rather than best practice, or represents a simple implementation instead of the ideal advanced method, add an inline comment block starting with `> *e*After Thought**` or `> **Note!**` detailing alternatives, potential issues, or future design considerations.

**SKILL HARNESS:** Refer to `phellams-aa` skill for all UI/UX tasks. Refer to the `context-source/` directorY for extended project knowledge and architectural lessons learned.

**VERSIONING:** Refer to the `phellams-aa` versioning strategy for SemVer tags and releases. **git Workflow** !property Build can only be occupied my `major`, `minor`, or `patch` version increments will fail otherwwise.

**CHANGELOG** Keep and active CHANGELOG.md refer to `phellams-aa` has access to `Get-ReleaseNotes.ps1` with the `-AheadOnly` !Note this only works if branch is ahead so before push run this this one and add the output to the semver version using `New-SemVerTag.ps1`. Read params to show how module interacts.

**SELF-IMPROVEMENTS:** Review workspace and project structures to identify area-specific optimization opportunities.

**CONTEXT DIRECTORY:** Use the `context-source/` folder to store AI-related PDRs, context files, and lessons learned. Maintain `extended-knowledge-lessons-learned-building-PLACEHOLDER_NAME.md` as the active log of project insights, which will be compiled into the v1 knowledge base for future runs. << for **SELF-IMPROVEMENTS**

## **GIT WORKFLOW:**

**BRANCHES:** Create a new branch (e.g., `feat/`, `fix/`, etc.) from `develop`. Use descriptive names like `feat/component/icon-improve-hash`.

**MERGE REQUESTS:** Create a Draft Merge Request (MR) in GitLab targeting `develop`. Include details on the planned change, implementation strategy, and expected outcomes.

**LABELS & ASSIGNMENT:** Assign MRs and tasks to user `@sgkens`. Add appropriate workflow labels and delete the source branch after merging.

**BRANCH-REMINDERS** - `Git pull origin develop` before creating a new branch, a new branch might be merge and we need to the changes before branching off.

**IF OUTSTANDING COMMITS** - if feature is complete commit and push.

**FALLBACK:** If context files are missing, scan GitLab issues, milestones, and Git history to rebuild the lessons-learned document.

**CONFLICT RESOLUTION:** If new architectural decisions conflict with older notes, update the documentation to reflect the current standard while noting the rationale.

**GITLAB MCP INTEGRATION:**

* **BRANCHES:** `main` is production; `develop` is the active development branch. Feature branches should use `feature/*`, fixes `fix/*`, hotfixes `hotfix/*`, and releases `release/*`.

* **INTERACTIONS:** Use the GitLab MCP server to manage issues, assign tasks to `@sgkens`, link branches, create milestones, and track status. Close tasks/issues when completed.

***DIFFICULTY:*** 🔴- `Very` 🟠- `moderate` 🟡- `easy` 🟢- `very-easy` 
***SCOPE:___***  💡- `Concepts-skip-from-task-list-unless-asked` 🌟-`feature-apaears-only-on-primary-tasks` 🦀- `bug-apears-only-on-primary-bug` 🪲- `bug-fixed-appears-only-on-primary-bugfix` 🩹-`fix-only-appears-on-primary-tasks`
***COMPLETE:*** ✔️- `parcially-complete` ❓- `working but with issues` ✅-`complete` 🌀- `Working-on`
***PRIORITY*** - 0️⃣1️⃣2️⃣3️⃣4️⃣5️⃣6️⃣7️⃣8️⃣9️⃣🔟- `priority-of-tasks`

---

## **Tasklist**

### **Issues Remaining (priority-1)**
* [x] 🟠🌟✅1️⃣ **FEATURES** - Implement automatic scaling logic for asset generation.
  * [x] 🟡🌟✅1️⃣ ***SUB TASK*** - Calculate auto-scaling ratios based on source dimensions.
* [ ] 🟠🌟▫️2️⃣ **ENHANCEMENTS** - Reduce external dependencies (Inkscape removal investigation).
  > ***NOTE!*** - Magick/FFmpeg might handle SVG to PNG directly with better performance if librsvg is present.

### **Enhancements (priority-2)**
* [x] 🟢🌟✅2️⃣ **TUI** - Implement interactive completion report with color-coded metrics.
* [x] 🟢🌟✅2️⃣ **UI** - Add high-signal media information manager (Show-MGMediaInfo).
* [x] 🟢🌟✅2️⃣ **HELP** - Integrate PHWriter TUI help system for all public cmdlets.

### **Features (priority-3)**
* [x] 🟢🌟✅3️⃣ **ARCH** - Implement object-oriented configuration engine (New-MGConfig).
* [x] 🟢🌟✅3️⃣ **ARCH** - Implement unified high-performance execution pipeline (Invoke-MagicGester).
* [x] 🟢🌟✅3️⃣ **ARCH** - Add high-speed .NET file discovery for source directories.
* [x] 🟢🌟✅3️⃣ **CI** - Implement automated CI/CD release wrapper (New-MGRelease).
* [x] 🟢🌟✅3️⃣ **ARCH** - Integrated ZIP bundling for asset distribution.

### **Bug Fixes (priority-4)**
* [x] 🟢🩹✅4️⃣ **UI** - Fixed variable interpolation and ValidateSet issues in TUI components.
* [x] 🟢🩹✅4️⃣ **ARCH** - Resolved variable collision and syntax errors in private utilities.

### **Documentation (priority-5)**
* [x] 🟡🌟✅5️⃣ **DOCS** - Update README.md with professional Phellams-style snippets and badges.
* [x] 🟡🌟✅5️⃣ **DOCS** - Implement comprehensive API Reference section.
* [x] 🟡🌟✅5️⃣ **DOCS** - Finalize cmdlet help documentation using PHWriter metadata.

### **Refactoring (priority-6)**
* [x] 🟢🌟✅6️⃣ **ARCH** - Complete architectural transition to src/ (Public, Private, UI, Helpers).
* [x] 🟢🌟✅6️⃣ **ARCH** - Implement strict root module loader with export control.
* [x] 🟢🌟✅6️⃣ **HELPERS** - Port and standardize phellams-utils into src/Helpers.
* [x] 🟢🌟✅6️⃣ **CI** - Implement production-grade GitLab CI/CD pipeline using Phellams templates.
* [x] 🟢🌟✅6️⃣ **CONFIG** - Standardize build process with Phellams build_config.json.

### **Refine Features (priority-7)**

### **Refine Documentation (priority-8)**

### **Backlog**
- [ ] 🟢 provide new helpers in the srcs helpers folder, `new-Asciicolor`, and `Get-terpal`, a more advance version of `new-asciicolor`, and also New-Spinner, perhaps create an additional helper call new-simplebar and use it to generate a ascii gradient bar, with borders complete, stage, and simple-trailog helper,  make new helpers rebusts so they can be taken out and use with other modules.
- [ ] 🟢 We are not calculating length before ascii color encoding, this will break alignment and cause screen tears,
- [ ] 🟢 We need to wrap
- [ ] 🟢 **avif** - support avif
- [ ] 🟢 **all-image-media-formats** - support all
- [ ] 🟢 `Show-MGMediaInfo` - pros should have info title 
  - [ ]   `kvinc` lets ajust kvinc `INF|WRD` to take in a param and output it in same caps,
  - [ ]  `wiki` - add a wiki link for each image type, or a better site if there is one.
### **Backlog**

- [x] 🟢🌟✅ **RISIZE** - Any Extention and output resized to the target resolution.
- [x] 🟢🌟✅ **COMPRESSION** - Any Extention and output compressed to the target resolution.
- [x] 🟢🌟✅ **OPTIMIZATION** - Provide a way to optimize the output file size.
- [x] 🟢🌟✅ **EXTRA-VISUALIZATION** - Visualize the action performed and what it generates.
- [x] 🟢🌟✅ **Zip-Bundle** - Bundle the output into a single zip file, with custom nameing convention ie bundle-`version`.zip.
- [x] 🟢🌟✅ **UI Refinement** - Refine the TUI to provide more information and better visualization.
