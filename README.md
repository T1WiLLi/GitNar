# GitNar

> A cross-platform desktop app (Flutter & Dart) to sync SonarCloud issues into GitHub—seamlessly.

GitNar lets you connect your SonarCloud project to one or more GitHub repositories and projects. With its intuitive node-based workflow designer, you can automate issue creation, labeling, notifications, comment syncing, batch processing, and more—all without writing a single line of script.

## 🔥 Key Features

- **One-Click Issue Export**  
  Fetch open SonarCloud issues and file them in GitHub—automatically creating issues/cards in your repo & project boards.

- **Custom Label Management**  
  Create, map, and sync labels between SonarCloud issues and GitHub labels directly from the UI.

- **Node-Based Workflow Designer**  
  - **Trigger Nodes**: Start your workflow on scheduled intervals, webhook events, or manual runs.  
  - **Conditional Blocks**: Branch your flow based on issue severity, component, or custom metadata.  
  - **Action Nodes**:  
    - Create / update GitHub issues  
    - Post comments or notifications  
    - Sync GitHub ↔ Sonar comments  
    - Batch operations for bulk labeling or closing  

- **Notifications & Alerts**  
  Send desktop or email alerts when new critical issues appear, or when workflows succeed/fail.

- **Comment Synchronization**  
  Keep discussions in GitHub and SonarCloud in sync—any comment added on one side appears on the other.

- **Batch Processing**  
  Group multiple issues into a single workflow run—ideal for nightly clean-up or bulk updates.

- **Multi-Project Support**  
  Manage dozens of SonarCloud projects & GitHub repositories from one unified interface.

---

## 🛠️ Prerequisites

- **Flutter SDK** ≥ 3.0  
- **Dart SDK** ≥ 2.18  
- A valid **SonarCloud** account + token  
- **Github** is authenticated through OAuth2

---

## 🚀 Installation

1. **Clone the repository**  
   ```bash
   git clone https://github.com/your-org/GitNar.git
   cd GitNar
2. **Install dependencies**

	```bash
	flutter pub get
	```
3. **Run on Desktop**
	```bash
	flutter run -d windows   # Windows  
	flutter run -d macos     # macOS  
	flutter run -d linux     # Linux
	```
4. **Build a Release**

```bash
flutter build windows   # or macos, linux
```

## 🤝 Contributing
1. Fork the repo
2. Create a branch (git checkout -b feature/YourFeature)
3. Commit your changes (git commit -m "feat: add YourFeature")
4. Push to your branch (git push origin feature/YourFeature)
5. Open a Pull Request

📜 License
GitNar is released under the MIT License.
