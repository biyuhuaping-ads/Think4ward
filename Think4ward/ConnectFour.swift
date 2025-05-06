
import SwiftUI
import AVFoundation
import UIKit

// MARK: - Game Models
struct Disc: Identifiable {
    let id = UUID()
    let player: Player
}

enum Player: String {
    case red = "Red"
    case yellow = "Yellow"
    
    var color: Color {
        switch self {
        case .red: return Color.red
        case .yellow: return Color.yellow
        }
    }
    
    var next: Player {
        return self == .red ? .yellow : .red
    }
}

enum GameState: Equatable {
    case playing
    case win(Player)
    case draw
    
    var message: String {
        switch self {
        case .playing:
            return "Game in progress"
        case .win(let player):
            return "\(player.rawValue) Wins!"
        case .draw:
            return "Game Draw!"
        }
    }
    
    static func == (lhs: GameState, rhs: GameState) -> Bool {
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
class GameLogic: ObservableObject {
    static let ROWS = 6
    static let COLUMNS = 7
    static let CONNECT = 4
    
    @Published var board: [[Disc?]]
    @Published var currentPlayer: Player = .red
    @Published var gameState: GameState = .playing
    @Published var moveCount = 0
    @Published var lastMove: (row: Int, col: Int)? = nil
    @Published var winningCells: [(Int, Int)] = []
    
    private var audioPlayer: AVAudioPlayer?
    
    init() {
        board = Array(repeating: Array(repeating: nil, count: GameLogic.COLUMNS), count: GameLogic.ROWS)
        setupAudioPlayer()
    }
    
    private func setupAudioPlayer() {
        // In a real app, you would load your sound files here
        // Example:
        // if let soundURL = Bundle.main.url(forResource: "disc_drop", withExtension: "wav") {
        //     audioPlayer = try? AVAudioPlayer(contentsOf: soundURL)
        //     audioPlayer?.prepareToPlay()
        // }
    }
    
    func playSound(sound: String) {
        // In a real app, you would implement proper sound playing logic
        // Example:
        // if sound == "drop" {
        //     audioPlayer?.play()
        // }
    }
    
    func canDrop(in column: Int) -> Bool {
        guard gameState == .playing else { return false }
        return board[0][column] == nil
    }
    
    func dropDisc(in column: Int) {
        guard canDrop(in: column) else { return }
        
        // Find the lowest empty row
        for row in (0..<GameLogic.ROWS).reversed() {
            if board[row][column] == nil {
                // Place the disc
                let disc = Disc(player: currentPlayer)
                board[row][column] = disc
                lastMove = (row, column)
                moveCount += 1
                playSound(sound: "drop")
                
                // Check game status
                if checkWin(row: row, col: column) {
                    gameState = .win(currentPlayer)
                    playSound(sound: "win")
                } else if moveCount == GameLogic.ROWS * GameLogic.COLUMNS {
                    gameState = .draw
                    playSound(sound: "draw")
                } else {
                    currentPlayer = currentPlayer.next
                }
                
                break
            }
        }
    }
    
    func checkWin(row: Int, col: Int) -> Bool {
        guard let disc = board[row][col] else { return false }
        let player = disc.player
        
        // Directions: horizontal, vertical, diagonal (\), diagonal (/)
        let directions = [(0, 1), (1, 0), (1, 1), (1, -1)]
        
        for (dr, dc) in directions {
            var connectedCells = [(row, col)]
            
            // Check in positive direction
            for i in 1..<GameLogic.CONNECT {
                let newRow = row + i * dr
                let newCol = col + i * dc
                if isValid(row: newRow, col: newCol) &&
                   board[newRow][newCol]?.player == player {
                    connectedCells.append((newRow, newCol))
                } else {
                    break
                }
            }
            
            // Check in negative direction
            for i in 1..<GameLogic.CONNECT {
                let newRow = row - i * dr
                let newCol = col - i * dc
                if isValid(row: newRow, col: newCol) &&
                   board[newRow][newCol]?.player == player {
                    connectedCells.append((newRow, newCol))
                } else {
                    break
                }
            }
            
            if connectedCells.count >= GameLogic.CONNECT {
                winningCells = connectedCells
                return true
            }
        }
        
        return false
    }
    
    func isValid(row: Int, col: Int) -> Bool {
        return row >= 0 && row < GameLogic.ROWS && col >= 0 && col < GameLogic.COLUMNS
    }
    
    func resetGame() {
        board = Array(repeating: Array(repeating: nil, count: GameLogic.COLUMNS), count: GameLogic.ROWS)
        currentPlayer = .red
        gameState = .playing
        moveCount = 0
        lastMove = nil
        winningCells = []
    }
}

// MARK: - UI Components

struct DiscView: View {
    let disc: Disc?
    let isWinningCell: Bool
    let column: Int
    
    @State private var offset: CGFloat = -400
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.2))
            
            if let disc = disc {
                Circle()
                    .fill(disc.player.color)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                    .offset(y: offset)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: offset)
                    .onAppear {
                        offset = 0
                    }
            }
            
            if isWinningCell {
                Circle()
                    .stroke(Color.white, lineWidth: 3)
                    .shadow(color: .white, radius: 2)
            }
        }
    }
}

struct PlayerIndicatorView: View {
    let player: Player
    let isCurrentPlayer: Bool
    
    var body: some View {
        HStack {
            Circle()
                .fill(player.color)
                .frame(width: 20, height: 20)
            
            Text(player.rawValue)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isCurrentPlayer ? Color.gray.opacity(0.3) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCurrentPlayer ? player.color : Color.clear, lineWidth: 2)
        )
        .scaleEffect(isCurrentPlayer ? 1.1 : 1.0)
        .animation(.spring(response: 0.3), value: isCurrentPlayer)
    }
}

struct GameStatusView: View {
    let gameState: GameState
    let currentPlayer: Player
    
    var body: some View {
        VStack(spacing: 8) {
            if case .win(let player) = gameState {
                Text("\(player.rawValue) Wins!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(player.color)
            } else if case .draw = gameState {
                Text("Game Draw!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
            } else {
                HStack(spacing: 20) {
                    PlayerIndicatorView(player: .red, isCurrentPlayer: currentPlayer == .red)
                    PlayerIndicatorView(player: .yellow, isCurrentPlayer: currentPlayer == .yellow)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
    }
}

// MARK: - Main Game View
struct ConnectFour: View {
    @StateObject private var game = GameLogic()
    @State private var showGameRules = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    colorScheme == .dark ? Color(red: 0.1, green: 0.1, blue: 0.3) : Color(red: 0.8, green: 0.9, blue: 1.0),
                    colorScheme == .dark ? Color(red: 0.1, green: 0.1, blue: 0.2) : Color(red: 0.7, green: 0.8, blue: 0.9)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("CONNECT FOUR")
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.1, green: 0.3, blue: 0.6))
                    
                    GameStatusView(gameState: game.gameState, currentPlayer: game.currentPlayer)
                }
                .padding(.top)
                
                Spacer()
                
                // Game Board
                VStack(spacing: 8) {
                    // Column selection buttons - adjusted to match grid spacing
                    HStack(spacing: 6) {
                        ForEach(0..<GameLogic.COLUMNS, id: \.self) { col in
                            Button(action: {
                                if game.canDrop(in: col) {
                                    game.dropDisc(in: col)
                                }
                            }) {
                                Image(systemName: "arrow.down.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(game.canDrop(in: col) ? game.currentPlayer.color : Color.gray.opacity(0.3))
                                    .frame(maxWidth: .infinity)
                            }
                            .disabled(!game.canDrop(in: col))
                            .padding(.vertical, 2)
                        }
                    }
                    
                    // Board
                    ZStack {
                        // Board background
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.blue.opacity(0.8))
                            .shadow(color: colorScheme == .dark ? .black.opacity(0.5) : .gray.opacity(0.5),
                                   radius: 10, x: 0, y: 5)
                        
                        // Board grid - adapted to fit screen better
                        VStack(spacing: 6) {
                            ForEach(0..<GameLogic.ROWS, id: \.self) { row in
                                HStack(spacing: 6) {
                                    ForEach(0..<GameLogic.COLUMNS, id: \.self) { col in
                                        DiscView(
                                            disc: game.board[row][col],
                                            isWinningCell: game.winningCells.contains(where: { $0 == row && $1 == col }),
                                            column: col
                                        )
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .aspectRatio(1, contentMode: .fit)
                                    }
                                }
                            }
                        }
                        .padding(8)
                    }
                    .aspectRatio(7/6, contentMode: .fit)
                    .frame(maxWidth: UIScreen.main.bounds.width - 32)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // New Game button only (smaller)
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
            
            // Game rules sheet
            if showGameRules {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showGameRules = false
                    }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("How to Play")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        ruleItem(number: 1, text: "Players take turns dropping colored discs into the grid")
                        ruleItem(number: 2, text: "Red always goes first")
                        ruleItem(number: 3, text: "Discs fall to the lowest available position in the column")
                        ruleItem(number: 4, text: "First to connect four of their discs horizontally, vertically, or diagonally wins")
                        ruleItem(number: 5, text: "If the grid fills up without a winner, the game is a draw")
                    }
                    
                    Button(action: {
                        showGameRules = false
                    }) {
                        Text("Got it!")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(colorScheme == .dark ? Color(white: 0.2) : .white)
                        .shadow(radius: 20)
                )
                .frame(maxWidth: 350)
                .padding(24)
                .transition(.scale)
            }
        }
    }
    
    private func ruleItem(number: Int, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .fontWeight(.bold)
                .padding(8)
                .background(Circle().fill(Color.blue))
                .foregroundColor(.white)
            
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}


