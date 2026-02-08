# Classic Snake Game

A minimalist, classic Snake game built with SwiftUI and SwiftData. The game focuses on the core loop: grid movement, growing snake, food spawning, scoring, game over, and restart.

## About
This project is a clean, modern SwiftUI implementation of the classic Snake experience. It uses deterministic game logic for reliable behavior and a simple, touch-friendly UI that also supports hardware keyboard controls.

## Features
- Grid-based snake movement with growth on food pickup
- Deterministic food spawning and scoring
- Game over on wall or self collision
- Pause/resume and restart controls
- Keyboard controls (Arrow keys or WASD)
- On-screen directional pad for touch devices

## Tech Stack
- SwiftUI (UI and rendering)
- SwiftData (project template; no persistence used for gameplay)
- Swift Concurrency (game tick loop)

## How to Run
1. Open `ClassicSnakeGameByCodex/ClassicSnakeGameByCodex.xcodeproj` in Xcode.
2. Select a simulator or device.
3. Run the app.

## Controls
- Keyboard: Arrow keys or WASD
- Touch: On-screen D-pad
- Buttons: Pause/Resume and Restart

## Manual Test Checklist
- Snake moves each tick and responds to direction changes.
- Food spawns within the grid and never on the snake.
- Score increases when food is eaten.
- Game ends on wall collision or self collision.
- Pause stops movement; Resume continues.
- Restart resets the game from any state.

## Screenshots
Screenshots can be added here. Suggested shots:
- Gameplay in progress
- Paused state
- Game Over state
