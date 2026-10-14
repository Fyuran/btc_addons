#!/usr/bin/env python3
"""
BTC Arma 3 Child Class Skeleton Generator
Parses an existing Arma 3 config/GUI class (including all nested children and Controls)
and generates the exact derived skeleton needed for child class inheritance:

    class GVAR(ctrlListEdit): GVAR(ctrlList)
    {
        class Controls: Controls
        {
            class Title: Title {};
            class Button_1: Button_1 {};
            class Button_2: Button_2 {};
            class Value: Value {};
        };
    };

With `-m` / `--merge`, it recursively traces the base class inheritance chain
up to the root base class and merges all ancestor inner classes (e.g. nested controls
in parent/grandparent classes), ensuring no inherited controls are left behind.

Usage:
    python btc_skeleton.py <file.hpp> [ChildClassName]
    python btc_skeleton.py -m <file.hpp> [ChildClassName]
    python btc_skeleton.py -m <ParentClassName> [ChildClassName]
    python btc_skeleton.py addons/gui/includes/ctrlList.hpp GVAR(ctrlListEdit)
    python btc_skeleton.py -m addons/gui/includes/ctrlListListNEditPresets.hpp GVAR(ctrlListListNEditPresets_child)
    python btc_skeleton.py --clip [ChildClassName]
    python btc_skeleton.py <file.hpp> -o addons/gui/includes/ctrlListEdit.hpp
"""

import argparse
import os
import re
import shutil
import subprocess
import sys
from collections import OrderedDict
from pathlib import Path
from typing import Dict, List, Optional, Set, Tuple


# ── ANSI Colors ────────────────────────────────────────────────────────────────
class Colors:
    RESET = "\033[0m"
    BOLD = "\033[1m"
    DIM = "\033[2m"
    CYAN = "\033[36m"
    GREEN = "\033[32m"
    YELLOW = "\033[33m"
    BLUE = "\033[34m"
    MAGENTA = "\033[35m"
    RED = "\033[31m"

    @classmethod
    def disable(cls):
        cls.RESET = ""
        cls.BOLD = ""
        cls.DIM = ""
        cls.CYAN = ""
        cls.GREEN = ""
        cls.YELLOW = ""
        cls.BLUE = ""
        cls.MAGENTA = ""
        cls.RED = ""


# ── AST Node ───────────────────────────────────────────────────────────────────
class ClassNode:
    def __init__(self, name: str, base: Optional[str] = None):
        self.name: str = name
        self.base: Optional[str] = base
        self.children: OrderedDict[str, "ClassNode"] = OrderedDict()

    def clone(self) -> "ClassNode":
        cloned = ClassNode(self.name, self.base)
        for k, v in self.children.items():
            cloned.children[k] = v.clone()
        return cloned

    def generate_child_skeleton(
        self, child_name: str, indent_size: int = 4
    ) -> str:
        """
        Generates the derived child class skeleton.
        Root: class ChildName: ParentName { class Controls: Controls { ... }; };
        """
        indent = " " * indent_size
        lines = [f"class {child_name}: {self.name}", "{"]

        for ch_name, ch_node in self.children.items():
            lines.extend(ch_node._render_inner_skeleton(ch_name, indent, level=1))

        lines.append("};")
        return "\n".join(lines)

    def _render_inner_skeleton(
        self, name: str, indent: str, level: int
    ) -> List[str]:
        pad = indent * level
        if not self.children:
            return [f"{pad}class {name}: {name} {{}};"]

        lines = [f"{pad}class {name}: {name}", f"{pad}{{"]
        for sub_name, sub_node in self.children.items():
            lines.extend(sub_node._render_inner_skeleton(sub_name, indent, level + 1))
        lines.append(f"{pad}}};")
        return lines

    def total_descendants(self) -> int:
        count = len(self.children)
        for ch in self.children.values():
            count += ch.total_descendants()
        return count


# ── Config Parser ─────────────────────────────────────────────────────────────
def remove_comments(text: str) -> str:
    """Strips single-line and multi-line comments while preserving strings."""
    pattern = r'(\"(?:[^\"]|\"\")*\")|(\/\/[^\n]*)|(\/\*[\s\S]*?\*\/)'

    def replace(m: re.Match) -> str:
        if m.group(1):
            return m.group(1)
        elif m.group(2):
            return ""
        else:
            return "\n" * m.group(3).count("\n")

    return re.sub(pattern, replace, text)


def parse_classes_from_text(text: str) -> OrderedDict[str, ClassNode]:
    """
    Parses Arma config text and returns all root-level ClassNodes
    with their nested children hierarchy.
    """
    clean = remove_comments(text)

    # Tokenizer matching string literals, macro calls/identifiers, and symbols
    token_pattern = re.compile(
        r'(\"(?:[^\"]|\"\")*\")|'
        r'([a-zA-Z_][a-zA-Z0-9_]*(?:\s*\([^)]*\))?)|'
        r'([{};:])'
    )

    tokens: List[str] = []
    for m in token_pattern.finditer(clean):
        val = m.group(1) or m.group(2) or m.group(3)
        tokens.append(val.strip())

    roots: OrderedDict[str, ClassNode] = OrderedDict()
    stack: List[Tuple[ClassNode, int]] = []
    brace_depth = 0
    i = 0
    n = len(tokens)

    while i < n:
        tok = tokens[i]
        if tok == "class":
            i += 1
            if i >= n:
                break
            cname = tokens[i]
            cbase: Optional[str] = None
            i += 1
            if i < n and tokens[i] == ":":
                i += 1
                if i < n:
                    cbase = tokens[i]
                    i += 1

            # Check what follows:
            # 1. Forward declaration: class Name;
            if i < n and tokens[i] == ";":
                node = ClassNode(cname, cbase)
                if stack:
                    stack[-1][0].children[cname] = node
                else:
                    roots[cname] = node
                i += 1
            # 2. Empty definition: class Name: Base {};
            elif i + 1 < n and tokens[i] == "{" and tokens[i + 1] == "}":
                node = ClassNode(cname, cbase)
                if stack:
                    stack[-1][0].children[cname] = node
                else:
                    roots[cname] = node
                i += 2
                if i < n and tokens[i] == ";":
                    i += 1
            # 3. Class body: class Name: Base { ... }
            elif i < n and tokens[i] == "{":
                brace_depth += 1
                node = ClassNode(cname, cbase)
                if stack:
                    stack[-1][0].children[cname] = node
                else:
                    roots[cname] = node
                stack.append((node, brace_depth))
                i += 1
        elif tok == "{":
            # Non-class block (such as an array assignment `columns[] = { ... };`)
            brace_depth += 1
            i += 1
        elif tok == "}":
            if stack and stack[-1][1] == brace_depth:
                stack.pop()
            brace_depth -= 1
            i += 1
            if i < n and tokens[i] == ";":
                i += 1
        else:
            i += 1

    return roots


def find_class_in_tree(
    nodes: OrderedDict[str, ClassNode], target_name: str
) -> Optional[ClassNode]:
    """Finds a class matching target_name anywhere in the tree."""
    target_clean = re.sub(r"\s+", "", target_name).lower()
    for name, node in nodes.items():
        if re.sub(r"\s+", "", name).lower() == target_clean:
            return node
        sub = find_class_in_tree(node.children, target_name)
        if sub:
            return sub
    return None


def get_primary_class(
    classes: OrderedDict[str, ClassNode], requested_name: Optional[str] = None
) -> Optional[ClassNode]:
    """Selects target class: matches requested_name or picks the primary class with body."""
    if requested_name:
        return find_class_in_tree(classes, requested_name)
    # Prefer classes with children/body
    for node in classes.values():
        if node.children:
            return node
    if classes:
        return list(classes.values())[0]
    return None


def merge_ordered_keys_ci(base_keys: List[str], derived_keys: List[str]) -> List[str]:
    """
    Merges base and derived key orders while matching case-insensitively.
    Derived keys retain their exact declaration order. Base keys not in derived
    are inserted while preserving their relative positions from base.
    The exact casing from derived keys is preferred.
    """
    derived_lower_to_key = {k.lower(): k for k in derived_keys}
    base_lower_to_key = {k.lower(): k for k in base_keys}

    result_lower: List[str] = []
    for k in derived_keys:
        lk = k.lower()
        if lk not in result_lower:
            result_lower.append(lk)

    base_lower_keys = [k.lower() for k in base_keys]

    for i, lk in enumerate(base_lower_keys):
        if lk not in result_lower:
            prev_lk = None
            for prev in reversed(base_lower_keys[:i]):
                if prev in result_lower:
                    prev_lk = prev
                    break
            if prev_lk:
                idx = result_lower.index(prev_lk) + 1
                result_lower.insert(idx, lk)
            else:
                next_lk = None
                for nxt in base_lower_keys[i + 1 :]:
                    if nxt in result_lower:
                        next_lk = nxt
                        break
                if next_lk:
                    idx = result_lower.index(next_lk)
                    result_lower.insert(idx, lk)
                else:
                    result_lower.append(lk)

    final_keys: List[str] = []
    for lk in result_lower:
        if lk in derived_lower_to_key:
            final_keys.append(derived_lower_to_key[lk])
        elif lk in base_lower_to_key:
            final_keys.append(base_lower_to_key[lk])
        else:
            final_keys.append(lk)
    return final_keys


# ── Inheritance Resolver ──────────────────────────────────────────────────────
class Resolver:
    """
    Indexes and resolves classes across config files and traces inheritance chains.
    Deeply merges ancestor classes and external control types into derived classes.
    """

    def __init__(self, search_dirs: Optional[List[Path]] = None):
        if search_dirs is None:
            search_dirs = [Path.cwd()]
        self.search_dirs = search_dirs
        self.parsed_cache: Dict[Path, OrderedDict[str, ClassNode]] = {}
        self.class_lookup: Dict[str, ClassNode] = {}
        self.file_index: Dict[str, List[Path]] = {}
        self._build_index()

    def _build_index(self):
        candidate_exts = {".hpp", ".cpp", ".ext"}
        pattern = re.compile(
            r"\bclass\s+([a-zA-Z_][a-zA-Z0-9_]*(?:\s*\([^)]*\))?)", re.IGNORECASE
        )
        for d in self.search_dirs:
            if not d.exists():
                continue
            for root, _, files in os.walk(d):
                if any(x in root for x in [".hemttout", ".git"]):
                    continue
                for f in files:
                    p = Path(root) / f
                    if p.suffix.lower() in candidate_exts:
                        try:
                            content = p.read_text(encoding="utf-8", errors="ignore")
                            for m in pattern.finditer(content):
                                cname_clean = re.sub(r"\s+", "", m.group(1)).lower()
                                if cname_clean not in self.file_index:
                                    self.file_index[cname_clean] = []
                                if p not in self.file_index[cname_clean]:
                                    self.file_index[cname_clean].append(p)
                        except Exception:
                            pass

    def get_classes_in_file(self, p: Path) -> OrderedDict[str, ClassNode]:
        if p not in self.parsed_cache:
            try:
                content = p.read_text(encoding="utf-8", errors="ignore")
                self.parsed_cache[p] = parse_classes_from_text(content)
            except Exception:
                self.parsed_cache[p] = OrderedDict()
        return self.parsed_cache[p]

    def register_class(self, node: ClassNode):
        """Registers a known ClassNode directly into the resolver lookup."""
        clean_name = re.sub(r"\s+", "", node.name).lower()
        self.class_lookup[clean_name] = node

    def get_matching_files(self, class_name: str) -> List[Path]:
        cname_clean = re.sub(r"\s+", "", class_name).lower()
        return self.file_index.get(cname_clean, [])

    def resolve_class(
        self, class_name: str, preferred_file: Optional[Path] = None
    ) -> Optional[ClassNode]:
        cname_clean = re.sub(r"\s+", "", class_name).lower()
        if cname_clean in self.class_lookup:
            return self.class_lookup[cname_clean]

        file_list = self.file_index.get(cname_clean, [])
        if preferred_file and preferred_file in file_list:
            nodes = self.get_classes_in_file(preferred_file)
            found = find_class_in_tree(nodes, class_name)
            if found:
                self.class_lookup[cname_clean] = found
                return found

        for p in file_list:
            nodes = self.get_classes_in_file(p)
            found = find_class_in_tree(nodes, class_name)
            if found:
                self.class_lookup[cname_clean] = found
                return found
        return None

    def get_inheritance_chain(self, node: ClassNode) -> List[str]:
        chain = [node.name]
        curr = node
        visited = {re.sub(r"\s+", "", node.name).lower()}
        while curr and curr.base and curr.base != curr.name:
            chain.append(curr.base)
            base_clean = re.sub(r"\s+", "", curr.base).lower()
            if base_clean in visited:
                break
            visited.add(base_clean)
            curr = self.resolve_class(curr.base)
        return chain

    def merge_with_ancestors(
        self, target: ClassNode, visited_bases: Optional[Set[str]] = None
    ) -> ClassNode:
        """
        Recursively resolves ancestors of target and merges their inner classes.
        Also resolves external bases of nested controls (e.g. List_1: GVAR(ctrlList)).
        """
        if visited_bases is None:
            visited_bases = set()

        merged = target.clone()
        cname_clean = re.sub(r"\s+", "", target.name).lower()
        if cname_clean in visited_bases:
            return merged
        visited_bases.add(cname_clean)

        # 1. Resolve target's own base class chain (e.g. ctrlListListNEditPresets -> ctrlListListNEdit)
        if target.base and target.base != target.name:
            base_node = self.resolve_class(target.base)
            if base_node:
                base_merged = self.merge_with_ancestors(base_node, set(visited_bases))
                merged = self._merge_nodes(base_merged, merged)

        # 2. Also check if any children have their own external base (e.g. List_2: GVAR(ctrlListNEdit))
        self._deep_merge_children(merged, visited_bases)

        return merged

    def _merge_nodes(self, base_node: ClassNode, derived_node: ClassNode) -> ClassNode:
        derived_base = derived_node.base
        # Preserve original base if derived is an inner-class self reference (: Controls or : List_1)
        if (
            derived_base
            and re.sub(r"\s+", "", derived_base).lower()
            == re.sub(r"\s+", "", derived_node.name).lower()
        ):
            effective_base = base_node.base or derived_base
        else:
            effective_base = derived_base or base_node.base

        result = ClassNode(derived_node.name, effective_base)
        base_by_lower = {k.lower(): (k, v) for k, v in base_node.children.items()}
        derived_by_lower = {k.lower(): (k, v) for k, v in derived_node.children.items()}

        ordered_keys = merge_ordered_keys_ci(
            list(base_node.children.keys()), list(derived_node.children.keys())
        )

        for key in ordered_keys:
            lk = key.lower()
            if lk in base_by_lower and lk in derived_by_lower:
                base_child = base_by_lower[lk][1]
                derived_child = derived_by_lower[lk][1]
                merged_child = self._merge_nodes(base_child, derived_child)
                merged_child.name = key
                result.children[key] = merged_child
            elif lk in derived_by_lower:
                cloned = derived_by_lower[lk][1].clone()
                cloned.name = key
                result.children[key] = cloned
            else:
                cloned = base_by_lower[lk][1].clone()
                cloned.name = key
                result.children[key] = cloned

        return result

    def _deep_merge_children(self, node: ClassNode, visited_bases: Set[str]):
        for ch_name, ch_node in list(node.children.items()):
            clean_base = re.sub(r"\s+", "", ch_node.base or "").lower()
            clean_name = re.sub(r"\s+", "", ch_name).lower()
            if (
                clean_base
                and clean_base != clean_name
                and clean_base != re.sub(r"\s+", "", node.name).lower()
            ):
                external_base = self.resolve_class(ch_node.base)
                if external_base:
                    ext_merged = self.merge_with_ancestors(external_base, set(visited_bases))
                    merged_child = self._merge_nodes(ext_merged, ch_node)
                    merged_child.name = ch_name
                    node.children[ch_name] = merged_child
            self._deep_merge_children(node.children[ch_name], visited_bases)


# ── Clipboard Helpers ─────────────────────────────────────────────────────────
def read_from_clipboard() -> Optional[str]:
    """Reads text from system clipboard using wl-paste, xclip, or xsel."""
    for tool, args in [
        ("wl-paste", ["--no-newline"]),
        ("xclip", ["-selection", "clipboard", "-o"]),
        ("xsel", ["--clipboard", "--output"]),
    ]:
        if shutil.which(tool):
            try:
                res = subprocess.run([tool] + args, capture_output=True, text=True, check=True)
                if res.stdout:
                    return res.stdout
            except Exception:
                continue
    return None


def copy_to_clipboard(text: str) -> bool:
    """Copies text to system clipboard using wl-copy, xclip, or xsel."""
    for tool, args in [
        ("wl-copy", []),
        ("xclip", ["-selection", "clipboard"]),
        ("xsel", ["--clipboard", "--input"]),
    ]:
        if shutil.which(tool):
            try:
                p = subprocess.Popen([tool] + args, stdin=subprocess.PIPE, close_fds=True)
                p.communicate(input=text.encode("utf-8"))
                return p.returncode == 0
            except Exception:
                continue
    return False


# ── Main CLI ──────────────────────────────────────────────────────────────────
def main():
    if "--no-color" in sys.argv or not sys.stdout.isatty():
        Colors.disable()

    prog_title = f"{Colors.BOLD}{Colors.CYAN}BTC Arma 3 Child Class Skeleton Generator{Colors.RESET}"
    desc = f"""{prog_title}

Generates the exact derived skeleton needed for Arma 3 config/GUI class inheritance.

{Colors.BOLD}{Colors.YELLOW}WHY THIS TOOL EXISTS:{Colors.RESET}
  Arma 3's config engine does NOT automatically inherit inner classes (like `Controls: Controls`)
  unless each control is declared in the derived class. Without these declarations, inherited
  controls disappear at runtime. This script parses parent configs and bakes the full boilerplate.

{Colors.BOLD}{Colors.YELLOW}KEY MODES:{Colors.RESET}
  • {Colors.GREEN}Default Mode:{Colors.RESET}
    Generates a skeleton containing only the inner classes directly declared in the target parent class.
  • {Colors.GREEN}Merge Mode (-m, --merge):{Colors.RESET}
    Recursively traces the parent's base class chain up to root engine classes (e.g.
    `ctrlControlsGroupNoScrollbars`) AND resolves nested controls with external bases (e.g.
    `List_1: GVAR(ctrlList)`), merging every inherited control down into the child skeleton.
"""

    epilog = f"""{Colors.BOLD}{Colors.YELLOW}COMMON WORKFLOWS & EXAMPLES:{Colors.RESET}

  {Colors.CYAN}1. Full recursive skeleton up to root base classes (RECOMMENDED):{Colors.RESET}
     python3 btc_skeleton.py -m addons/gui/includes/ctrlListListNEditPresets.hpp "GVAR(myChild)"

  {Colors.CYAN}2. Search repository and A3 configs by parent class name:{Colors.RESET}
     python3 btc_skeleton.py -m "GVAR(ctrlListListNEditPresets)" "GVAR(myChild)"

  {Colors.CYAN}3. Generate single-level skeleton (only controls in that specific file):{Colors.RESET}
     python3 btc_skeleton.py addons/gui/includes/ctrlList.hpp "GVAR(ctrlListEdit)"

  {Colors.CYAN}4. Extract a specific or nested class from a multi-class config file:{Colors.RESET}
     python3 btc_skeleton.py addons/lift/config.cpp ACE_SelfActions
     python3 btc_skeleton.py addons/lift/config.cpp ACE_SelfActions --same
     python3 btc_skeleton.py addons/lift/config.cpp Helicopter MyHelicopter

  {Colors.CYAN}5. Parse parent snippet directly from system clipboard:{Colors.RESET}
     python3 btc_skeleton.py --clip "GVAR(myChild)"
     python3 btc_skeleton.py -m --clip "GVAR(myChild)"

  {Colors.CYAN}6. Write output directly to a new file:{Colors.RESET}
     python3 btc_skeleton.py -m ctrlListListNEdit.hpp -o addons/gui/includes/myCustomCtrl.hpp

{Colors.BOLD}{Colors.YELLOW}IMPORTANT TIPS:{Colors.RESET}
  • {Colors.BOLD}Bash Macro Quoting:{Colors.RESET} Always wrap macros containing parentheses in quotes in bash:
    Use {Colors.GREEN}"GVAR(ctrlList)"{Colors.RESET} instead of {Colors.RED}GVAR(ctrlList){Colors.RESET} (bash will treat unquoted () as a subshell syntax error).
  • {Colors.BOLD}Automatic Clipboard:{Colors.RESET} The generated skeleton is automatically copied to your
    clipboard ({Colors.MAGENTA}wl-copy{Colors.RESET} / {Colors.MAGENTA}xclip{Colors.RESET}). Just press {Colors.BOLD}Ctrl+V{Colors.RESET} in your editor immediately!
  • {Colors.BOLD}Child Class Name:{Colors.RESET} If omitted, defaults to {Colors.GREEN}GVAR(<parent>Edit){Colors.RESET} or {Colors.GREEN}<parent>_Child{Colors.RESET}.
"""

    parser = argparse.ArgumentParser(
        prog="btc_skeleton.py",
        description=desc,
        epilog=epilog,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    parser.add_argument(
        "pos_args",
        nargs="*",
        metavar="ARG",
        help="Positional arguments: [file.hpp/.cpp] [ParentClassName] [ChildClassName]",
    )
    parser.add_argument(
        "-m",
        "--merge",
        "--merge-parents",
        action="store_true",
        help="Recursively resolve base class inheritance chain and merge all inherited inner classes",
    )
    parser.add_argument(
        "-s",
        "--search-dir",
        action="append",
        metavar="DIR",
        help="Additional search directory for config files (can be specified multiple times)",
    )
    parser.add_argument("-f", "--file", metavar="FILE", help="Explicit path to parent config file")
    parser.add_argument("-p", "--parent", metavar="NAME", help="Explicit parent class name")
    parser.add_argument("-c", "--clip", action="store_true", help="Read input parent snippet from clipboard")
    parser.add_argument(
        "--same",
        "--self",
        action="store_true",
        help="Use parent class name as child class name (e.g. class Name: Name)",
    )
    parser.add_argument(
        "-y",
        "--copy",
        action="store_true",
        default=True,
        help="Copy result to clipboard (default: enabled)",
    )
    parser.add_argument("--no-copy", action="store_true", help="Do not copy result to clipboard")
    parser.add_argument("-o", "--out", metavar="FILE", help="Write generated skeleton directly to file")
    parser.add_argument("-i", "--indent", type=int, default=4, metavar="N", help="Indentation spaces (default: 4)")
    parser.add_argument("--no-color", action="store_true", help="Disable colored terminal output")

    args = parser.parse_args()

    if args.no_color:
        Colors.disable()

    pos1 = args.pos_args[0] if len(args.pos_args) > 0 else None
    pos2 = args.pos_args[1] if len(args.pos_args) > 1 else None
    pos3 = args.pos_args[2] if len(args.pos_args) > 2 else None

    parent_node: Optional[ClassNode] = None
    child_name: Optional[str] = None
    source_desc = ""

    # Setup Resolver search dirs
    search_dirs = [Path.cwd()]
    if args.search_dir:
        for s in args.search_dir:
            search_dirs.append(Path(s))
    a3_path = Path("/media/linux/C/Programming/Arma/a3")
    if a3_path.exists():
        search_dirs.extend([p for p in a3_path.glob("ui_f*") if p.is_dir()])

    resolver = Resolver(search_dirs=search_dirs)

    # 1. Source: Clipboard
    if args.clip:
        clip_text = read_from_clipboard()
        if not clip_text:
            print(f"{Colors.RED}Error: Clipboard is empty or could not be read.{Colors.RESET}")
            sys.exit(1)
        classes = parse_classes_from_text(clip_text)
        if not classes:
            print(f"{Colors.RED}Error: No classes found in clipboard snippet.{Colors.RESET}")
            sys.exit(1)
        target_name = args.parent or pos1
        parent_node = get_primary_class(classes, target_name)
        child_name = pos2 if args.parent else (pos2 if pos1 and pos1 in classes else pos1)
        source_desc = "clipboard"

    # 2. Source: File Path
    elif args.file or (pos1 and Path(pos1).exists() and Path(pos1).is_file()):
        file_path = Path(args.file if args.file else pos1)
        content = file_path.read_text(encoding="utf-8", errors="ignore")
        classes = parse_classes_from_text(content)
        if not classes:
            print(f"{Colors.RED}Error: No classes found in {file_path}.{Colors.RESET}")
            sys.exit(1)

        source_desc = str(file_path)

        if args.parent:
            parent_node = find_class_in_tree(classes, args.parent)
            child_name = pos2 if args.file else pos2
        elif args.file:
            if pos1 and find_class_in_tree(classes, pos1):
                parent_node = find_class_in_tree(classes, pos1)
                child_name = pos2
            else:
                parent_node = get_primary_class(classes)
                child_name = pos1
        elif pos2 and find_class_in_tree(classes, pos2):
            # pos1 is a file, pos2 is a class defined inside that file!
            parent_node = find_class_in_tree(classes, pos2)
            child_name = pos3
        else:
            # pos1 is a file, pos2 (if given) is not in the file, so it's the child name
            parent_node = get_primary_class(classes)
            child_name = pos2

    # 3. Source: Stdin (piped)
    elif pos1 == "-" or (not pos1 and not sys.stdin.isatty()):
        stdin_text = sys.stdin.read()
        classes = parse_classes_from_text(stdin_text)
        if not classes:
            print(f"{Colors.RED}Error: No classes found in stdin.{Colors.RESET}")
            sys.exit(1)
        target_name = args.parent or pos2
        parent_node = get_primary_class(classes, target_name)
        child_name = pos2 if not target_name else None
        source_desc = "stdin"

    # 4. Source: Search by class name in repository
    elif pos1 or args.parent:
        class_query = args.parent or pos1
        child_name = pos2 if not args.parent else pos1
        print(f"{Colors.DIM}Searching for class '{class_query}' in indexed files...{Colors.RESET}")

        matches = resolver.get_matching_files(class_query)
        parent_node = resolver.resolve_class(class_query)
        if parent_node:
            found_path = matches[0] if matches else None
            source_desc = str(found_path) if found_path else "indexed repository"
            if len(matches) > 1:
                print(f"{Colors.YELLOW}Note: Class '{class_query}' found in multiple files:{Colors.RESET}")
                for p in matches:
                    mark = f" {Colors.GREEN}(selected){Colors.RESET}" if p == found_path else ""
                    print(f"  • {p}{mark}")
                print(f"{Colors.DIM}Tip: Specify the file to target a specific one, e.g.:{Colors.RESET}")
                print(f"  python3 btc_skeleton.py <file> {class_query}\n")
        else:
            print(f"{Colors.RED}Error: Could not find class '{class_query}' in local files.{Colors.RESET}")
            sys.exit(1)
    else:
        parser.print_help()
        sys.exit(1)

    if not parent_node:
        print(f"{Colors.RED}Error: Target parent class could not be resolved.{Colors.RESET}")
        sys.exit(1)

    # Resolve inheritance chain and merge if requested
    chain_info: Optional[List[str]] = None
    if args.merge:
        resolver.register_class(parent_node)
        chain_info = resolver.get_inheritance_chain(parent_node)
        parent_node = resolver.merge_with_ancestors(parent_node)

    # Resolve child class name
    if args.same:
        child_name = parent_node.name
    elif not child_name:
        base_clean = parent_node.name
        if base_clean.startswith("GVAR(") and base_clean.endswith(")"):
            inner = base_clean[5:-1]
            child_name = f"GVAR({inner}_Child)"
        else:
            child_name = f"{base_clean}_Child"

    # Generate the skeleton
    skeleton = parent_node.generate_child_skeleton(child_name=child_name, indent_size=args.indent)

    # Print summary
    desc_count = parent_node.total_descendants()
    print(f"\n{Colors.BOLD}{Colors.CYAN}=== BTC CHILD SKELETON GENERATOR ==={Colors.RESET}")
    print(f"{Colors.DIM}Source:{Colors.RESET} {Colors.MAGENTA}{source_desc}{Colors.RESET}")
    if chain_info and len(chain_info) > 1:
        print(
            f"{Colors.DIM}Parent:{Colors.RESET} {Colors.YELLOW}{parent_node.name}{Colors.RESET} (merged {desc_count} inner classes)"
        )
        print(f"{Colors.DIM}Chain: {Colors.RESET} {Colors.BLUE}{' -> '.join(chain_info)}{Colors.RESET}")
    else:
        print(
            f"{Colors.DIM}Parent:{Colors.RESET} {Colors.YELLOW}{parent_node.name}{Colors.RESET} ({desc_count} inner classes)"
        )
    print(f"{Colors.DIM}Child: {Colors.RESET} {Colors.GREEN}{child_name}{Colors.RESET}")
    print(f"{Colors.BOLD}{Colors.CYAN}===================================={Colors.RESET}\n")

    print(skeleton)
    print()

    # Optional Write to File
    if args.out:
        out_path = Path(args.out)
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(skeleton + "\n", encoding="utf-8")
        print(f"{Colors.GREEN}✓ Wrote skeleton to {out_path}{Colors.RESET}")

    # Copy to Clipboard
    should_copy = args.copy and not args.no_copy
    if should_copy:
        if copy_to_clipboard(skeleton):
            print(f"{Colors.CYAN}✓ Copied skeleton to clipboard!{Colors.RESET}\n")


if __name__ == "__main__":
    main()
