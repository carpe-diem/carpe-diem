# Hi there, I'm carpe-diem! 👋

Welcome to my GitHub profile! I'm a passionate developer who loves to code and create amazing projects. Here's a little bit about me:

## 👀 Interests
- **Python**
- **Rust**
- **Artificial Intelligence**

## 🌱 Learning
- Studying a [Master's Degree in Artificial Intelligence](https://www.universidadviu.com/es/master-inteligencia-artificial)
- Currently diving deep into **Rust**.
- Exploring the world of **Artificial Intelligence**.

## 👯 Looking to Collaborate On
- Projects related to **Artificial Intelligence**.
- Innovative ideas involving **AI**, **Python** and **Rust** technologies.

## 👷🏻‍♂️ Side Prejects

- [OTPilot](https://otpilot.app) OTPilot is a Chrome extension that turns any site's 2FA setup page into a one-click add — no QR scanner, no secret keys, no phone. When you visit a login page it's configured for, it fills the TOTP code and submits the form automatically. Everything is stored locally, protected by a master password, and never sent to any server.
- [Pomodoso](https://pomodoso.com) A focus timer for developers that lives in your browser. It runs Pomodoro sessions, tracks tasks and habits, syncs with Google Calendar, and automatically detects the Linear issue or GitHub PR you have open (or any URL you configure) — so you can start working with one click, no context switching required.
- [PipeHero](https://pipehero) Develop, debug & ship webhooks. Tunnel public traffic to your machine, inspect and replay every request, and debug it with your team, or hand it to your AI agent via MCP.
- [GitArena.app](https://gitarena.app) Turn Pull Request Reviews into a Competitive Sport. GitArena transforms code reviews from a chore into an exciting competition. Track metrics, earn points, and climb the leaderboard.
- [StoryPlace.io](https://storyplace.io) Helps Startups improve their products. They receive product feedback, analyze and prioritize the feedback, and enhance features.
  
## 📫 How to Reach Me
- [Email](mailto:alberto@paparelli.com.ar)
- [Linkedin](https://www.linkedin.com/in/paparelli/)
- [Wellfound](https://wellfound.com/u/paparelli)
- [Twitter](https://twitter.com/carpedev)
- [Twitch](https://www.twitch.tv/carpedev)

## ⚡ Fun Fact
- Enjoys spending time with family and friends, travelling, and exploring new places.
- Passionate about reading, especially topics related to technology and science.

## ⚙️ Dotfiles

This repo doubles as my dev environment config: Ghostty pinned as a dedicated host for
[Herdr](https://herdr.dev), Herdr's own theme/keybind setup, and a [LazyVim](https://www.lazyvim.org)-based
Neovim config (Python LSP, file tree, git blame on the current line, a trimmed-down Ruff rule set,
lazygit wired to `<leader>gg`), plus [pi](https://pi.dev) with Herdr's integration and a one-line
footer extension (path · git branch · model · context bar).
See [`configs/`](./configs) for the files and [`INSTALL_PROMPT.md`](./INSTALL_PROMPT.md) for a
ready-to-paste prompt that has an AI agent install all of it on a new machine, so every machine
ends up with the same setup. New Herdr workspaces open with the tabs IA (claude), Services
(2x2 shells), Git (lazygit), Code (nvim) and Console. After changing a config, push it and run
[`./update.sh`](./update.sh) on each machine to apply it (it pulls, copies only what changed, and
backs up whatever it overwrites).

It also holds my shared local dev infrastructure in [`infra/`](./infra): one Postgres, S3
(SeaweedFS), Logto, Mailpit and Caddy on `*.localhost` for every project, each project getting its
own database, bucket and site via `infra/infra project create <name>`. Works with Docker or Podman.


Thank you for visiting my profile! Feel free to check out my repositories and get in touch.
