---
name: agent-self-management
description: "Self-learning system for agents to update knowledge bases, record lessons learned, track patterns, and improve over time. Used by all agents for continuous self-improvement."
---
# Agent Self-Management

## Purpose
Enable agents to record and retrieve lessons learned, update their knowledge bases, and avoid repeating past mistakes.

## When to Use
- After resolving a complex issue
- When discovering a new pattern or anti-pattern
- After a failed approach — record what didn't work and why
- When a test reveals unexpected behavior

## Protocol

### Recording a Lesson
1. Identify the insight: what was learned?
2. Classify: pattern, anti-pattern, gotcha, or optimization
3. Determine scope: workspace-wide or project-specific
4. Write concise note with context and evidence
5. Store in appropriate memory scope

### Retrieval
- Check memory at session start for relevant prior knowledge
- Before attempting a complex task, search for related lessons
- Cross-reference findings with known gotchas list

## Storage Locations
- User memory (`/memories/`) — cross-workspace insights
- Session memory (`/memories/session/`) — current task context
- Repository memory (`/memories/repo/`) — codebase-specific facts
