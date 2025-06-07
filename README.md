# Resource Users Addon
This is a Proof of Concept in the form of an inspector addon for issue https://github.com/godotengine/godot-proposals/issues/904 .

## Current status (07/06/2025)
The main resource (a material) is saved as a .tres and used exactly once in the whole project. The nested resource (a material in next pass) is also saved as a .tres, and it's used in the main resource (duh), in another node of the same scene of the main resource, and in another scene.
![immagine](https://github.com/user-attachments/assets/764d09d1-25b8-4e2a-b1a0-660dd9242422)

## What I'd like to do
- figure out how to build a "resource users database" in the .godot folder, so that it doesn't need to parse the whole project each time
- is it possible to show this as a symbol in the preview?
- maybe a popup that shows all the users if not unique? 

