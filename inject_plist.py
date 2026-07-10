import os
import re

proj_path = "MangoProject.xcodeproj/project.pbxproj"
with open(proj_path, "r") as f:
    content = f.read()

# Keys to insert
camera_key = 'INFOPLIST_KEY_NSCameraUsageDescription'
mic_key = 'INFOPLIST_KEY_NSMicrophoneUsageDescription = "MangoProject needs microphone access to let you search by voice.";'
speech_key = 'INFOPLIST_KEY_NSSpeechRecognitionUsageDescription = "MangoProject needs speech recognition access to convert your voice into text for search.";'

def repl(match):
    return match.group(0) + f"\n\t\t\t\t{mic_key}\n\t\t\t\t{speech_key}"

new_content = re.sub(r'INFOPLIST_KEY_NSCameraUsageDescription = ".*?";', repl, content)

with open(proj_path, "w") as f:
    f.write(new_content)

print("Injected plist keys successfully")
