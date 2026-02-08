//
//  SnakeGameView.swift
//  ClassicSnakeGameByCodex
//
//  Created by Codex.
//

import SwiftUI

struct SnakeGameView: View {
    @State private var game = SnakeGame()

    var body: some View {
        VStack(spacing: 16) {
            Text("Classic Snake")
                .font(.title2)
                .bold()

            Text("Score: \(game.state.score)")
                .font(.headline)

            GameBoardView(state: game.state)
                .overlay(alignment: .topTrailing) {
                    if game.state.isPaused {
                        Text("Paused")
                            .font(.caption)
                            .padding(6)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
                            .padding(8)
                    }
                }

            if game.state.isGameOver {
                Text("Game Over")
                    .font(.headline)
                    .foregroundStyle(.red)
            }

            HStack(spacing: 12) {
                Button(game.state.isPaused ? "Resume" : "Pause") {
                    game.togglePause()
                }
                .buttonStyle(.bordered)

                Button("Restart") {
                    game.restart()
                }
                .buttonStyle(.borderedProminent)
            }

            DirectionPad(
                onUp: { game.setDirection(.up) },
                onDown: { game.setDirection(.down) },
                onLeft: { game.setDirection(.left) },
                onRight: { game.setDirection(.right) }
            )

            Text("Use arrow keys or WASD")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.background)
        .overlay {
            KeyboardShortcutsView { direction in
                game.setDirection(direction)
            }
            .frame(width: 1, height: 1)
            .opacity(0.01)
        }
        .onAppear {
            game.start()
        }
        .onDisappear {
            game.stop()
        }
    }
}

struct GameBoardView: View {
    let state: SnakeGameState

    var body: some View {
        GeometryReader { proxy in
            let cellSize = min(
                proxy.size.width / CGFloat(state.cols),
                proxy.size.height / CGFloat(state.rows)
            )
            let boardSize = CGSize(
                width: cellSize * CGFloat(state.cols),
                height: cellSize * CGFloat(state.rows)
            )

            Canvas { context, _ in
                let background = Path(CGRect(origin: .zero, size: boardSize))
                context.fill(background, with: .color(.black.opacity(0.05)))

                let foodRect = CGRect(
                    x: CGFloat(state.food.x) * cellSize,
                    y: CGFloat(state.food.y) * cellSize,
                    width: cellSize,
                    height: cellSize
                )
                context.fill(Path(foodRect), with: .color(.red))

                for (index, segment) in state.snake.enumerated() {
                    let rect = CGRect(
                        x: CGFloat(segment.x) * cellSize,
                        y: CGFloat(segment.y) * cellSize,
                        width: cellSize,
                        height: cellSize
                    )
                    let color: Color = index == 0 ? .green : .green.opacity(0.8)
                    context.fill(Path(rect), with: .color(color))
                }

                let border = Path(CGRect(origin: .zero, size: boardSize))
                context.stroke(border, with: .color(.gray), lineWidth: 2)
            }
            .frame(width: boardSize.width, height: boardSize.height)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 320)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct DirectionPad: View {
    let onUp: () -> Void
    let onDown: () -> Void
    let onLeft: () -> Void
    let onRight: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Button(action: onUp) {
                Image(systemName: "chevron.up")
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.bordered)

            HStack(spacing: 16) {
                Button(action: onLeft) {
                    Image(systemName: "chevron.left")
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.bordered)

                Button(action: onDown) {
                    Image(systemName: "chevron.down")
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.bordered)

                Button(action: onRight) {
                    Image(systemName: "chevron.right")
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.bordered)
            }
        }
        .accessibilityLabel("Directional Controls")
    }
}

struct KeyboardShortcutsView: View {
    let onDirection: (SnakeDirection) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button("Up") { onDirection(.up) }
                .keyboardShortcut(.upArrow, modifiers: [])
            Button("Down") { onDirection(.down) }
                .keyboardShortcut(.downArrow, modifiers: [])
            Button("Left") { onDirection(.left) }
                .keyboardShortcut(.leftArrow, modifiers: [])
            Button("Right") { onDirection(.right) }
                .keyboardShortcut(.rightArrow, modifiers: [])

            Button("W") { onDirection(.up) }
                .keyboardShortcut("w", modifiers: [])
            Button("A") { onDirection(.left) }
                .keyboardShortcut("a", modifiers: [])
            Button("S") { onDirection(.down) }
                .keyboardShortcut("s", modifiers: [])
            Button("D") { onDirection(.right) }
                .keyboardShortcut("d", modifiers: [])
        }
    }
}

#Preview {
    SnakeGameView()
}
