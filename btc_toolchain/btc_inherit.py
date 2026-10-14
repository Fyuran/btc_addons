#!/usr/bin/env python3
"""
BTC Arma 3 Config Inheritance Hierarchy Builder
Extracts and builds the complete C++ inheritance hierarchy for Arma 3 config classes,
including all nested children and controls, generating the exact forward-declaration
scaffolding needed for your addon config.cpp.

Usage:
    python btc_inherit.py <config.cpp> <target1> [target2 ...]
    python btc_inherit.py <target1> [target2 ...]
    python btc_inherit.py 15200
    python btc_inherit.py Combo Checkbox Edit
    python btc_inherit.py /media/linux/C/Programming/Arma/a3/3den/config.cpp Combo Checkbox Edit
    python btc_inherit.py 15200 --subclass MySpeedMode --copy
"""

import argparse
import bisect
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


# ── Config AST / Representation ───────────────────────────────────────────────
class ConfigNode:
    def __init__(self, name: str, base: Optional[str], start_line: int, scope: List[str]):
        self.name: str = name
        self.base: Optional[str] = base
        self.start_line: int = start_line
        self.end_line: int = start_line
        self.scope: List[str] = list(scope)
        self.has_body: bool = False
        self.classes: OrderedDict[str, "ConfigNode"] = OrderedDict()

    @property
    def full_path(self) -> str:
        parts = self.scope + [self.name]
        return " >> ".join(parts) if parts else self.name


# ── Parser ────────────────────────────────────────────────────────────────────
def remove_comments(text: str) -> str:
    """Strip single-line and multi-line comments while strictly preserving newline offsets."""
    pattern = r'(\"(?:[^\"]|\"\")*\")|(\/\/[^\n]*)|(\/\*[\s\S]*?\*\/)'

    def replace(m: re.Match) -> str:
        if m.group(1):  # string literal
            return m.group(1)
        elif m.group(2):  # // comment
            return ""
        else:  # /* ... */ comment
            return "\n" * m.group(3).count("\n")

    return re.sub(pattern, replace, text)


def parse_config_file(filepath: Path) -> Tuple[OrderedDict[str, ConfigNode], List[ConfigNode]]:
    """
    Parses an Arma 3 config.cpp file and returns:
      - root_classes: OrderedDict[class_name -> ConfigNode]
      - all_classes: List[ConfigNode] in appearance order
    """
    text = filepath.read_text(encoding="utf-8", errors="ignore")
    clean = remove_comments(text)

    # Line offset lookup for fast pos -> line conversion
    line_offsets = []
    curr = 0
    for l in clean.splitlines(True):
        line_offsets.append(curr)
        curr += len(l)

    def pos_to_line(pos: int) -> int:
        return bisect.bisect_right(line_offsets, pos)

    token_pattern = re.compile(r'(\"(?:[^\"]|\"\")*\")|([a-zA-Z0-9_]+)|([{};:])')
    tokens: List[Tuple[str, int]] = []
    for m in token_pattern.finditer(clean):
        tokens.append((m.group(), pos_to_line(m.start())))

    root_classes: OrderedDict[str, ConfigNode] = OrderedDict()
    all_classes: List[ConfigNode] = []
    stack: List[Tuple[ConfigNode, int]] = []
    brace_depth = 0

    i = 0
    n = len(tokens)
    while i < n:
        tok, line = tokens[i]
        if tok == "class":
            i += 1
            if i >= n:
                break
            cname, cline = tokens[i]
            cbase: Optional[str] = None
            i += 1
            if i < n and tokens[i][0] == ":":
                i += 1
                if i < n:
                    cbase = tokens[i][0]
                    i += 1

            if i < n and tokens[i][0] == ";":
                # Forward declaration without body
                scope = [c.name for c, _ in stack]
                node = ConfigNode(cname, cbase, cline, scope)
                all_classes.append(node)
                if stack:
                    stack[-1][0].classes[cname] = node
                else:
                    root_classes[cname] = node
                i += 1
            elif i < n and tokens[i][0] == "{":
                # Class definition with body
                brace_depth += 1
                scope = [c.name for c, _ in stack]
                node = ConfigNode(cname, cbase, cline, scope)
                node.has_body = True
                all_classes.append(node)
                if stack:
                    stack[-1][0].classes[cname] = node
                else:
                    root_classes[cname] = node
                stack.append((node, brace_depth))
                i += 1
        elif tok == "{":
            brace_depth += 1
            i += 1
        elif tok == "}":
            if stack and stack[-1][1] == brace_depth:
                popped, _ = stack.pop()
                popped.end_line = line
            brace_depth -= 1
            i += 1
        else:
            i += 1

    return root_classes, all_classes


# ── Target Finder ─────────────────────────────────────────────────────────────
def find_target_by_line(all_classes: List[ConfigNode], line_num: int) -> Optional[ConfigNode]:
    """Finds the class corresponding to a given line number."""
    # 1. Exact start line match
    for c in all_classes:
        if c.start_line == line_num:
            return c

    # 2. Inside body range: pick the innermost class enclosing line_num
    enclosing = [c for c in all_classes if c.start_line <= line_num <= c.end_line]
    if enclosing:
        enclosing.sort(key=lambda c: (len(c.scope), -(c.end_line - c.start_line)), reverse=True)
        return enclosing[0]

    # 3. Closest preceding class
    preceding = [c for c in all_classes if c.start_line <= line_num]
    if preceding:
        preceding.sort(key=lambda c: c.start_line, reverse=True)
        return preceding[0]

    return None


def find_target_by_name(
    all_classes: List[ConfigNode], name: str, scope_hint: Optional[List[str]] = None
) -> Optional[ConfigNode]:
    """Finds class matching name (can be simple name or scoped 'A >> B')."""
    if ">>" in name or "/" in name:
        target_parts = [p.strip() for p in re.split(r'>>|/', name)]
        for c in all_classes:
            if c.scope + [c.name] == target_parts:
                return c

    # Simple name match
    matches = [c for c in all_classes if c.name.lower() == name.lower()]
    if matches:
        if scope_hint:
            scoped_matches = [
                c
                for c in matches
                if c.scope == scope_hint
                or (len(c.scope) >= len(scope_hint) and c.scope[-len(scope_hint):] == scope_hint)
            ]
            if scoped_matches:
                return scoped_matches[0]

        # Prioritize primary config scopes like Attributes, Cfg3DEN, CfgVehicles
        def score(c: ConfigNode) -> int:
            s = 0
            if "Attributes" in c.scope:
                s += 20
            if "Cfg3DEN" in c.scope:
                s += 10
            if "CfgVehicles" in c.scope:
                s += 8
            if c.base:
                s += 4
            if c.has_body:
                s += 2
            return s

        matches.sort(key=score, reverse=True)
        return matches[0]

    return None


# ── Base Class Resolver ───────────────────────────────────────────────────────
def get_node_by_scope_path(
    path: List[str], root_classes: OrderedDict[str, ConfigNode]
) -> Optional[ConfigNode]:
    """Looks up a specific node along a scope hierarchy path."""
    curr_dict = root_classes
    node = None
    for s in path:
        if s in curr_dict:
            node = curr_dict[s]
            curr_dict = node.classes
        else:
            return None
    return node


def resolve_base_class(
    base_name: str, current_scope: List[str], root_classes: OrderedDict[str, ConfigNode]
) -> Optional[ConfigNode]:
    """
    Resolves base_name according to Arma's scoping rules:
      1. Check innermost scope (current enclosing class)
      2. Check parent scopes up to root
      3. Check root scope
    """
    for depth in range(len(current_scope), -1, -1):
        test_scope = current_scope[:depth]
        node = get_node_by_scope_path(test_scope, root_classes) if test_scope else None
        check_classes = node.classes if node else root_classes
        if base_name in check_classes:
            return check_classes[base_name]

    return None


def build_inheritance_chain(
    target: ConfigNode, root_classes: OrderedDict[str, ConfigNode]
) -> List[ConfigNode]:
    """Builds inheritance list starting from target up to the root base class."""
    chain = [target]
    curr = target
    seen: Set[str] = {target.name}

    while curr and curr.base:
        base_node = resolve_base_class(curr.base, curr.scope, root_classes)
        if base_node:
            if base_node.name in seen:
                break
            seen.add(base_node.name)
            chain.append(base_node)
            curr = base_node
        else:
            external_node = ConfigNode(curr.base, None, 0, [])
            chain.append(external_node)
            break

    return chain


# ── Recursive Node Formatter ──────────────────────────────────────────────────
def format_node_def(
    name: str,
    base: Optional[str],
    children: OrderedDict[str, ConfigNode],
    is_scope_root: bool = False,
    include_inner: bool = True,
    indent_level: int = 0,
    indent_str: str = "    ",
) -> List[str]:
    """
    Recursively formats a class and all its inner children using Arma C++ syntax.
    - If a class has children, emits: class Name: Base { ... };
    - If a class has no children and has a base, emits: class Name: Base {};
    - If a class has no children and is a scope root, emits: class Name;
    """
    pad = indent_str * indent_level
    base_part = f": {base}" if base else ""

    if include_inner and children:
        lines = [f"{pad}class {name}{base_part} {{"]
        for child_name, child_node in children.items():
            lines.extend(
                format_node_def(
                    name=child_name,
                    base=child_node.base,
                    children=child_node.classes,
                    is_scope_root=False,
                    include_inner=include_inner,
                    indent_level=indent_level + 1,
                    indent_str=indent_str,
                )
            )
        lines.append(f"{pad}}};")
        return lines
    else:
        if is_scope_root:
            return [f"{pad}class {name};"]
        elif base:
            return [f"{pad}class {name}{base_part} {{}};"]
        else:
            return [f"{pad}class {name};"]


# ── Code Generator ────────────────────────────────────────────────────────────
def generate_scaffolding(
    targets: List[ConfigNode],
    root_classes: OrderedDict[str, ConfigNode],
    subclass_name: Optional[str] = None,
    include_inner: bool = True,
    full_root: bool = False,
    indent_size: int = 4,
) -> str:
    """
    Generates C++ config.cpp forward declaration scaffolding for one or multiple targets.
    Merged into a single clean hierarchy with correctly inherited children.
    """
    indent_str = " " * indent_size
    lines: List[str] = []

    # 1. Collect all chains for all targets
    target_scope = targets[0].scope
    nodes_in_scope: OrderedDict[str, ConfigNode] = OrderedDict()
    external_root_nodes: OrderedDict[str, ConfigNode] = OrderedDict()

    for target in targets:
        chain = build_inheritance_chain(target, root_classes)
        # Process from root base to derived
        for c in reversed(chain):
            if c.scope == target_scope:
                nodes_in_scope[c.name] = c
            elif not c.scope and c.name:
                external_root_nodes[c.name] = c

    # 2. Recursively collect external root classes referenced by inner classes
    referenced_root_names: Set[str] = set()

    def scan_inner_references(children: OrderedDict[str, ConfigNode]):
        for ch_node in children.values():
            if ch_node.base:
                # If base is defined at root, record it
                if ch_node.base in root_classes:
                    referenced_root_names.add(ch_node.base)
                elif ch_node.base not in children and ch_node.base not in nodes_in_scope:
                    # External reference
                    referenced_root_names.add(ch_node.base)
            scan_inner_references(ch_node.classes)

    if include_inner:
        for node in nodes_in_scope.values():
            scan_inner_references(node.classes)

    # 3. Output root-level base classes
    root_lines: List[str] = []
    emitted_roots: Set[str] = set()

    # If full_root requested, emit external chain
    if full_root:
        for r in external_root_nodes.values():
            if r.name and r.name not in emitted_roots:
                if r.base:
                    root_lines.append(f"class {r.name}: {r.base};")
                else:
                    root_lines.append(f"class {r.name};")
                emitted_roots.add(r.name)

    # Emit root controls referenced by inner classes
    for r_name in sorted(referenced_root_names):
        if r_name and r_name not in emitted_roots:
            root_lines.append(f"class {r_name};")
            emitted_roots.add(r_name)

    if root_lines:
        lines.append("// Root-level controls and base classes")
        lines.extend(root_lines)
        lines.append("")

    # 4. Output enclosing scopes
    if target_scope:
        lines.append(f"// Enclosing scope: {' >> '.join(target_scope)}")
        depth = 0
        current_path: List[str] = []

        for s in target_scope:
            current_path.append(s)
            node = get_node_by_scope_path(current_path, root_classes)
            parent_node = (
                get_node_by_scope_path(current_path[:-1], root_classes)
                if len(current_path) > 1
                else None
            )

            # If node has a base defined in parent scope (e.g. Module_F: Logic in CfgVehicles), declare it
            if node and node.base:
                parent_classes = parent_node.classes if parent_node else root_classes
                if node.base in parent_classes and node.base != s:
                    lines.append(f"{indent_str * depth}class {node.base};")
                lines.append(f"{indent_str * depth}class {s}: {node.base} {{")
            else:
                lines.append(f"{indent_str * depth}class {s} {{")
            depth += 1

        # Emit nodes inside target_scope
        scope_nodes = list(nodes_in_scope.values())
        for idx, node in enumerate(scope_nodes):
            # Check if this node is the root base of this scope
            # (i.e. first in scope, no base inside this scope, and not one of the user's explicit targets)
            is_root = (
                idx == 0
                and not node.classes
                and (not node.base or node.base not in nodes_in_scope)
                and not full_root
            )

            node_base = node.base
            if is_root:
                node_base = None

            lines.extend(
                format_node_def(
                    name=node.name,
                    base=node_base,
                    children=node.classes,
                    is_scope_root=is_root,
                    include_inner=include_inner,
                    indent_level=depth,
                    indent_str=indent_str,
                )
            )

        # Optional custom subclass template
        if subclass_name:
            main_target = targets[0]
            lines.append("")
            lines.append(f"{indent_str * depth}// Custom subclass")
            lines.append(f"{indent_str * depth}class {subclass_name}: {main_target.name} {{")
            if include_inner and main_target.classes:
                for in_name, in_node in main_target.classes.items():
                    in_base = f": {in_node.base}" if in_node.base else ""
                    lines.append(f"{indent_str * (depth + 1)}class {in_name}{in_base} {{")
                    lines.append(f"{indent_str * (depth + 2)}// Custom controls and overrides")
                    lines.append(f"{indent_str * (depth + 1)}}};")
            else:
                lines.append(f"{indent_str * (depth + 1)}// Custom properties here")
            lines.append(f"{indent_str * depth}}};")

        # Close enclosing scope braces
        for d in reversed(range(depth)):
            lines.append(f"{indent_str * d}}};")

    return "\n".join(lines)


# ── Tree Visualization ────────────────────────────────────────────────────────
def print_hierarchy_tree(chain: List[ConfigNode], include_inner: bool = True):
    """Prints a clear, formatted tree of the inheritance hierarchy."""
    print(f"\n{Colors.BOLD}{Colors.CYAN}=== INHERITANCE HIERARCHY ==={Colors.RESET}")
    for idx, node in enumerate(chain):
        indent = "    " * idx
        connector = "└── : " if idx > 0 else ""
        scope_str = (
            f" in {Colors.MAGENTA}{' >> '.join(node.scope)}{Colors.RESET}"
            if node.scope
            else f" in {Colors.DIM}<root>{Colors.RESET}"
        )
        line_str = (
            f" {Colors.DIM}(line {node.start_line}){Colors.RESET}"
            if node.start_line
            else f" {Colors.YELLOW}(external){Colors.RESET}"
        )
        name_str = (
            f"{Colors.BOLD}{Colors.GREEN}{node.name}{Colors.RESET}"
            if idx == 0
            else f"{Colors.YELLOW}{node.name}{Colors.RESET}"
        )
        base_str = f" {Colors.DIM}: {node.base}{Colors.RESET}" if (node.base and idx == 0) else ""

        print(f"{indent}{connector}{name_str}{base_str}{line_str}{scope_str}")

        # Show inner classes if present
        if include_inner and node.classes:
            inner_indent = indent + "      "
            for in_name, in_node in node.classes.items():
                in_base = f" : {in_node.base}" if in_node.base else ""
                print(f"{inner_indent}{Colors.BLUE}+ class {in_name}{in_base}{Colors.RESET}")
                for sub_name, sub_node in in_node.classes.items():
                    sub_base = f" : {sub_node.base}" if sub_node.base else ""
                    print(f"{inner_indent}    {Colors.DIM}- class {sub_name}{sub_base}{Colors.RESET}")

    print(f"{Colors.BOLD}{Colors.CYAN}============================={Colors.RESET}\n")


# ── Clipboard Helper ──────────────────────────────────────────────────────────
def copy_to_clipboard(text: str) -> bool:
    """Attempts to copy text to system clipboard using available tools."""
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
    parser = argparse.ArgumentParser(
        description="Arma 3 Config Inheritance Hierarchy Builder",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python btc_inherit.py 15200
  python btc_inherit.py Combo Checkbox Edit
  python btc_inherit.py /media/linux/C/Programming/Arma/a3/3den/config.cpp Combo Checkbox Edit
  python btc_inherit.py 15200 --subclass MyCustomSpeedMode --copy
  python btc_inherit.py 15200 --no-inner
        """,
    )

    parser.add_argument("args", nargs="*", help="[config.cpp] <target1> [target2 ...]")
    parser.add_argument("-f", "--file", help="Path to config.cpp file")
    parser.add_argument("-s", "--scope", help="Optional scope filter (e.g. 'Cfg3DEN >> Attributes')")
    parser.add_argument("--no-inner", action="store_true", help="Do not include inner child classes / controls")
    parser.add_argument("-r", "--full-root", action="store_true", help="Resolve external root base classes completely")
    parser.add_argument("-u", "--subclass", help="Name of your custom subclass to generate in skeleton")
    parser.add_argument("-y", "--copy", action="store_true", help="Copy generated scaffolding to clipboard")
    parser.add_argument("--no-color", action="store_true", help="Disable colored output")

    parsed = parser.parse_args()

    if parsed.no_color or not sys.stdout.isatty():
        Colors.disable()

    config_file: Optional[Path] = None
    target_inputs: List[str] = []

    # Parse positional arguments
    args_list = list(parsed.args)
    if parsed.file:
        config_file = Path(parsed.file)

    if args_list:
        first_arg = Path(args_list[0])
        if first_arg.exists() and first_arg.is_file():
            config_file = first_arg
            target_inputs = args_list[1:]
        else:
            target_inputs = args_list

    # Default file candidates if not specified
    if not config_file:
        default_candidates = [
            Path("/media/linux/C/Programming/Arma/a3/3den/config.cpp"),
            Path("./config.cpp"),
            Path("./addons/enemy_waves/config.cpp"),
        ]
        for cand in default_candidates:
            if cand.exists():
                config_file = cand
                break

    if not config_file or not config_file.exists():
        print(f"{Colors.RED}Error: Config file not found. Specify via: python btc_inherit.py <path/to/config.cpp> <targets...>{Colors.RESET}")
        sys.exit(1)

    if not target_inputs:
        print(f"{Colors.RED}Error: Must provide at least one line number or class name.{Colors.RESET}")
        sys.exit(1)

    print(f"{Colors.DIM}Parsing {config_file}...{Colors.RESET}")
    root_classes, all_classes = parse_config_file(config_file)
    print(f"{Colors.DIM}Parsed {len(all_classes)} class entries.{Colors.RESET}")

    scope_hint = [p.strip() for p in re.split(r'>>|/', parsed.scope)] if parsed.scope else None

    # Resolve all target nodes
    target_nodes: List[ConfigNode] = []
    for item in target_inputs:
        node: Optional[ConfigNode] = None
        current_hint = scope_hint or (target_nodes[0].scope if target_nodes else None)
        if item.isdigit():
            node = find_target_by_line(all_classes, int(item))
            if not node:
                print(f"{Colors.RED}Error: No class found at or near line {item}.{Colors.RESET}")
                sys.exit(1)
        else:
            node = find_target_by_name(all_classes, item, scope_hint=current_hint)
            if not node:
                print(f"{Colors.RED}Error: Class '{item}' not found in {config_file}.{Colors.RESET}")
                sys.exit(1)
        target_nodes.append(node)

    include_inner = not parsed.no_inner

    # Print Visual Hierarchy Tree for targets
    for t in target_nodes:
        chain = build_inheritance_chain(t, root_classes)
        print_hierarchy_tree(chain, include_inner=include_inner)

    # Generate Scaffolding Code
    scaffold = generate_scaffolding(
        targets=target_nodes,
        root_classes=root_classes,
        subclass_name=parsed.subclass,
        include_inner=include_inner,
        full_root=parsed.full_root,
    )

    print(f"{Colors.BOLD}{Colors.GREEN}=== GENERATED CONFIG.CPP SKELETON ==={Colors.RESET}")
    print(scaffold)
    print(f"{Colors.BOLD}{Colors.GREEN}====================================={Colors.RESET}\n")

    if parsed.copy:
        if copy_to_clipboard(scaffold):
            print(f"{Colors.CYAN}✓ Copied scaffolding to clipboard!{Colors.RESET}")
        else:
            print(f"{Colors.YELLOW}Warning: Could not copy to clipboard (wl-copy/xclip not available).{Colors.RESET}")


if __name__ == "__main__":
    main()
