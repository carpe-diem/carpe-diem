/**
 * One-line footer for pi:
 *   ~/code/carpe-diem · git:main · xai/grok-4.7 (high)        [▪▪........] 18% (256k)
 * Replaces pi's default footer; delete this file to get the default back.
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

const BAR_WIDTH = 10;

function formatTokens(n: number): string {
	if (n >= 1_000_000) return `${+(n / 1_000_000).toFixed(1)}M`;
	if (n >= 1000) return `${Math.round(n / 1000)}k`;
	return `${n}`;
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx: ExtensionContext) => {
		ctx.ui.setFooter((tui, theme, footerData) => {
			const unsub = footerData.onBranchChange(() => tui.requestRender());
			const sep = theme.fg("dim", " · ");

			const cwd = (): string => {
				const home = process.env.HOME;
				const path = home && ctx.cwd.startsWith(home) ? `~${ctx.cwd.slice(home.length)}` : ctx.cwd;
				const cut = path.lastIndexOf("/") + 1;
				return theme.fg("dim", path.slice(0, cut)) + theme.fg("accent", theme.bold(path.slice(cut)));
			};

			const model = (): string => {
				if (!ctx.model) return theme.fg("dim", "no model");
				const thinking = pi.getThinkingLevel();
				return (
					theme.fg("dim", `${ctx.model.provider}/`) +
					theme.fg("text", ctx.model.id) +
					(thinking && thinking !== "off" ? theme.fg("text", ` (${thinking})`) : "")
				);
			};

			const context = (): string => {
				const usage = ctx.getContextUsage();
				const window = usage?.contextWindow ?? ctx.model?.contextWindow;
				const percent = usage?.percent ?? 0;
				const filled = Math.min(BAR_WIDTH, Math.round((percent / 100) * BAR_WIDTH));
				const color = percent >= 80 ? "error" : percent >= 50 ? "warning" : "success";
				const bar = `[${"▪".repeat(filled)}${".".repeat(BAR_WIDTH - filled)}]`;
				return (
					theme.fg(color, `${bar} ${Math.round(percent)}%`) +
					(window ? theme.fg("dim", ` (${formatTokens(window)})`) : "")
				);
			};

			return {
				dispose: unsub,
				invalidate() {},
				render(width: number): string[] {
					const branch = footerData.getGitBranch();
					const left = [cwd(), branch ? theme.fg("warning", `git:${branch}`) : "", model()]
						.filter(Boolean)
						.join(sep);
					const right = context();
					const gap = width - visibleWidth(left) - visibleWidth(right);
					if (gap < 2) return [truncateToWidth(left, width)];
					return [left + " ".repeat(gap) + right];
				},
			};
		});
	});
}
