# Benchmark / positioning: existing tools for interactive context curation

Date: 2026-10-16. A look-around check before locking objectives and design further.
Items marked *(k)* come from the model's own knowledge and were not re-checked online this session. Everything else was checked through web search (sources at the end).
**Verification pass:** the homepages or docs of ThoughtDAG, Context Viewer, Letta ADE, ContextCraft and DAI Studio (through an article) were fetched, and the rows were corrected. Tangents.chat could not be fetched.

---

## 1. Landscape by category

### A. Vendor API-level context management
| Tool | Overlap with our goals | Limits vs. our goals |
|---|---|---|
| **Anthropic context editing** (`clear_tool_uses`, `clear_thinking`), **server compaction** (`compact_*`), **memory tool** | Automated pruning (clears tool results but keeps the record of the call), summarizing, persistent memory files | Policy-driven and automatic, triggered by token thresholds. No human in the loop, no structure, no view of what was dropped. |
| **OpenAI Responses / Conversations API** (`previous_response_id`, server state, `/compact`) | Chains and forks responses; server-side compaction | State lives on the server; compaction items are **encrypted and opaque**. Response chains can't be edited after the fact; `truncation:auto` breaks the cache. |
| **Anthropic Console Workbench, OpenAI Playground** *(k)* | Prompt editing, side-by-side comparison, evals | Work on a single prompt, not on a live session or an agent loop. |

### B. Observability / eval platforms
| Tool | Overlap | Limits |
|---|---|---|
| **LangSmith** | Traces; "Open in Playground" to edit and re-run any logged call; datasets; pairwise experiments; Studio applies changes back to a running agent | For developers, after the fact, about *apps*. No KR. Tied to the LangChain ecosystem. |
| **Langfuse** (MIT, self-hostable) | Traces, prompt versions, experiments, side-by-side playground | Same: monitoring and evals, not live curation. |
| **Phoenix, Braintrust, Helicone, promptfoo** *(k)* | Tracing, A/B evals, cost tracking | Same category. |

### C. Agent frameworks with persistent state
| Tool | Overlap | Limits / known pitfalls |
|---|---|---|
| **LangGraph** checkpointers, **time travel**, **interrupts** | Exactly our "tree of steps + gate": replay or fork from any checkpoint; `update_state` creates a branch and keeps history; `interrupt()` is a human-in-the-loop gate | The node re-runs after resume, so side effects run twice. Replay re-runs LLM and tool calls. Some durability modes lose intermediate state. A framework, not a curation UI. |

### D. Memory systems
| Tool | Overlap | Limits |
|---|---|---|
| **Letta ADE** | **Context window viewer**; editable **memory blocks**, each with a character limit | Context = agent-managed memory blocks, not a KR of the conversation. The agent edits itself; human curation is secondary. *Verified:* the original ADE docs are deprecated (new ADE at chat.letta.com). They confirm only that memory blocks can be edited; the docs don't mention editing message history or showing a token breakdown. |
| **Zep / Graphiti** | **Temporal knowledge graph** built from episodes. **Bidirectional provenance** between episodes and facts. Bi-temporal timestamps. Contradicted facts are **invalidated, not deleted** | LLM extraction on every episode is costly (strongly disputed numbers: 600k+ tokens per conversation reported by Mem0). Built for retrieval, not for editing the context. |
| **Mem0** *(k)* | Light extracted memory | Same retrieval focus. |

### E. Coding-agent harnesses
| Tool | Overlap | Limits |
|---|---|---|
| **Claude Code** | `/context` usage breakdown; `/compact` with focus instructions; `/rewind` checkpoints (files and conversation); **hooks**: `PreToolUse` → allow/deny/ask/defer, plus `updatedInput` to rewrite the tool call; Pre/PostCompact | Curation is coarse (compact, rewind). There's no structured view of the context. Checkpoints cover file edits, not every side effect. |
| **Cline / Roo Code** *(k)* | Approval of each tool call, diff view, checkpoints, context bar | Same coarseness. |
| **Aider** *(k)* | Explicit `/add` and `/drop` of files in context; repo map | Curation at file level only. |

### F. Interactive context editors / explorers (closest to us)
| Tool | Overlap | Limits |
|---|---|---|
| **ThoughtDAG** (MIT, v0.5; ~640 stars, ~820 commits; desktop app, CLI, MCP) | "Wires are the context": each exchange is a node, and the wired paths **are** the next request. Branch, merge, prune (disconnect a path but keep it visible), Condense, **staleness** (rerun dependent answers in dependency order), preview of the request before sending. **Recall** with **topic dossiers** (decisions and open questions, linked to sources), chosen by an optional model ("Jev") or by rules as a fallback. **Session Atlas** imports Claude Code, Codex and Pi sessions **read-only**. Context-repair pilot: removing the wrong source repaired 152/162 cases, removing the contaminated subgraph repaired 162/162 | Explicitly "not an autonomous research agent or a replacement for your coding harness": **no agent loop, no tool-call approval**. Providers are Ollama or OpenAI-compatible endpoints. No token counts mentioned. KR is message-level, plus generated dossiers; no ontology. |
| **Context Viewer** (ACM CAIS '26 demo; nilenso + CMU) | **LLM-extracted** pipeline: segmentation, then topics, then classification. **The user can revise the pipeline's prompts**, which is a middle ground between manual and automated extraction. Filter, group, compare runs; evaluates compaction; tracks how the system prompt grows | Analysis only: the context itself can't be edited, and there's no round trip. No public code repository. |
| **ContextCraft, DAI Studio** | Canvas or blocks to assemble a context under a token budget. DAI Studio (v0.5.1, Jun 2026) uses BPMN-like nodes stored as plain-text `.dai` files that can be versioned in git | Built **before the call**; no live session or agent loop. ContextCraft is a toy (2 stars, 3 commits, generated by an AI agent). |
| **Tangents.chat** ("context compiler") | Mentioned in the ThoughtDAG HN thread | *Not verified* (the site fetch failed). |
| **Loom** (Janus; Obsidian plugin) | Tree / "multiverse" of continuations; navigate, prune, splice | Built for base-model text generation, not chat, tools or agents. |
| **SillyTavern** | Mature **injection** model: Prompt Manager ordering; World Info entries triggered by keywords and inserted at a chosen **position or depth**; Author's Note; per-prompt token breakdown | Built for roleplay. Its injection rules are keyword-based, not semantic. |
| **ChatGPT, Open WebUI, LibreChat branching** *(k)* | Edit a message and branch | Only a list or tree of messages; no structure. |

---

## 2. Takeaways for our design

1. **Our niche is real but narrow.** We found no tool that combines **(a)** an extracted KR, **(b)** a round trip from KR back to the prompt, with provenance, **(c)** gates on the agent loop, and **(d)** a workbench with metrics and cache-cost awareness. But each piece already exists somewhere, and the space is getting crowded in 2026 (ThoughtDAG, Context Viewer, DAI Studio). We need a clear statement of what sets us apart.
   - *After checking homepages:* ThoughtDAG is more mature than first assumed. It already covers round-trip editing at the level of messages and paths, branch/merge/prune, staleness, and read-only import of Claude Code sessions. What sets us apart therefore comes down to: **(c) the live agent loop with gates and tool-call blast radius** (ThoughtDAG explicitly excludes this), **a Claude-native, cache-aware workbench**, and **a KR finer than whole messages** (an ontology, not only paths of exchanges).
   - ThoughtDAG's context-repair pilot is outside evidence for the curation premise: removing the wrong source or the contaminated subgraph repairs most downstream errors.
2. **New high-profile question: standalone vs. companion.** Do we run our own loop and API calls (full control, the current plan), or sit beside existing harnesses (Claude Code transcripts and hooks, as ThoughtDAG does), or both (import sessions, then curate and re-run)? This affects A and the control layer more than anything else so far.
3. **KR v1 has three proven patterns to borrow from:**
   - authored by the user (ThoughtDAG graph);
   - extracted by an LLM as segments, topics and classes, where the user can revise the extraction prompts (Context Viewer);
   - dossiers of decisions and open questions linked to their sources, with rules as the fallback (ThoughtDAG);
   - an episode → fact graph with provenance and invalidation (Graphiti).

   The extraction cost criticism of Graphiti confirms our LLM-extraction risk.
4. **Operations to add or refine:**
   - **elide/stub** (keep the record of the call, drop its payload), which is what the vendor APIs do;
   - **invalidate rather than delete**, which fits our append-only design.
5. **Forking the conversation doesn't fork the world.** Replaying or branching re-runs tool side effects (LangGraph pitfall; Claude Code checkpoints don't cover every side effect). Steps should be marked as side-effecting or pure, and the executor needs snapshots or a sandbox before branching is safe. Candidate for the "decide early" list.
6. **Gate vocabulary already exists:** allow/deny/ask/defer plus input rewrite (Claude Code hooks). Reuse it.
7. **Stay client-side and stateless.** Vendor features are moving server-side, automatic and opaque (OpenAI encrypted compaction). For us they are either turned off or modeled as operations. When we generalize to other providers, stateless endpoints fit; server-state APIs are harder to curate.
8. **Persistence: don't reinvent the trace format.** Look at the OpenTelemetry GenAI conventions *(k)* and LangSmith/Langfuse traces, for import and export.
9. **Injection vocabulary:** SillyTavern's position, depth, triggers and priority. **Budget view:** Letta's per-section limits.
10. **Measuring effectiveness:** there's prior work to look at (ThoughtDAG's "Context Intervention Benchmark", Context Viewer's compaction evaluation).

---

## Sources
- Letta ADE: https://docs.letta.com/guides/ade/context-window-viewer/ · https://www.letta.com/blog/introducing-the-agent-development-environment/
- LangGraph: https://docs.langchain.com/oss/python/langgraph/use-time-travel · https://docs.langchain.com/oss/python/langgraph/interrupts · https://docs.langchain.com/oss/python/langgraph/checkpointers · https://dev.to/priyansh_singhal_5975e7d3/your-langgraph-node-runs-twice-after-interrupt-thats-by-design-796
- Anthropic: https://platform.claude.com/docs/en/build-with-claude/context-editing · https://platform.claude.com/docs/en/agents-and-tools/tool-use/memory-tool · https://platform.claude.com/cookbook/tool-use-context-engineering-context-engineering-tools
- Claude Code: https://code.claude.com/docs/en/hooks · https://code.claude.com/docs/en/best-practices
- OpenAI: https://developers.openai.com/api/docs/guides/compaction · https://developers.openai.com/api/docs/guides/migrate-to-responses · https://community.openai.com/t/compact-a-response-with-previous-response-id/1372502
- LangSmith / Langfuse: https://docs.langchain.com/langsmith/observability-studio · https://langfuse.com/resources/engineering/langsmith-alternative
- Zep / Graphiti: https://arxiv.org/pdf/2501.13956 · https://help.getzep.com/graphiti/getting-started/overview
- ThoughtDAG: https://news.ycombinator.com/item?id=49307700 · https://github.com/chenxiachan/thoughtdag
- Context Viewer: https://dl.acm.org/doi/10.1145/3786335.3813210 · https://www.caisconf.org/program/2026/demos/context-viewer/
- ContextCraft: https://github.com/dakshjain-1616/ContextCraft · DAI Studio: https://www.creativeainews.com/blog/dai-studio-visual-context-engineering-llm-2026/
- Loom: https://generative.ink/posts/language-models-are-multiverse-generators/ · https://cyborgism.wiki/hypha/loom
- SillyTavern: https://docs.sillytavern.app/usage/core-concepts/worldinfo/
