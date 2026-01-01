#  VoiceCraft – AI-Powered Sign Language Translator

VoiceCraft is a Flutter-based accessibility application that enables real-time **gesture-to-text translation** to bridge communication gaps between sign language users and non-signers. The application leverages computer vision and AI to translate sign language gestures into readable text with near real-time feedback.

This project focuses on **accessibility, inclusivity, and real-time AI-driven interaction**.

---

## 🚀 Features

- **Real-Time Gesture Recognition**
  - Uses live camera feed to capture hand gestures.
  - Processes gestures continuously for smooth translation.

- **AI-Powered Translation**
  - Integrates **Gemini 2.5 Pro** for accurate gesture interpretation.
  - Converts recognized gestures into meaningful text output.

- **Accessible & Intuitive UI**
  - Clean Flutter-based interface.
  - Live camera preview with instant transcription feedback.

- **Dataset-Driven Learning**
  - Gesture definitions and annotations based on the **Indian Sign Language (ISL) Learning Book**.

---

## 🧠 System Architecture

Camera Input → Gesture Capture → AI Model (Gemini 2.5 Pro)  
→ Gesture Classification → Text Translation → UI Display

The application processes camera frames in real time, sends relevant gesture data to the AI model, and displays translated text directly in the user interface.

---

## 🛠️ Tech Stack

| Component | Technology |
|---------|------------|
| Mobile Framework | Flutter (Dart) |
| AI Model | Gemini 2.5 Pro |
| Camera Integration | Flutter Camera Plugin |
| Platform | Android / iOS |
| Dataset Reference | Indian Sign Language (ISL) Learning Book |

---

## ▶️ How to Run

### Prerequisites
- Flutter SDK (latest stable)
- Android Studio / VS Code
- Physical Android device or emulator
- Gemini API key

---

### Steps

1. Clone the repository:
   ```bash
   git clone <repository-url> <br/>
2.Navigate to the project directory. <br/>
3.Install Dependencies. <br/>
4.Configure API Keys. <br/>
5.Run the application. 
