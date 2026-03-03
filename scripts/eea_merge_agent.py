import os
import sys
import subprocess
import json

# Ensure the scripts directory is on sys.path for imports
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
if SCRIPT_DIR not in sys.path:
    sys.path.insert(0, SCRIPT_DIR)

from eea_merge_utils import (
    load_state, save_state, run_cmd, ARTIFACTS_DIR, check_gemini_available, log_validation
)

def build_agent_prompt(filepath, state_entry, patches_content):
    patch_id = state_entry.get("patch_id")
    if patch_id:
        patch_file = os.path.join(ARTIFACTS_DIR, "patches", f"{patch_id}.md")
        if os.path.exists(patch_file):
            with open(patch_file, "r") as pf:
                patch_details = pf.read()
            patch_info = (
                f"This file is related to EEA Patch {patch_id}. Context:\n\n"
                f"<patch_context>\n{patch_details}\n</patch_context>"
            )
        else:
            patch_info = f"This file is related to EEA Patch {patch_id}."
    else:
        patch_info = "No specific EEA patch documented. Review `patches-overview.md` if needed."

    template_path = os.path.join(SCRIPT_DIR, "prompts", "agentic_resolution_prompt.txt")
    with open(template_path, "r") as f:
        template = f.read()

    return template.format(
        filepath=filepath,
        conflict_type=state_entry.get("conflict_type", "unknown"),
        status=state_entry.get("status", "unknown"),
        patch_info=patch_info
    )

def run_agentic_resolution(filepath, state_entry, patches_content, model):
    print(f"\n--- Booting Agent for {filepath} ---")
    prompt = build_agent_prompt(filepath, state_entry, patches_content)

    # Note: --yolo auto-approves tool uses.
    cmd = [
        "gemini", 
        "-m", model, 
        "--yolo", 
        "-p", prompt
    ]

    print(f"Running agent for {filepath}...")
    try:
        # Stream the output so the user can watch the agent work in real time
        process = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True
        )

        output_log = []
        for line in process.stdout:
            print(line, end="")
            output_log.append(line)

        process.wait()
        full_output = "".join(output_log)

        if process.returncode != 0:
            print(f"Agent failed with return code {process.returncode}")
            return False

        if "RESOLUTION COMPLETE" in full_output:
            print(f"Agent successfully resolved {filepath}.")
            return True
        else:
            print(f"Agent finished, but 'RESOLUTION COMPLETE' not found. It might have failed.")
            return False

    except Exception as e:
        print(f"Failed to run agent for {filepath}: {e}")
        return False

def main():
    import argparse
    parser = argparse.ArgumentParser(description="EEA Merge Phase 3: Agentic Resolution")
    parser.add_argument("--model", default="gemini-3.1-pro-preview", 
                        help="LLM model to use for the agent")
    args = parser.parse_args()

    if not check_gemini_available():
        print("Error: Gemini CLI not available.")
        sys.exit(1)

    state = load_state()
    if not state:
        print("No state found. Run init phase first.")
        sys.exit(1)

    patch_doc_path = os.path.join(ARTIFACTS_DIR, "patches-overview.md")
    patches_content = ""
    if os.path.exists(patch_doc_path):
        with open(patch_doc_path, "r") as f:
            patches_content = f.read()

    # Find files that require human intervention
    target_files = []
    for filepath, entry in state.items():
        if entry["status"] in ["requires_human", "failed_requires_human"]:
            target_files.append((filepath, entry))

    if not target_files:
        print("\nNo files require agentic resolution. Skipping Phase 3.")
        sys.exit(0)

    print(f"\nPhase 3: Launching Agent for {len(target_files)} complex conflicts...")

    resolved_count = 0
    for filepath, entry in target_files:
        success = run_agentic_resolution(filepath, entry, patches_content, args.model)
        if success:
            entry["status"] = "resolved_and_verified"
            resolved_count += 1
        else:
            # Leave it as requires_human if the agent fails, so a real human can intervene
            print(f"Agent could not resolve {filepath}. Human intervention still required.")
        
        save_state(state)

    print(f"\nAgentic Resolution Complete. Resolved {resolved_count}/{len(target_files)} files.")

if __name__ == "__main__":
    main()
