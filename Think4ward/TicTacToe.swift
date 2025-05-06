
import SwiftUI
import UIKit

// MARK: - Game Models
enum TTTPlayer: String {
    case x = "X"
    case o = "O"
    
    var color: Color {
        switch self {
        case .x: return Color.blue
        case .o: return Color.red
        }
    }
    
    var next: TTTPlayer {
        return self == .x ? .o : .x
    }
}

enum TTTGameState: Equatable {
    case playing
    case win(TTTPlayer)
    case draw
    
    var message: String {
        switch self {
        case .playing:
            return "Game in progress"
        case .win(let player):
            return "\(player.rawValue) Wins!"
        case .draw:
            return "It's a Draw!"
        }
    }
    
    static func == (lhs: TTTGameState, rhs: TTTGameState) -> Bool {
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
class TicTacToeGameLogic: ObservableObject {
    @Published var board: [TTTPlayer?] = Array(repeating: nil, count: 9)
    @Published var currentPlayer: TTTPlayer = .x
    @Published var gameState: TTTGameState = .playing
    @Published var winningPattern: [Int] = []
    @Published var moveCount = 0
    @Published var lastMove: Int? = nil
    
    let winPatterns = [
        [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
        [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
        [0, 4, 8], [2, 4, 6]             // diagonals
    ]
    
    func handleMove(_ index: Int) {
        guard gameState == .playing && board[index] == nil else { return }
        
        // Place the move
        board[index] = currentPlayer
        lastMove = index
        moveCount += 1
        
        // Check game status
        if checkWin(for: currentPlayer) {
            gameState = .win(currentPlayer)
        } else if moveCount == 9 {
            gameState = .draw
        } else {
            currentPlayer = currentPlayer.next
        }
    }
    
    func checkWin(for player: TTTPlayer) -> Bool {
        for pattern in winPatterns {
            if pattern.allSatisfy({ board[$0] == player }) {
                winningPattern = pattern
                return true
            }
        }
        return false
    }
    
    func resetGame() {
        board = Array(repeating: nil, count: 9)
        currentPlayer = .x
        gameState = .playing
        winningPattern = []
        moveCount = 0
        lastMove = nil
    }
}

// MARK: - UI Components
struct TTTCellView: View {
    let index: Int
    let value: TTTPlayer?
    let isWinningCell: Bool
    let onTap: () -> Void
    
    @State private var scale: CGFloat = 0
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(isWinningCell ? Color.yellow.opacity(0.3) : Color.blue.opacity(0.1))
                .shadow(color: isWinningCell ? Color.yellow.opacity(0.5) : Color.blue.opacity(0.2), radius: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isWinningCell ? Color.yellow : Color.blue.opacity(0.3), lineWidth: isWinningCell ? 3 : 1)
                )
            
            if let player = value {
                Group {
                    if player == .x {
                        TTTXView()
                            .foregroundColor(TTTPlayer.x.color)
                    } else {
                        TTTOView()
                            .foregroundColor(TTTPlayer.o.color)
                    }
                }
                .scaleEffect(scale)
                .rotationEffect(.degrees(rotation))
                .onAppear {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                        scale = 1
                        rotation = 0
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .onTapGesture(perform: onTap)
        .onChange(of: value) { _ in
            if value != nil {
                scale = 0
                rotation = -90
                withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                    scale = 1
                    rotation = 0
                }
            }
        }
    }
}

struct TTTXView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.clear)
                .frame(width: 10)
                .rotationEffect(.degrees(45))
            
            Rectangle()
                .fill(Color.clear)
                .frame(width: 10)
                .rotationEffect(.degrees(-45))
        }
        .frame(width: 40, height: 40)
        .overlay(
            Image(systemName: "xmark")
                .font(.system(size: 40, weight: .bold))
        )
    }
}

struct TTTOView: View {
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 10)
                .frame(width: 40, height: 40)
        }
    }
}

struct TTTGameStatusView: View {
    let gameState: TTTGameState
    let currentPlayer: TTTPlayer
    
    var body: some View {
        VStack(spacing: 8) {
            if case .win(let player) = gameState {
                Text("\(player.rawValue) Wins!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(player.color)
                    .padding(.vertical, 4)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(player == .x ? Color.blue.opacity(0.2) : Color.red.opacity(0.2))
                    )
            } else if case .draw = gameState {
                Text("It's a Draw!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                    .padding(.vertical, 4)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.orange.opacity(0.2))
                    )
            } else {
                HStack {
                    Text("Current Player:")
                        .fontWeight(.medium)
                    
                    if currentPlayer == .x {
                        Text("X")
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.blue.opacity(0.2))
                            )
                    } else {
                        Text("O")
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.red.opacity(0.2))
                            )
                    }
                }
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.1))
                )
            }
        }
    }
}

// MARK: - Main Game View
struct TicTacToeView: View {
    @StateObject private var game = TicTacToeGameLogic()
    @Environment(\.colorScheme) var colorScheme
    
    let gridItemLayout = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    colorScheme == .dark ? Color(red: 0.1, green: 0.1, blue: 0.3) : Color(red: 0.9, green: 0.95, blue: 1.0),
                    colorScheme == .dark ? Color(red: 0.1, green: 0.1, blue: 0.2) : Color(red: 0.85, green: 0.9, blue: 0.95)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 4) {
                    Text("TIC TAC TOE")
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.1, green: 0.3, blue: 0.6))
                    
                    // Game status
                    TTTGameStatusView(gameState: game.gameState, currentPlayer: game.currentPlayer)
                }
                .padding(.top)
                
                Spacer()
                
                // Game board
                LazyVGrid(columns: gridItemLayout, spacing: 12) {
                    ForEach(0..<9, id: \.self) { index in
                        TTTCellView(
                            index: index,
                            value: game.board[index],
                            isWinningCell: game.winningPattern.contains(index),
                            onTap: {
                                withAnimation {
                                    game.handleMove(index)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)
                .frame(maxWidth: 380) // Limit max width for larger screens
                
                Spacer()
                
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

