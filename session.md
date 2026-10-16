# Session log — Context Curator

Read this file to get started quickly. Together with `plan_v1.md`, it is the **only** starting point for new sessions.

## Starting-point rules
- **Start from:** `session.md` (this file) and `plan_v1.md`. The plan holds the current structured view of the project; this log holds how we got there and how we work.
- **`PROJECT_INTENT.md` has been used.** It is kept as an archive only. Do not use it as a starting point again.
- **Ignore** `./captures/` (the user's monitoring of our exchanges) and `./grab-proxy.sh`.
- `objectives(note-to-self).md` is the user's own note. Do not read it unless asked.

## Persona / working mode (session 1: planning phase)
The user may ask to resume this mode ("slow, brief brainstorming at a high level"). It means:
- **Brief answers.** This is really important. Short bullets, no walls of text.
- **The user leads.** Go step by step from vague, systemic directions down to concrete specs. Don't rush into specifics.
- **No suggestions** unless the user asks for them, or asks for feedback on what they proposed.
- **Technical details** only when they are a serious risk or bottleneck that has to be discussed alongside the high-level objectives.
- **Open-ended brainstorming first.** Filter and summarize only when the user asks.
- **Don't** load skills, spawn agents, or over-engineer.
- **Stay local** (console and repo). Don't publish artifacts. One plan artifact was published by mistake in session 1, is private, and is no longer maintained.
- The user may push toward a different persona as phases change. Follow that.

## Session 1 — 2026-10-16 — high-level planning
Chronological summary of what we decided and what emerged:

1. **Project framing.** A "context curator" app: it gives a running account of the LLM context and lets the user curate it interactively (stress, prune, organize, separate immediate objectives from distant ones). It also acts as a **workbench**: token and usage display, pruning and summarizing suggestions, A/B sub-calls, sandboxed agentic test runs. **UI ergonomics is the central feature**: turn unstructured text into something a human can see and act on. Key tension: formal and deterministic curation versus LLM-automated curation (vague outcomes and added cost).
2. **Claude first, not Claude only.** Start with the Anthropic API (own key, full control) and its message data model. Other endpoints and models stay an open perspective.
3. **Work items grouped** into A (Foundation: API port, schema, state, persistence), B (Curation: filter, prune, summarize; KR; metrics), C (UI: conversation view, history navigator and editor, dashboard), D (Agentic extensions: skills, harness and sandbox, multi-agent).
4. **Knowledge representation (KR) is a spine** that runs across A, B and C, not one item in B. It covers the ontology (what) and the representation (graph or hierarchy). It is a data pipeline: messages → extraction → KR → curation and rendering → assembly back into messages.
5. **The round trip is the core difficulty.** Agreed strategy: (1) keep the KR pipeline and its risks high profile; (2) v1 commits to **one concrete ontology and one extraction process**, tested on both ergonomics and effectiveness; (3) leave the design open for other KR models and extractors. Supporting principles: provenance from KR back to the source text; the transcript plus the edit log are the source of truth; edits are a small set of **operations** (drop, replace, pin, insert); don't abstract before a second variant exists.
6. **Injection** (skills, fetched content, RAG, persona) is the **insert** operation. Injected items are tagged with their origin. The **transcript is separate from the assembled prompt**: the prompt is compiled at each call. The API is stateless (the full prompt is re-sent on every call), so any history edit is possible, but it **invalidates the prompt cache** from the edit point onward. Signed thinking blocks cannot be edited.
7. **Coherent view.** One pipeline (the spine) with layers around it: Foundation, KR, Curation, Interaction, plus extensions plugged in. See `plan_v1.md`.
8. **The agent loop is a first-class concern** (the user flagged this as weighing heavily on design). The spine runs **at each loop step**. A **single gate** (checkpoint) comes before any API call or tool execution; there the user approves, rejects, edits (back through the pipeline) or branches. **Gate policy** (auto, review or deny, graded by risk) holds the automation-vs-safety tension; v1 reviews everything plus an allowlist. **Tool-call visualization** shows the blast radius (diffs, paths, network access, reversibility). **Decide early:** history as a tree of steps, append-only step records, one gate with a policy hook, an executor behind a narrow interface. **Defer:** multi-agent, a rich policy language, LLM risk assessment, parallel branches.

9. **Benchmark / positioning check** (details in `benchmark.md`). Key takeaways:
   - **The niche is real but narrow.** No tool combines an extracted KR, a round trip with provenance, gates on the agent loop, and a workbench with cache-cost awareness. Each piece exists somewhere. Closest tools: ThoughtDAG (a user-drawn graph that *is* the context), Context Viewer (LLM-extracted topics, read-only), Letta ADE (context viewer and memory blocks), LangGraph (checkpoints, fork, interrupts). We need to state clearly what sets us apart.
   - **New high-profile question: standalone vs. companion** to existing harnesses (Claude Code transcripts and hooks), or both.
   - **Forking the conversation doesn't fork the world.** Replay and branching re-run tool side effects, so we need side-effect marking and snapshots or a sandbox.
   - **Reuse existing vocabularies:**
     - gates: allow/deny/ask/defer plus input rewrite (Claude Code hooks);
     - injection: position, depth, triggers, priority (SillyTavern);
     - budgets: per-section limits (Letta);
     - KR patterns: user-authored (ThoughtDAG), LLM-extracted (Context Viewer), episodes → facts with provenance (Graphiti).
   - **Operations:** add **elide** (keep the record of the call, drop its payload) and **invalidate rather than delete**.
   - **Stay client-side and stateless** (vendor compaction is moving server-side and becoming opaque). Align persistence with existing trace formats (OpenTelemetry GenAI, LangSmith/Langfuse).

10. **ThoughtDAG is the main reference product.** The user plans to use `benchmark.md` as the yardstick for any future spec, with ThoughtDAG as the main comparison. Reusing open-source parts (MIT) is an option for later, once the stack is chosen. Prefer reusing their underlying libraries or interop surfaces (MCP, JSON export) over forking app code.

**Status at the end of session 1:** the design is not locked in, but specs are starting to emerge. Successive refinement passes are planned, to limit back-and-forth and refactoring. Next step, in a new session: go into specifics and detailed specs before building.
