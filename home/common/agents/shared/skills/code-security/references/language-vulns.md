# Language-Specific Vulnerability Patterns

## Python

| Vulnerability | CWE | Search For | Fix |
|---|---|---|---|
| Pickle deserialization | 502 | `pickle.loads`, `pickle.load`, `shelve.open`, `joblib.load`, `torch.load`, `numpy.load` with `allow_pickle=True` | JSON/protobuf. HMAC-sign if pickle required. `weights_only=True` for torch |
| YAML deserialization | 502 | `yaml.load(` without `SafeLoader`, `yaml.FullLoader` | `yaml.safe_load()` or `Loader=yaml.SafeLoader` |
| Format string injection | 134 | `.format(` with user-controlled template, `logging.info(user_string % values)` | Never let user control format string |
| Subprocess injection | 78 | `subprocess.run`, `subprocess.call`, `os.system`, `os.popen` with `shell=True` or string args with user input | List args with `shell=False`. Allowlist inputs |
| eval/exec | 95 | `eval(`, `exec(`, `compile(` with user input path | Remove entirely. `ast.literal_eval` for literals |
| SSTI | 1336 | `Template(request.`, `Template(user_` (Jinja2, Mako, Django) | Pass user input as context vars, not template source. `SandboxedEnvironment` |

## JavaScript / TypeScript

| Vulnerability | CWE | Search For | Fix |
|---|---|---|---|
| Prototype pollution | 1321 | Custom deep merge/clone, `_.merge`, `_.defaultsDeep`, `_.set` with user input | Filter `__proto__`/`constructor`/`prototype` keys. Use `Map` for user keys |
| ReDoS | 1333 | Nested quantifiers: `(a+)+`, `(a*)*`, `(a\|b\|c+)+` | Eliminate nested quantifiers. `re2` for user patterns. Timeouts |
| XSS (React/Vue) | 79 | `dangerouslySetInnerHTML`, `v-html`, `bypassSecurityTrust`, `href`/`src` bound to user input | DOMPurify. Allowlist URL schemes (`https:`, `mailto:`). Prefer text rendering |
| eval/dynamic code | 95 | `eval(`, `new Function(`, `setTimeout(`/`setInterval(` with string args, `vm.runInNewContext` | Remove eval. JSON.parse for data. Function refs for timers. `vm` is not a sandbox |
| Dynamic imports | 22, 98 | `` require(`./handlers/${` ``, `` import(`./plugins/${` `` | Allowlist of valid module names |
| Supply chain | 829 | `preinstall`/`postinstall` scripts in deps, low-download packages shadowing internal names | `npm audit`, scoped registries, `--ignore-scripts` in CI, provenance verification |

## Go

| Vulnerability | CWE | Search For | Fix |
|---|---|---|---|
| SQL injection | 89 | `db.Query("..."+`, `db.Exec(fmt.Sprintf(`, `db.QueryRow` with string concat | Parameterized queries (`$1`, `?`) |
| Race conditions | 362 | Global `map` accessed from handlers/goroutines without `sync.Mutex`, check-then-act on shared state | `sync.Mutex`/`sync.RWMutex`/`sync.Map`. Hold lock across check-and-act. `go test -race` |
| Integer overflow | 190 | Explicit type conversions (`int64` to `int32`, `uint` to `int`), arithmetic on user input | Validate ranges before conversion. `math.MaxInt32` guards |
| Unsafe pointer | 787, 125 | `import "unsafe"`, `unsafe.Pointer`, `reflect.SliceHeader`, `reflect.StringHeader` | Avoid unless required. Document safety invariants. `go vet` |
| Missing error check | 391 | `err` assigned but not checked (security-critical paths: auth, crypto, file ops) | Always check errors on security paths |

## Java

| Vulnerability | CWE | Search For | Fix |
|---|---|---|---|
| Deserialization | 502 | `ObjectInputStream`, `readObject()`, `readUnshared()`, `XMLDecoder`, `XStream`, `SnakeYAML Yaml.load()` | JSON (Jackson/Gson)/protobuf. `ObjectInputFilter` (Java 9+) if unavoidable |
| JNDI injection | 917 | `ctx.lookup(`, `InitialContext`, Log4j2 < 2.17.1 with user input in log messages | Never pass user input to JNDI. Log4j >= 2.17.1. `formatMsgNoLookups=true` |
| XXE | 611 | `DocumentBuilderFactory`, `SAXParserFactory`, `XMLInputFactory`, `TransformerFactory` without disabling external entities | `setFeature("...disallow-doctype-decl", true)`, disable external entities/parameter entities |
| EL injection | 917 | `createValueExpression`, `createMethodExpression`, `ExpressionParser.parseExpression` with user input | Never construct EL from user input. `SimpleEvaluationContext` for Spring SpEL |

## Rust

| Vulnerability | CWE | Search For | Fix |
|---|---|---|---|
| Unsafe blocks | 787, 125, 416 | `unsafe {`, `unsafe fn`, `unsafe impl` | Minimize surface. Encapsulate with safe APIs. `#[deny(unsafe_code)]` at crate level. `cargo miri test` |
| FFI boundary | 119 | `extern "C"`, `extern "system"`, `#[link(name =` | Validate buffer sizes. `CString`/`CStr` for strings. Wrap in safe APIs |
| Panic in libraries | 248 | `.unwrap()`, `.expect(`, `panic!(`, `todo!(`, direct indexing `[index]` without bounds check | Return `Result`/`Option`. `.get(index)`. `cargo clippy --warn clippy::unwrap_used` |
| TOCTOU with locks | 362 | `Mutex`/`RwLock` lock-check-drop-relock patterns | Hold lock across entire check-then-act. Atomic ops for simple flags |
| Crypto misuse | 327 | `rand::thread_rng` for security tokens, tokens < 128 bits | `OsRng` with >= 128 bits. Use `ring`/`rustcrypto`/`sodiumoxide` |
