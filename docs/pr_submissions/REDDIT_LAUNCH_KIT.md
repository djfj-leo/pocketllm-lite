# PocketLLM Lite: Reddit Launch Kit & Direct Submission Links

---

## 1. r/LocalLLaMA

* **Subreddit Link**: [r/LocalLLaMA](https://www.reddit.com/r/LocalLLaMA/)
* **Direct Submit Link**: [Create Post on r/LocalLLaMA](https://www.reddit.com/r/LocalLLaMA/submit)
* **Required Flair**: `Project` or `Software`

### Post Title:
```text
I got tired of ad-filled mobile wrappers for Ollama, so I built PocketLLM Lite — an open-source, offline Android client (Local GGUF, SKILL.md plugins, local RAG)
```

### Post Body (Copy & Paste):
```markdown
Hey r/LocalLLaMA,

Like a lot of people here, I use local models via Ollama on my desktop/server and wanted a mobile client that actually felt responsive, worked offline, and respected privacy. Most apps on the Play Store are either subscription traps, loaded with ads, or route everything through third-party cloud servers.

So I built **PocketLLM Lite** — a 100% open-source, ad-free Flutter client designed specifically for local LLMs, GGUF models, and self-hosted Ollama workflows.

### 🛠️ Key Features:
* **Runs Offline & Connects to Ollama**: Run GGUF models directly on-device or stream seamlessly from your home Ollama instance over Wi-Fi/Tailscale.
* **DeepSeek R1 Thinking Accordion**: Native streaming support for `<think>` reasoning blocks rendered in a collapsible Material 3 accordion UI.
* **Agentic Tool Calling Pipeline**: Executes local math, system diagnostics, and knowledge lookup directly on the device with structured `<tool_call>` UI cards.
* **Open-Standard Agent Skills (`SKILL.md`)**: Install skills directly from GitHub URLs or create custom skills offline with `/` autocomplete support.
* **Web Search Fallback (Tavily Integration)**: Toggle live web search when offline models need current data, with inline markdown source citations `[Source](URL)`.
* **Local Vector RAG**: Ingest PDFs and text files locally to chat with your documents offline without sending data to external servers.
* **Offline STT & TTS**: Voice-type your prompts offline and listen to completions using native speech engines.
* **Zero Ads & Zero Telemetry**: Completely free, open-source (MIT License), and built with Material 3 Expressive UI.

### 📊 Performance Profiler:
Built-in speed profiler to measure Time to First Token (TTFT) and token generation speed (tokens/sec) directly on your device hardware.

* **GitHub Repository**: https://github.com/PocketLLM/pocketllm-lite
* **Release APK Downloads**: https://github.com/PocketLLM/pocketllm-lite/releases

I'd love to get feedback from the community on features or model interfaces you'd like to see next!
```

---

## 2. r/androidapps

* **Subreddit Link**: [r/androidapps](https://www.reddit.com/r/androidapps/)
* **Direct Submit Link**: [Create Post on r/androidapps](https://www.reddit.com/r/androidapps/submit)
* **Required Flair/Tag**: Must include `[DEV]` in title.

### Post Title:
```text
[DEV] PocketLLM Lite – Ad-free, open-source offline AI assistant for Android (Runs local GGUF models & Ollama, zero telemetry)
```

### Post Body (Copy & Paste):
```markdown
Hi r/androidapps!

I'm the developer of **PocketLLM Lite**, an open-source Android app created for anyone who wants an AI assistant that works 100% offline, doesn't collect user data, and contains zero ads or subscriptions.

### Why I built it:
Many AI apps on Android lock basic features behind $20/month paywalls, track user prompts, or stop working the moment you enter an airplane or subway. PocketLLM Lite runs local AI models directly on your phone hardware or connects to your home computer over Wi-Fi.

### Core Features:
- 🔒 **100% Private & Ad-Free**: No trackers, no account creation, no analytics.
- ⚡ **Offline Dictation & Speech**: Talk to your assistant and listen to answers completely offline.
- 📄 **Chat with Documents (RAG)**: Load local PDFs/text files to analyze without uploading them to cloud servers.
- 🔌 **Extensible Skills**: Add custom helper skills using open `SKILL.md` standard formats.
- 🌐 **Optional Web Search**: Toggle live internet web search with clickable inline sources when needed.

* **GitHub Repo**: https://github.com/PocketLLM/pocketllm-lite
* **Direct APK Download**: https://github.com/PocketLLM/pocketllm-lite/releases

I'd love for you to try it out and let me know your thoughts!
```

---

## 3. r/selfhosted

* **Subreddit Link**: [r/selfhosted](https://www.reddit.com/r/selfhosted/)
* **Direct Submit Link**: [Create Post on r/selfhosted](https://www.reddit.com/r/selfhosted/submit)
* **Required Flair**: `Self-Promotional` or `Software`

### Post Title:
```text
PocketLLM Lite – An open-source, ad-free Android companion client for self-hosted Ollama & LocalAI servers
```

### Post Body (Copy & Paste):
```markdown
Hey r/selfhosted,

If you run Ollama, LocalAI, or vLLM on your home server or homelab, I built **PocketLLM Lite** as a dedicated mobile client for Android.

### Highlights for Self-Hosters:
- **Flexible Endpoints**: Connect to your desktop/server Ollama instance via local IP, Tailscale, or WireGuard.
- **Offline Fallback**: Run smaller GGUF models directly on your phone when away from your home network.
- **Local Document Ingestion**: Local RAG vector DB processing PDFs and notes on your device.
- **DeepSeek R1 Thinking**: Full support for `<think>` reasoning accordion rendering.
- **Zero Cloud Telemetry**: MIT licensed, zero analytics, zero ads.

* **GitHub**: https://github.com/PocketLLM/pocketllm-lite
* **Release APKs**: https://github.com/PocketLLM/pocketllm-lite/releases
```

---

## 4. r/FlutterDev

* **Subreddit Link**: [r/FlutterDev](https://www.reddit.com/r/FlutterDev/)
* **Direct Submit Link**: [Create Post on r/FlutterDev](https://www.reddit.com/r/FlutterDev/submit)
* **Required Flair**: `Showcase`

### Post Title:
```text
How we built PocketLLM Lite: An open-source Flutter app for on-device GGUF inference, local RAG & Material 3 Expressive UI
```

### Post Body (Copy & Paste):
```markdown
Hi Flutter devs!

We recently open-sourced **PocketLLM Lite**, a privacy-first mobile AI client built with Flutter.

### Technical Architecture Highlights:
- **State Management**: Riverpod 3 (AsyncNotifier & StateNotifier providers).
- **Local Database**: Hive CE for high-performance binary storage of chat sessions and settings.
- **Streaming Pipeline**: Custom chunked HTTP stream parser with regex stream splitter for `<think>` tags and `<tool_call>` execution cards.
- **Agent Skills Architecture**: Open-standard `SKILL.md` loader with in-input cursor navigation and dynamic system prompt injection.
- **Design System**: Strict Material 3 implementation using `ColorScheme.fromSeed(#6750A4)`.

* **Source Code**: https://github.com/PocketLLM/pocketllm-lite
```

---

## 5. r/OpenSource

* **Subreddit Link**: [r/OpenSource](https://www.reddit.com/r/OpenSource/)
* **Direct Submit Link**: [Create Post on r/OpenSource](https://www.reddit.com/r/OpenSource/submit)
* **Required Flair**: `Project`

### Post Title:
```text
PocketLLM Lite: An open-source, privacy-first mobile LLM client (MIT License)
```

### Post Body (Copy & Paste):
```markdown
Hello r/OpenSource!

We've published **PocketLLM Lite**, an open-source mobile client for Android released under the permissive **MIT License**.

It enables running Large Language Models 100% offline or streaming from self-hosted Ollama servers without proprietary cloud dependencies, advertising SDKs, or data tracking.

* **GitHub Repository**: https://github.com/PocketLLM/pocketllm-lite
* **Release Download**: https://github.com/PocketLLM/pocketllm-lite/releases

Contributions, feature requests, and code reviews are welcome!
```
