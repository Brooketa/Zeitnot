# Swift Code Style Rules for Claude

> This ruleset is derived from the FIVE iOS Swift Code Style Guide. When generating, reviewing, or modifying Swift code, Claude must follow all rules below without exception.

---

## Naming

- Use `UpperCamelCase` for types and protocols; `lowerCamelCase` for variables, constants, and functions.
- Prioritize clarity over brevity — use the minimum number of words that **clearly** describe the entity.
- Name variables and parameters by their **role**, not their type.
- Name functions and methods according to their **side-effects**.
- Factory methods must begin with `make`.
- Avoid obscure terms, abbreviations, and redundant words.
- Place parameters with default values toward the end of the parameter list.
- Always label tuple members and name closure parameters.
- Protocol naming:
  - Default: suffix with `Protocol` (e.g., `NetworkingProtocol`)
  - Delegate protocols: suffix with `Delegate` (e.g., `ImageDownloaderDelegate`)
  - Descriptive protocols: suffix with `able` (e.g., `Equatable`, `Runnable`)
- Do **not** add class prefixes (e.g., `CoreUIRoundedButton`). Use module-qualified syntax instead: `CoreUI.RoundedButton()`.
- Generic type parameters must be descriptive `UpperCamelCase`. Use single-letter names (`T`, `U`) only when the type has no semantic meaning.

### Delegates

The first parameter of a custom delegate method must be unnamed and contain the delegate source:

```swift
// ✅
func imageDownloader(_ imageDownloader: ImageDownloader, didFinishDownloading: Bool)

// ❌
func didFinishDownloading(imageDownloader: ImageDownloader)
```

---

## Code Organization

### Extensions

- Write a **separate extension** for each protocol conformance.
- If the extension does not require changing property visibility → put it in a **new file**.
- If it requires relaxing visibility → put it in the **same file**, with a `// MARK:` comment.
### Protocol Conformance

- Implement protocol methods in extensions, not inline in the type declaration.
- Exception: protocols that provide default implementations or without which the object makes no sense (e.g., `Equatable`, `Codable`) may be listed inline.

### Unused Code

Remove all unused or dead code without exception:
- Xcode template stubs (e.g., `didReceiveMemoryWarning`)
- Functions with no callers
- Commented-out code
- Functions that only call `super`
- Incomplete `// TODO:` stubs

### Imports

- Import only modules that are actively used. Remove unused imports.
- Import order: **Apple frameworks → Third-party frameworks → Project modules**, alphabetically within each group.

```swift
// ✅
import SceneKit
import UIKit
import RxCocoa
import RxSwift
import Core
import CoreUI
```

### Namespacing

Use `enum` (not `struct`) for namespaces, since enums cannot be instantiated:

```swift
// ✅
enum Constants {
    static let height: CGFloat = 10
}

// ❌
struct Constants {
    static let height: CGFloat = 10
}
```

---

## Spacing

- Indent with **4 spaces**, never tabs.
- Empty lines must contain only a newline character — no trailing spaces.
- Maximum line length: **120 characters**.
- Add a single blank line after the opening brace of a class/struct and before the closing brace.
- Add a blank line after every `guard` statement block.
- Colons: **no space before**, **one space after**.
  - Exceptions: ternary `?:`, empty dictionary `[:]`, selectors `addTarget(_:action:)`

---

## Comments

**Do not write comments.** Never add a line comment (`//`), a documentation comment (`///`), or a
block comment (`/* ... */`) unless it has been explicitly requested. This applies to new code and to
code being modified — do not "helpfully" annotate a change, a workaround, or a non-obvious line.

Code must be self-documenting instead. If something seems to need explaining, rename it, extract it
into a named property or function, or move a magic number into a named constant until the code
reads on its own.

The only exception is `// MARK:` section markers, which structure a file and are used throughout
this codebase.

Never use C-style block comments `/* ... */` under any circumstances.

Delete comments you come across that are stale or that restate the code.

---

## Classes and Structs

### `self`

Only use explicit `self` in:
- Initializers (when disambiguating)
- Escaping closures

Do **not** use `self` for regular property or method access outside of these cases.

---

## Functions

### Declarations

- Functions fitting within 120 characters → single line.
- Functions exceeding 120 characters → break parameters into separate lines, with the closing `)` and return type on their own line.
- Opening brace `{` is always on the **same line** as the return type.
- Use `()` for void input, `Void` for void output in function **types**. Do not use `-> Void` in function declarations.

```swift
// ✅
func myFunction() { ... }
let onCompleted: () -> Void

// ❌
func myFunction() -> Void { ... }
let onCompleted: () -> ()
```

### Calls

- Short calls → single line.
- Long calls → break parameters, closing `)` stays on the **last parameter line** (not a new line).

```swift
// ✅
let result = someFunction(
    param1: "value1",
    param2: "value2",
    param3: "value3")

// ❌
let result = someFunction(
    param1: "value1",
    param2: "value2",
    param3: "value3"
)
```

---

## Closure Expressions

- Use trailing closure syntax only when there is a **single** closure at the end of the argument list.
- Multiple trailing closure syntax (Swift 5.3+) is optional but acceptable.
- Give closure parameters meaningful names; use anonymous `$0` only when the context is unambiguous.
- Omit `return` in single-expression closures (Swift 5.1+).
- Each chained method using a trailing closure must be on a **new line**.

```swift
// ✅
let value = numbers
    .map { $0 * 2 }
    .filter { $0 > 50 }

// ❌
let value = numbers.map { $0 * 2 }.filter { $0 > 50 }
```

---

## Types

### Optionals

- Use optionals only to represent genuinely absent values — not as error signals.
- Do **not** encode optionality in the name (e.g., no `optionalAddress`, `maybeUser`).
- Use optional chaining `?.` for single-use access. Unwrap with `if let` / `guard let` for repeated access.
- When unwrapping, reuse the same name (shadow the optional). Never use `strongSelf`, `unwrappedValue`, etc.

### Type Inference

Let the compiler infer types wherever possible:

```swift
// ✅
let name = "MyName"
var names: [String] = []

// ❌
let name: String = "MyName"
var names = [String]()
```

Explicit type annotation is acceptable for:
- `CGFloat`, `DayOfWeek`, and other cases where the inferred type would differ from intent.

### Syntactic Sugar

Always use shorthand syntax:

```swift
// ✅
var names: [String]
var map: [Int: String]
var value: Int?

// ❌
var names: Array<String>
var map: Dictionary<Int, String>
var value: Optional<Int>
```

---

## Functions vs Methods

Prefer **methods** over free functions. Use free functions only when behavior is not associated with any type (e.g., `zip`, `max`).

---

## Memory Management

- Never create retain cycles. Use `weak` or `unowned` references, or value types.
- Always capture `[weak self]` in `@escaping` closures. Prefer `weak` over `unowned`.
- After capturing `[weak self]`, immediately unwrap with:

```swift
guard let self = self else { return }
```

Do not scatter optional chaining (`self?.`) throughout the closure body.

---

## Access Control

- Default to `private`. Prefer `private` over `fileprivate`.
- Use `public` or `open` only when explicitly required for cross-module visibility.
- Declare the least restrictive access level that still satisfies requirements.

---

## Property Declaration Order

Nested types and `typealiases` go **first**, before any properties.

Ordering rules (by priority):
1. `static` before non-static
2. `open` → `public` → `internal` → `fileprivate` → `private`
3. `let` before `var`
4. Inline-initialized before lazily/externally initialized
5. Computed properties last
6. `init` after all stored properties

Separate static/non-static groups and different visibility groups with a blank line.

---

## Control Flow

### Prefer `guard` over `if`

Use `guard` to exit early and avoid deeply nested code.

### If-Else

- Braces open on the same line as the statement; close on a new line.
- Multiple conditions: each condition on its own line, opening brace on a new line.

```swift
// ✅
if
    condition1,
    condition2
{
    // ...
}

// ❌
if condition1, condition2 {
```

### Ternary Operator

- Use ternary for **value assignment** when it fits cleanly.
- Do **not** use ternary to call void-returning functions.
- Do **not** nest ternary operators — extract into a separate variable instead.
- Multiline ternary: indent 2nd and 3rd lines by 4 spaces; `?` and `:` at end of line.

```swift
// ✅
variable = condition ?
    valueWithVeryLongName1 :
    valueWithVeryLongName2
```

### Guard Statement

- Single condition with `return` → one line if it fits within 120 characters.
- Multiple conditions → each condition on its own line, `else` on its own line.
- Multiple single-condition guards that return → group them without blank lines between.
- Always leave a blank line **after** the last guard block before the next statement.

---

## Semicolons

Never use semicolons. Never write multiple statements on the same line.

---

## Parentheses

- Do not wrap single `if` conditions in parentheses.
- For complex multi-part conditions, group logically with parentheses and extract sub-conditions into named `Bool` variables.

```swift
// ✅
let isDeveloper = role == .developer
if name == "Name" && isDeveloper { }

// ❌
if (name == "Name") { }
```

---

## Multi-line String Literals

Open `"""` on the assignment line (no text on that line). Indent the content one level. Close `"""` at the correct indentation level.

```swift
// ✅
let message = """
    First line \
    Second line.
    """

// ❌
let message = """First line \
    Second line.
    """
```
