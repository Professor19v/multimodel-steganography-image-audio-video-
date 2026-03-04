# 🛡️ Multimodal Steganography Dashboard

A MATLAB-based Wizard for hiding secret messages in Images, Audio, and Video files using LSB (Least Significant Bit) encoding and **MLEA (Modified Lightweight Encryption Algorithm)**.

## 📋 Requirements
To run this application, you must have **MATLAB (R2020b or later)** installed along with the following toolboxes:
* **Image Processing Toolbox**
* **Audio Toolbox**
* **Computer Vision Toolbox**

## 🚀 How to Run
1. Open MATLAB.
2. Navigate to the folder containing `wizard_steganography_dashboard.m`.
3. Type `wizard_steganography_dashboard` in the Command Window and press Enter.

## 🛠️ Features
- **Sender Mode:** Load a cover file, encrypt a text message, and save the stego-file.
- **Receiver Mode:** Load a stego-file and extract the hidden message.
- **Security:** Uses a custom bit-shaping and XOR-based encryption (MLEA) before hiding data.
- **Multi-Format Support:** - 🖼️ **Images:** `.png`, `.jpg`, `.bmp`
  - 🎵 **Audio:** `.wav`
  - 🎥 **Video:** `.mp4`, `.avi`
