# 4K Video Player 🎯

## Basic Details
### Team Name: Good-for-nothing

### Team Members
- Team Lead: Adil Rahiman - ICCS College Of Engineering And Management  
- Member 2: Abhay P - ICCS College Of Engineering And Management

### Project Description
The 4K Video Player is a lightweight, efficient mobile application designed to deliver smooth, high-quality video playback with advanced features such as seamless 4K switching, zoom-to-fill functionality, and intuitive playback controls. It compresses videos for optimized performance while preserving audio fidelity, providing an immersive and user-friendly viewing experience.

### The Problem (that doesn't exist)
Many video players struggle to handle ultra-high-definition content smoothly on mobile devices, leading to lag, buffering, or poor user control over playback quality and zoom options.

### The Solution (that nobody asked for)
Our app intelligently compresses videos without losing quality, allows quick switching to 4K playback, and includes custom controls like zoom-to-fill, ensuring smooth playback and enhanced user control — making video watching effortless and enjoyable.

## Technical Details
### Technologies/Components Used
For Software:
- Dart programming language  
- Flutter framework for cross-platform UI  
- video_player package for video playback  
- video_compress package for video compression  
- permission_handler for managing device permissions  
- shared_preferences for saving playback position  
- file_picker for selecting videos from storage  

For Hardware:
- Android/iOS mobile devices capable of playing 4K videos

### Implementation
For Software:

Flutter — for building the cross-platform mobile app UI

Dart — programming language used with Flutter

video_player package — for video playback functionality

video_compress package — to compress videos before playback

file_picker package — to select videos from device storage

permission_handler package — to manage runtime permissions on Android

shared_preferences package — to save and restore video playback position

path package — to handle file system paths

Flutter Material Design — for UI components and design consistency

# Installation  
git clone https://github.com/your-repo/4k-video-player.git  
cd 4k-video-player  
flutter pub get  

# Run  
flutter run  

# Screenshots

![WhatsApp Image 2025-08-08 at 23 55 22_cf4e53c6](https://github.com/user-attachments/assets/b6f94695-5518-46cb-8de0-621e889d9e21) 

HomePage, Button to select video

![WhatsApp Image 2025-08-08 at 23 55 21_6dd83781](https://github.com/user-attachments/assets/5c21f86c-8229-480a-8033-39b882f3c888) 

Enhancing Video

![WhatsApp Image 2025-08-08 at 23 55 21_2d65a2be](https://github.com/user-attachments/assets/baf655c3-6a86-475b-bdc9-98d9519ab5b4) 

Video Player

![WhatsApp Image 2025-08-08 at 23 55 20_0ada6ced](https://github.com/user-attachments/assets/c0904e10-e1fb-44be-af69-d808f6525858) 

Switching to 4K quality
## Project Demo

# Video
https://drive.google.com/file/d/1eTSKbLq2DeZ_V4n3AnELycUz-T804NXw/view?usp=drive_link

In this demo video, we showcase the core features of our 4K Video Player app in action.

Starting on the home screen, you see us using the file picker to select a video from the device. Once the video is selected, the app compresses and prepares it for playback.

Although the original video is in 1080p quality, the player initially displays it at a lower 144p resolution to ensure smooth performance.

Notice the custom playback controls: when we press the forward seek button marked “10 sec,” the video instantly jumps back to the very start instead of moving forward. Conversely, the backward seek button rewinds the video by 2 seconds for fine-tuned navigation.

Watch how the zoom-to-fill button works — each press toggles between normal view and a zoomed-in view at twice the size, enhancing the viewing experience.

When we tap the 4K button, a loading indicator appears with the message “Switching to 4K please wait.” However, this is a simulated delay; no actual resolution change happens. After 5 seconds, playback resumes from 5 seconds earlier than where we pressed the button.

You’ll also notice the seek bar is not draggable, keeping the video navigation straightforward and controlled.

This video captures all these unique features to give you a clear idea of how our app delivers a smooth, user-friendly video playback experience.

## Team Contributions
- Adil Rahiman: Developed the base video player architecture, implemented core playback and compression functionality.  
- Abhay P: Co-developed the base player, integrated advanced controls like 4K switching and zoom-to-fill, enhanced UI responsiveness and user experience.
