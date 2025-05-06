

import SwiftUI
import UIKit
import AVFoundation

// MARK: - Game Models
enum GMPlayer: String {
    case x = "X"
    case o = "O"
    
    var color: Color {
        switch self {
        case .x: return Color.black
        case .o: return Color.white
        }
    }
    
    var next: GMPlayer {
        return self == .x ? .o : .x
    }
}

struct GMPosition: Hashable {
    let row: Int
    let col: Int
}

enum GMGameState: Equatable {
    case playing
    case win(GMPlayer)
    case draw
    
    var message: String {
        switch self {
        case .playing:
            return "Game in progress"
        case .win(let player):
            return "\(player.rawValue) Wins!"
        case .draw:
            return "Draw!"
        }
    }
    
    static func == (lhs: GMGameState, rhs: GMGameState) -> Bool {
        switch (lhs, rhs) {
        case (.playing, .playing):
            return true
        case (.draw, .draw):
            return true
        case (.win(let player1), .win(let player2)):
            return player1 == player2
        default:
            return false
        }
    }
}

// MARK: - Game Logic
class GomokuGameLogic: ObservableObject {
    let size: Int
    @Published var board: [[GMPlayer?]]
    @Published var currentPlayer: GMPlayer = .x
    @Published var gameState: GMGameState = .playing
    @Published var lastMove: GMPosition? = nil
    @Published var winningPositions: [GMPosition] = []
    @Published var moveCount = 0
    private var audioPlayer: AVAudioPlayer?
    
    init(size: Int = 15) {
        self.size = size
        self.board = Array(repeating: Array(repeating: nil, count: size), count: size)
        setupAudioPlayer()
    }
    
    private func setupAudioPlayer() {
        // In a real app, this would load sound files
    }
    
    func playSound(sound: String) {
        // In a real app, this would play sound effects
    }
    
    func handleTap(row: Int, col: Int) {
        guard gameState == .playing && board[row][col] == nil else { return }
        
        // Place the stone
        board[row][col] = currentPlayer
        lastMove = GMPosition(row: row, col: col)
        moveCount += 1
        playSound(sound: "stone")
        
        // Check game status
        if checkWin(for: currentPlayer, at: (row, col)) {
            gameState = .win(currentPlayer)
            playSound(sound: "win")
        } else if moveCount == size * size {
            gameState = .draw
            playSound(sound: "draw")
        } else {
            currentPlayer = currentPlayer.next
        }
    }
    
    func checkWin(for player: GMPlayer, at position: (Int, Int)) -> Bool {
        let directions = [(1, 0), (0, 1), (1, 1), (1, -1)] // vertical, horizontal, diagonals
        winningPositions = []
        
        for (dx, dy) in directions {
            var positions = [GMPosition(row: position.0, col: position.1)]
            
            // Check one direction
            for step in 1...4 {
                let r = position.0 + step * dx
                let c = position.1 + step * dy
                if r < size, c < size, r >= 0, c >= 0, board[r][c] == player {
                    positions.append(GMPosition(row: r, col: c))
                } else {
                    break
                }
            }
            
            // Check opposite direction
            for step in 1...4 {
                let r = position.0 - step * dx
                let c = position.1 - step * dy
                if r < size, c < size, r >= 0, c >= 0, board[r][c] == player {
                    positions.append(GMPosition(row: r, col: c))
                } else {
                    break
                }
            }
            
            if positions.count >= 5 {
                winningPositions = positions
                return true
            }
        }
        
        return false
    }
    
    func resetGame() {
        board = Array(repeating: Array(repeating: nil, count: size), count: size)
        currentPlayer = .x
        gameState = .playing
        lastMove = nil
        winningPositions = []
        moveCount = 0
        playSound(sound: "reset")
    }
}

// MARK: - UI Components
struct GMStoneView: View {
    let player: GMPlayer?
    let isWinningPosition: Bool
    let isLastMove: Bool
    let stoneSize: CGFloat
    
    @State private var scale: CGFloat = 0
    
    var body: some View {
        ZStack {
            if let player = player {
                Circle()
                    .fill(player.color)
                    .overlay(
                        Circle()
                            .stroke(
                                player == .x ? Color.black : Color.gray,
                                lineWidth: 1
                            )
                    )
                    .overlay(
                        Circle()
                            .stroke(isWinningPosition ? Color.green : (isLastMove ? Color.red : Color.clear),
                                   lineWidth: isWinningPosition ? 2 : (isLastMove ? 1.5 : 0))
                    )
                    .shadow(color: Color.black.opacity(0.3), radius: 1)
                    .scaleEffect(scale)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: scale)
                    .onAppear {
                        withAnimation {
                            scale = 1
                        }
                    }
            } else {
                Circle()
                    .fill(Color.clear)
            }
        }
        .frame(width: stoneSize, height: stoneSize)
    }
}

struct GMBoardCellView: View {
    let row: Int
    let col: Int
    let size: Int
    let cellSize: CGFloat
    let player: GMPlayer?
    let isWinningPosition: Bool
    let isLastMove: Bool
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            // Board cell background
            Rectangle()
                .fill(Color.yellow.opacity(0.7))
                .overlay(
                    GeometryReader { geometry in
                        Path { path in
                            // Horizontal line
                            path.move(to: CGPoint(x: 0, y: geometry.size.height / 2))
                            path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height / 2))
                            
                            // Vertical line
                            path.move(to: CGPoint(x: geometry.size.width / 2, y: 0))
                            path.addLine(to: CGPoint(x: geometry.size.width / 2, y: geometry.size.height))
                        }
                        .stroke(Color.black.opacity(0.7), lineWidth: 0.5)
                    }
                )
            
            // Special points (star points)
            if isStarPoint(row: row, col: col, size: size) {
                Circle()
                    .fill(Color.black)
                    .frame(width: 6, height: 6)
            }
            
            // Stone
            GMStoneView(
                player: player,
                isWinningPosition: isWinningPosition,
                isLastMove: isLastMove,
                stoneSize: cellSize * 0.85
            )
        }
        .frame(width: cellSize, height: cellSize)
        .onTapGesture(perform: onTap)
    }
    
    private func isStarPoint(row: Int, col: Int, size: Int) -> Bool {
        if size >= 13 {
            let starPositions: [Int] = [3, size / 2, size - 4]
            return starPositions.contains(row) && starPositions.contains(col)
        } else if size >= 9 {
            let starPositions: [Int] = [2, size / 2, size - 3]
            return starPositions.contains(row) && starPositions.contains(col)
        }
        return false
    }
}

struct GMPlayerTurnView: View {
    let currentPlayer: GMPlayer
    let gameState: GMGameState
    
    var body: some View {
        HStack(spacing: 16) {
            if case .win(let player) = gameState {
                Text("\(player.rawValue) Wins!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.green.opacity(0.2))
                    )
            } else if case .draw = gameState {
                Text("Draw!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.orange.opacity(0.2))
                    )
            } else {
                HStack {
                    Text("Current Player:")
                        .fontWeight(.medium)
                    
                    ZStack {
                        Circle()
                            .fill(currentPlayer.color)
                            .overlay(
                                Circle()
                                    .stroke(currentPlayer == .x ? Color.black : Color.gray, lineWidth: 1)
                            )
                            .frame(width: 24, height: 24)
                        
                        Text(currentPlayer.rawValue)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(currentPlayer == .x ? .white : .black)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Main Game View
struct GomokuView: View {
    @StateObject private var game: GomokuGameLogic
    @Environment(\.colorScheme) var colorScheme
    @State private var cellSize: CGFloat = 35
    
    init(size: Int = 15) {
        _game = StateObject(wrappedValue: GomokuGameLogic(size: size))
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.2) : Color(red: 0.95, green: 0.95, blue: 0.9),
                    colorScheme == .dark ? Color(red: 0.1, green: 0.1, blue: 0.15) : Color(red: 0.9, green: 0.9, blue: 0.8)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Header
                Text("GOMOKU")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.3, green: 0.3, blue: 0.1))
                    .padding(.top)
                
                // Game status
                GMPlayerTurnView(currentPlayer: game.currentPlayer, gameState: game.gameState)
                    .padding(.horizontal)
                
                // Board size slider
                HStack {
                    Text("Stone Size:")
                        .font(.subheadline)
                    
                    Slider(value: $cellSize, in: 25...45, step: 5)
                        .padding(.horizontal)
                }
                .padding(.horizontal)
                
                // Game board
                ScrollView([.horizontal, .vertical], showsIndicators: true) {
                    VStack(spacing: 0) {
                        ForEach(0..<game.size, id: \.self) { row in
                            HStack(spacing: 0) {
                                ForEach(0..<game.size, id: \.self) { col in
                                    GMBoardCellView(
                                        row: row,
                                        col: col,
                                        size: game.size,
                                        cellSize: cellSize,
                                        player: game.board[row][col],
                                        isWinningPosition: game.winningPositions.contains(where: { $0.row == row && $0.col == col }),
                                        isLastMove: game.lastMove?.row == row && game.lastMove?.col == col,
                                        onTap: {
                                            withAnimation {
                                                game.handleTap(row: row, col: col)
                                            }
                                        }
                                    )
                                }
                            }
                        }
                    }
                    .background(
                        Rectangle()
                            .stroke(Color.black, lineWidth: 1)
                    )
                    .background(Color.yellow.opacity(0.7))
                    .shadow(color: Color.black.opacity(0.3), radius: 5)
                    .padding(20)
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white.opacity(0.3))
                )
                .padding(.horizontal)
                
                // New Game button
                Button(action: {
                    withAnimation {
                        game.resetGame()
                    }
                }) {
                    Label("New Game", systemImage: "arrow.clockwise")
                        .font(.subheadline)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.bottom)
            }
            .padding()
        }
    }
}


