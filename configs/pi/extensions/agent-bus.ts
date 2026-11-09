/**
 * Logs `herdr agent prompt` calls made through pi's bash tool to the agent bus
 * (~/.config/herdr/local-plugins/agent-map/agent-bus.py), so the agent map
 * (prefix+m in Herdr) can show who asked whom for what.
 */

import { spawn } from "node:child_process";
import { existsSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const BUS = join(homedir(), ".config/herdr/local-plugins/agent-map/agent-bus.py");
const commands = new Map<string, string>();

function record(entry: Record<string, unknown>) {
	if (!existsSync(BUS)) return;
	try {
		spawn("python3", [BUS, "record", JSON.stringify(entry)], { stdio: "ignore", detached: true }).unref();
	} catch {
		// never get in the agent's way
	}
}

export default function (pi: ExtensionAPI) {
	pi.on("tool_call", (event) => {
		if (event.toolName !== "bash") return undefined;
		const command = String(event.input?.command ?? "");
		if (!/herdr\b[^\n]*\bagent\s+prompt\b/.test(command)) return undefined;
		commands.set(event.toolCallId, command);
		record({ phase: "sent", id: event.toolCallId, command });
		return undefined;
	});

	pi.on("tool_result", (event) => {
		const command = commands.get(event.toolCallId);
		if (command === undefined) return undefined;
		commands.delete(event.toolCallId);
		record({ phase: "returned", id: event.toolCallId, command, exit: event.isError ? 1 : 0 });
		return undefined;
	});
}
