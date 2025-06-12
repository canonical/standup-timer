# Stand-Up Timer App

A lightweight Flutter desktop application that helps run efficient stand-up or daily-scrum meetings.  
Each participant gets a fixed countdown (default 2 min) that automatically advances to the next speaker when time is up.  
You can quickly include/exclude speakers and see the total expected meeting time before you start.

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| **Name picker** | Toggle who should speak today with a single click. |
| **Auto-shuffle** | Names are shuffled on every app launch for variety. |
| **Circular countdown** | Large, animated timer ring with MM:SS display. |
| **One-click controls** | Start, Stop/Resume, Next person, and full Restart. |
| **Expected duration** | Shows total meeting length based on selected speakers. |

---

## 🚀 Getting Started


  ```bash
  git clone git@github.com:canonical/standup-timer.git
  cd standup-timer/standup_timer
  flutter config --enable-linux-desktop
  flutter create --platforms=linux .
  flutter run -d linux
  ```

  Tip: Replace the default _allNames list in main.dart with your actual team names.


## 🖥️ Usage

- Select speakers – Click a name to include/exclude it (blue = selected).
- Check “Expected time” – Shows total minutes based on your selection.
- Start – The first speaker’s timer begins.
- Stop/Resume – Pause if needed.
- Next person – Skip ahead manually.
- Restart – Reset the whole session without closing the app.


## 🔧 Customisation
- Timer length – Change _duration (seconds) in _TimerPageState.
- Default names – Edit the _allNames list at the top of main.dart.
