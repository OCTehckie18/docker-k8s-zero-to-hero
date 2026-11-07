# 🌿 Track 0: Git: Where Every Change Begins

Before an app can be containerised or deployed, it has to be **written, saved, shared, reviewed and released**. That's Git. This track turns you into the teammate everyone wants: you commit cleanly, collaborate without overwriting anyone, review through pull requests, and stay calm when something breaks.

### 🥞 The story: you work at Vidyarthi Bhavan, Basavanagudi
Bengaluru's legendary breakfast spot in Basavanagudi (since 1943): benne dosa, idli vada, filter coffee. *The website, team, prices and incidents in these labs are invented for teaching; they are not the restaurant's real systems.* Every lab is a day on its tech team, maintaining the menu website with **Lakshmi** (lead developer) and **Ravi** (intern). Real problems, real commands:

| # | Lab | The situation | Time | Level |
|---|---|---|---|---|
| **G00** ⭐ | [**Git Foundations**](00-foundations/README.md) · [quiz](00-foundations/quiz.md) | why version control; 9 diagrams: save points, group photo, draft copies, team flow, undo map | 60–90m | 🟢 |
| G01 | [Day 1: Your First Repository](01-first-repo/README.md) | put the menu under Git | 40m | 🟢 |
| G02 | [Time Travel & Undo](02-time-travel-undo/README.md) | 😱 "Who set benne dosa to ₹1?" blame, revert, restore, amend, reflog rescue | 50m | 🟢→🟡 |
| G03 | [Branches](03-branches/README.md) | build Cold Coffee without breaking the live menu | 40m | 🟢→🟡 |
| G04 | [Teamwork: Push & Pull](04-teamwork-remote/README.md) | Lakshmi joins; your push gets **rejected** | 50m | 🟡 |
| G05 | [Merge Conflicts](05-merge-conflicts/README.md) | 🥞⚔️ the ghee roast dosa price war | 40m | 🟡 |
| G06 | [Pull Requests & Code Review](06-pull-requests/README.md) | a robot and a human catch a ₹2600 typo | 60m | 🟡 |
| G07 | [Release Day & the Friday Incident](07-release-and-incident/README.md) | 🚨 `git bisect` finds the bug, then hotfix, tag, and on to Docker | 50m | 🟡→🔴 |
| 🔥 | [Break-and-fix scenarios G-01 … G-08](troubleshooting/README.md) | the 8 Git emergencies every developer meets | 1–2h | 🟢→🔴 |

### How it works on one laptop, offline
| Folder | Plays the role of |
|---|---|
| `~/z2h-git/cafe` | 🧑 your laptop |
| `~/z2h-git/lakshmi` | 👩 Lakshmi's laptop (from G04) |
| `~/z2h-git/github/cafe.git` | ☁️ GitHub, the team's shared copy (a "bare" repository) |

Jump into **any** lab with its start script, which rebuilds the exact starting point:
```bash
./git/scripts/lab-start.sh 05
```
Optional "real GitHub" steps (with the `gh` CLI) are included in G04 and G06.

### What you need
Just **Git** (`git --version`), with no Docker or Kubernetes required for this track. Works on macOS, Linux, Windows (Git Bash or WSL) and the Killercoda Ubuntu playground.

📚 Keep the [Git cheat sheet](../cheatsheets/git.md) open while you work: every command in both its classic (`checkout`) and modern (`switch`/`restore`) form.

➡️ Start with [G00 Git Foundations](00-foundations/README.md) · then continue to [🐳 Track 1: Docker](../docker/README.md)
