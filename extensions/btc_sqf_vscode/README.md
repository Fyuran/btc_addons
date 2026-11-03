# BTC SQF & CBA IntelliSense

Advanced documentation hovers, parameter inspection, signature help, variable type inference, real-time type diagnostics, and Go-to-Definition for **Arma 3 SQF** and **CBA/HEMTT** macros.

---

## Features

### 1. Smart IntelliSense & Variable Type Inference
- **Local Variable Inspection:** Hover over any local variable (e.g. `_arr`, `_main_grp`, `_target`) to view its inferred typename (`Array`, `Control`, `Object`, `Number`, `String`, etc.), parameter origin, and declaration line.
- **Contextual Operand Validation:** When hovering over binary or unary commands (e.g. `_arr pushBackUnique _elem`), the extension inspects the surrounding operands in your open file and validates their types against the command's expected signatures.
- **Real-Time Type Diagnostics:** Warns you in the Problems panel if an incompatible type is passed to a command (e.g. passing a `String` or `Number` into a command expecting an `Array`).

### 2. Native Arma 3 Commands Database with Locality & Versions
- Over **3,600+** native engine commands and BIS functions documented offline.
- **Typed Signatures & Typenames:** Clearly displays operand types and return types, e.g. `(Array) pushBackUnique (Any) -> Number`.
- **Multiplayer Locality Badges:** Displays official Biki locality indicators right at the top:
  - `[AG]` **Global Argument** / `[AL]` **Local Argument**
  - `[EG]` **Global Effect** / `[EL]` **Local Effect**
  - `⚙️ Local (In-Memory)`
- **Version Introduced:** Displays the exact game engine version (e.g. `⚡ Arma 3 v1.56`, `Arma 3 v1.68`, `OFP v1.00`).
- **Parameter Breakdown & Examples:** Full typed parameter descriptions and official syntax documentation with BIKI links.

### 3. CBA Macro & Custom Function Hover
Hover over any CBA macro like `FUNC(name)`, `EFUNC(component, name)`, `QFUNC(name)`, or raw function names:
- **Full Name**: Automatically resolved using `PREFIX` and `COMPONENT` from `script_component.hpp`.
- **Parameter Breakdown**: Parameter names, types, optional status, default values, and docblock descriptions.
- **Return Type & Description**: Extracted from CBA docblocks.
- **Clickable Source File Link**: Directly jumps to the definition file.

### 4. Smart `call` Hover
Hover over the `call` keyword (e.g. `[args] call FUNC(myFunc)`) to see the required parameters and signature of the function being invoked.

### 5. Go-to-Definition (`F12` / `Ctrl+Click`)
Press `F12` or `Ctrl+Click` on any `FUNC(...)` or `EFUNC(...)` macro to jump directly to the target `.sqf` file in the workspace.

### 6. Signature Help
Provides active parameter highlighting when calling functions.

---

## Configuration

| Setting | Type | Default | Description |
|---|---|---|---|
| `btcSqf.enableNativeHovers` | `boolean` | `true` | Enable hover popups for native Arma 3 commands. |
| `btcSqf.enableVariableHover` | `boolean` | `true` | Show inferred type and declaration source when hovering over local variables. |
| `btcSqf.enableTypeChecking` | `boolean` | `true` | Real-time SQF type checking and operand validation diagnostics. |
| `btcSqf.enableCbaHovers` | `boolean` | `true` | Show documentation and parameter hover popups for CBA functions and macros (`FUNC`, `EFUNC`). |
| `btcSqf.enableCallHover` | `boolean` | `true` | Show target function parameters when hovering over the `call` keyword. |
| `btcSqf.defaultPrefix` | `string` | `"btc_toolchain"` | Addon prefix fallback if `script_mod.hpp` is not found. |

---

## Building & Installing

### Compile
```bash
npm run compile
```

### Package into `.vsix`
```bash
npx vsce package --no-dependencies
```

Install directly into VS Code / VSCodium:
```bash
codium --install-extension btc-sqf-vscode-1.1.0.vsix --force
```
