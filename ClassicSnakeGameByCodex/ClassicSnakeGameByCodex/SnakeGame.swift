//
//  SnakeGame.swift
//  ClassicSnakeGameByCodex
//
//  Created by Codex.
//

import Foundation
import Observation

struct GridPoint: Hashable {
    let x: Int
    let y: Int
}

enum SnakeDirection: CaseIterable {
    case up
    case down
    case left
    case right

    var vector: GridPoint {
        switch self {
        case .up: return GridPoint(x: 0, y: -1)
        case .down: return GridPoint(x: 0, y: 1)
        case .left: return GridPoint(x: -1, y: 0)
        case .right: return GridPoint(x: 1, y: 0)
        }
    }

    func isOpposite(of other: SnakeDirection) -> Bool {
        switch (self, other) {
        case (.up, .down), (.down, .up), (.left, .right), (.right, .left):
            return true
        default:
            return false
        }
    }
}

struct LCRNG: RandomNumberGenerator {
    var state: UInt64

    init(seed: UInt64) {
        self.state = seed == 0 ? 0x4d595df4d0f33173 : seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1
        return state
    }

    mutating func nextInt(upperBound: Int) -> Int {
        Int(next() % UInt64(upperBound))
    }
}

struct SnakeGameState {
    let rows: Int
    let cols: Int

    private(set) var snake: [GridPoint]
    private(set) var direction: SnakeDirection
    private(set) var food: GridPoint
    private(set) var score: Int
    private(set) var isGameOver: Bool
    private(set) var isPaused: Bool

    private var pendingDirection: SnakeDirection?
    private var rng: LCRNG

    init(rows: Int, cols: Int, seed: UInt64) {
        self.rows = rows
        self.cols = cols

        let midX = cols / 2
        let midY = rows / 2
        self.snake = [
            GridPoint(x: midX, y: midY),
            GridPoint(x: midX - 1, y: midY),
            GridPoint(x: midX - 2, y: midY)
        ]
        self.direction = .right
        self.score = 0
        self.isGameOver = false
        self.isPaused = false
        self.pendingDirection = nil
        self.rng = LCRNG(seed: seed)
        self.food = GridPoint(x: 0, y: 0)
        self.food = spawnFood()
    }

    mutating func reset(seed: UInt64) {
        self = SnakeGameState(rows: rows, cols: cols, seed: seed)
    }

    mutating func queueDirection(_ newDirection: SnakeDirection) {
        guard !direction.isOpposite(of: newDirection) else { return }
        pendingDirection = newDirection
    }

    mutating func togglePause() {
        isPaused.toggle()
    }

    mutating func step() {
        guard !isGameOver, !isPaused else { return }

        if let pending = pendingDirection, !direction.isOpposite(of: pending) {
            direction = pending
        }
        pendingDirection = nil

        let head = snake[0]
        let movement = direction.vector
        let newHead = GridPoint(x: head.x + movement.x, y: head.y + movement.y)

        if newHead.x < 0 || newHead.x >= cols || newHead.y < 0 || newHead.y >= rows {
            isGameOver = true
            return
        }

        if snake.contains(newHead) {
            isGameOver = true
            return
        }

        snake.insert(newHead, at: 0)

        if newHead == food {
            score += 1
            food = spawnFood()
        } else {
            snake.removeLast()
        }
    }

    private mutating func spawnFood() -> GridPoint {
        let total = rows * cols
        if snake.count >= total {
            return GridPoint(x: 0, y: 0)
        }

        var candidate: GridPoint
        repeat {
            let index = rng.nextInt(upperBound: total)
            candidate = GridPoint(x: index % cols, y: index / cols)
        } while snake.contains(candidate)

        return candidate
    }
}

@MainActor
@Observable
final class SnakeGame {
    private(set) var state: SnakeGameState
    private(set) var isRunning: Bool = false

    private let tickIntervalNanoseconds: UInt64
    private var tickTask: Task<Void, Never>?

    init(rows: Int = 20, cols: Int = 20, seed: UInt64? = nil, tickIntervalSeconds: Double = 0.18) {
        let resolvedSeed = seed ?? UInt64(Date().timeIntervalSince1970 * 1000)
        self.state = SnakeGameState(rows: rows, cols: cols, seed: resolvedSeed)
        self.tickIntervalNanoseconds = UInt64(tickIntervalSeconds * 1_000_000_000)
    }

    func start() {
        guard tickTask == nil else {
            isRunning = true
            return
        }
        isRunning = true
        tickTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: self.tickIntervalNanoseconds)
                if self.isRunning {
                    self.state.step()
                }
            }
        }
    }

    func stop() {
        tickTask?.cancel()
        tickTask = nil
        isRunning = false
    }

    func restart() {
        let newSeed = UInt64(Date().timeIntervalSince1970 * 1000)
        state.reset(seed: newSeed)
        isRunning = true
    }

    func togglePause() {
        state.togglePause()
    }

    func setDirection(_ direction: SnakeDirection) {
        state.queueDirection(direction)
    }
}
