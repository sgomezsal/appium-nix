# appium-nix

<p align="center">
  <img src="assets/demo.gif" alt="appium-nix demo" />
</p>

A minimal Appium runtime powered by Nix.

Run a full mobile automation environment with **one command**.

No manual Android SDK setup.
No global installs.
No Java headaches.

---

## ⚡ Example

Run a real Android automation in one command:

```
nix run github:sgomezsal/appium-nix -- examples/basic_navigation.py
```

Output:

```
[appium-nix] Starting Appium...
[appium-nix] Running: examples/basic_navigation.py
Navigation successful
[appium-nix] Stopping Appium...
```

---

## 🚀 Quick Start

Start Appium server:

```
nix run github:sgomezsal/appium-nix
```

Run an automation example:

```
nix run github:sgomezsal/appium-nix -- examples/basic_navigation.py
```

---

## ✨ Features

- Reproducible Appium runtime
- Automatic Android SDK bootstrap
- Python + Appium client ready
- Automatic Appium lifecycle management
- Supports external scripts

---

## 🧠 Why?

Setting up Appium is often painful:

- Java versions
- Android SDK paths
- Node dependencies
- Driver installs

**appium-nix** removes that friction using Nix and a zero-config workflow.

---

## 🛠 Philosophy

Minimal. Reproducible. Zero-config.

Inspired by tools like Playwright and uv, but focused on mobile automation workflows.

---

## 🤝 Credits

This project would not exist without the help of:

- [https://github.com/Dioprz](https://github.com/Dioprz) — major contributor and co-creator of the flake design and structure.

---

## ⚠️ Status

Experimental but functional.
