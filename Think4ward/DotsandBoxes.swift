import SwiftUI

struct ContentView: View {
    private let gridSize = 4
    private let dotSize: CGFloat = 12
    private let lineLength: CGFloat = 45
    
    @State private var horizontalLines = [Line: Int]()
    @State private var verticalLines = [Line: Int]()
    @State private var boxes = [Box]()
    @State private var currentPlayer = 1
    @State private var scores = [1: 0, 2: 0]
    @State private var gameOver = false
    @State private var lastPlacedLine: Line? = nil
    @State private var isLastPlacedHorizontal = false
    @State private var lastCompletedBoxes = [Box]()
    
    // Player colors
    private let player1Color = Color.blue
    private let player2Color = Color.red
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    colorScheme == .dark ? Color(red: 0.1, green: 0.1, blue: 0.2) : Color(red: 0.95, green: 0.97, blue: 1.0),
                    colorScheme == .dark ? Color(red: 0.05, green: 0.05, blue: 0.1) : Color(red: 0.85, green: 0.9, blue: 0.95)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Title
                Text("DOTS AND BOXES")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.1, green: 0.3, blue: 0.6))
                    .padding(.top)
                
                // Player scores
                HStack(spacing: 16) {
                    // Player 1 score
                    PlayerScoreView(
                        playerId: 1,
                        score: scores[1] ?? 0,
                        color: player1Color,
                        isCurrentPlayer: currentPlayer == 1 && !gameOver
                    )
                    
                    // Player 2 score
                    PlayerScoreView(
                        playerId: 2,
                        score: scores[2] ?? 0,
                        color: player2Color,
                        isCurrentPlayer: currentPlayer == 2 && !gameOver
                    )
                }
                .padding(.horizontal)
                
                // Game board
                ScrollView([.horizontal, .vertical], showsIndicators: false) {
                    VStack(spacing: 4) {
                        ForEach(0..<gridSize * 2 + 1, id: \.self) { row in
                            HStack(spacing: 4) {
                                ForEach(0..<gridSize * 2 + 1, id: \.self) { col in
                                    if row % 2 == 0 && col % 2 == 0 {
                                        // Dots
                                        Circle()
                                            .fill(Color.black)
                                            .frame(width: dotSize, height: dotSize)
                                            .shadow(color: .black.opacity(0.3), radius: 1)
                                    } else if row % 2 == 0 && col % 2 == 1 {
                                        // Horizontal Lines
                                        let line = Line(row: row, col: col)
                                        LineView(
                                            line: line,
                                            owner: horizontalLines[line],
                                            isHorizontal: true,
                                            isLastPlaced: lastPlacedLine == line && isLastPlacedHorizontal,
                                            player1Color: player1Color,
                                            player2Color: player2Color,
                                            lineLength: lineLength
                                        )
                                        .onTapGesture {
                                            withAnimation {
                                                handleTap(line, isHorizontal: true)
                                            }
                                        }
                                    } else if row % 2 == 1 && col % 2 == 0 {
                                        // Vertical Lines
                                        let line = Line(row: row, col: col)
                                        LineView(
                                            line: line,
                                            owner: verticalLines[line],
                                            isHorizontal: false,
                                            isLastPlaced: lastPlacedLine == line && !isLastPlacedHorizontal,
                                            player1Color: player1Color,
                                            player2Color: player2Color,
                                            lineLength: lineLength
                                        )
                                        .onTapGesture {
                                            withAnimation {
                                                handleTap(line, isHorizontal: false)
                                            }
                                        }
                                    } else {
                                        // Boxes
                                        let boxRow = row / 2
                                        let boxCol = col / 2
                                        if let box = boxes.first(where: { $0.row == boxRow && $0.col == boxCol }) {
                                            BoxView(
                                                box: box,
                                                isLastCompleted: lastCompletedBoxes.contains(where: { $0.id == box.id }),
                                                player1Color: player1Color,
                                                player2Color: player2Color,
                                                lineLength: lineLength
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white.opacity(0.5))
                            .shadow(color: colorScheme == .dark ? .black.opacity(0.5) : .gray.opacity(0.3),
                                   radius: 10, x: 0, y: 5)
                    )
                    .padding()
                }
                
                // Game status and color legend
                VStack(spacing: 12) {
                    // Game status
                    if gameOver {
                        Text(winnerText())
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(colorForWinner())
                            .padding(.vertical, 8)
                            .padding(.horizontal, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(colorForWinner().opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(colorForWinner().opacity(0.5), lineWidth: 1)
                                    )
                            )
                    }
                    
                    // Color legend
                    HStack(spacing: 20) {
                        ForEach([1, 2], id: \.self) { playerId in
                            HStack {
                                Rectangle()
                                    .fill(playerId == 1 ? player1Color : player2Color)
                                    .frame(width: 20, height: 4)
                                    .cornerRadius(2)
                                
                                Text("Player \(playerId)")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.1))
                    )
                }
                
                // Reset button
                Button(action: {
                    withAnimation {
                        resetGame()
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
        .onAppear {
            generateBoxes()
        }
    }
    
    // MARK: - Game Logic
    
    func handleTap(_ line: Line, isHorizontal: Bool) {
        guard !gameOver else { return }
        
        if isHorizontal {
            guard horizontalLines[line] == nil else { return }
            horizontalLines[line] = currentPlayer
            lastPlacedLine = line
            isLastPlacedHorizontal = true
        } else {
            guard verticalLines[line] == nil else { return }
            verticalLines[line] = currentPlayer
            lastPlacedLine = line
            isLastPlacedHorizontal = false
        }
        
        var claimedBox = false
        lastCompletedBoxes.removeAll()
        
        for i in boxes.indices {
            if boxes[i].isComplete(horizontalLines: horizontalLines, verticalLines: verticalLines),
               boxes[i].owner == nil {
                boxes[i].owner = currentPlayer
                scores[currentPlayer, default: 0] += 1
                claimedBox = true
                lastCompletedBoxes.append(boxes[i])
            }
        }
        
        if boxes.allSatisfy({ $0.owner != nil }) {
            gameOver = true
        }
        
        if !claimedBox {
            currentPlayer = currentPlayer == 1 ? 2 : 1
        }
    }
    
    func generateBoxes() {
        boxes = []
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                boxes.append(Box(row: row, col: col))
            }
        }
    }
    
    func resetGame() {
        horizontalLines = [:]
        verticalLines = [:]
        scores = [1: 0, 2: 0]
        currentPlayer = 1
        gameOver = false
        lastPlacedLine = nil
        lastCompletedBoxes.removeAll()
        generateBoxes()
    }
    
    func colorForLine(owner: Int?) -> Color {
        switch owner {
        case 1: return player1Color
        case 2: return player2Color
        default: return Color.gray.opacity(0.2)
        }
    }
    
    func colorForBox(owner: Int?) -> Color {
        switch owner {
        case 1: return player1Color.opacity(0.3)
        case 2: return player2Color.opacity(0.3)
        default: return Color.clear
        }
    }
    
    func colorForWinner() -> Color {
        if scores[1]! > scores[2]! {
            return player1Color
        } else if scores[2]! > scores[1]! {
            return player2Color
        } else {
            return .orange
        }
    }
    
    func winnerText() -> String {
        if scores[1]! > scores[2]! {
            return "Player 1 Wins!"
        } else if scores[2]! > scores[1]! {
            return "Player 2 Wins!"
        } else {
            return "It's a Tie!"
        }
    }
}

// MARK: - Models

struct Line: Hashable {
    let row: Int
    let col: Int
}

struct Box: Identifiable {
    let id = UUID()
    let row: Int
    let col: Int
    var owner: Int? = nil
    
    func isComplete(horizontalLines: [Line: Int], verticalLines: [Line: Int]) -> Bool {
        let top = Line(row: row * 2, col: col * 2 + 1)
        let bottom = Line(row: row * 2 + 2, col: col * 2 + 1)
        let left = Line(row: row * 2 + 1, col: col * 2)
        let right = Line(row: row * 2 + 1, col: col * 2 + 2)
        
        return horizontalLines[top] != nil &&
        horizontalLines[bottom] != nil &&
        verticalLines[left] != nil &&
        verticalLines[right] != nil
    }
}

// MARK: - UI Components

struct LineView: View {
    let line: Line
    let owner: Int?
    let isHorizontal: Bool
    let isLastPlaced: Bool
    let player1Color: Color
    let player2Color: Color
    let lineLength: CGFloat
    
    @State private var scale: CGFloat = 1.0
    
    var lineColor: Color {
        switch owner {
        case 1: return player1Color
        case 2: return player2Color
        default: return Color.gray.opacity(0.2)
        }
    }
    
    var body: some View {
        Rectangle()
            .fill(lineColor)
            .frame(
                width: isHorizontal ? lineLength : 4,
                height: isHorizontal ? 4 : lineLength
            )
            .cornerRadius(2)
            .shadow(color: owner != nil ? lineColor.opacity(0.5) : .clear, radius: isLastPlaced ? 3 : 0)
            .overlay(
                isLastPlaced && owner != nil ?
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color.yellow, lineWidth: 2) : nil
            )
            .scaleEffect(scale)
            .onChange(of: isLastPlaced) { newValue in
                if newValue {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        scale = 1.2
                    }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6).delay(0.1)) {
                        scale = 1.0
                    }
                }
            }
    }
}

struct BoxView: View {
    let box: Box
    let isLastCompleted: Bool
    let player1Color: Color
    let player2Color: Color
    let lineLength: CGFloat
    
    @State private var scale: CGFloat = 0
    
    var boxColor: Color {
        switch box.owner {
        case 1:
            return player1Color.opacity(0.3)
        case 2:
            return player2Color.opacity(0.3)
        default:
            return Color.clear
        }
    }
    
    var boxBorderColor: Color {
        switch box.owner {
        case 1:
            return player1Color
        case 2:
            return player2Color
        default:
            return Color.clear
        }
    }
    
    var body: some View {
        ZStack {
            if box.owner != nil {
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                boxColor.opacity(0.7),
                                boxColor.opacity(0.3)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(boxBorderColor.opacity(0.5), lineWidth: 1)
                    )
                    .scaleEffect(scale)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: scale)
                
                if let owner = box.owner {
                    Text("\(owner)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 1)
                }
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.clear)
            }
        }
        .frame(width: lineLength, height: lineLength)
        .onAppear {
            if box.owner != nil {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    scale = 1
                }
            }
        }
        .onChange(of: box.owner) { _ in
            if box.owner != nil {
                scale = 0
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    scale = 1
                }
            }
        }
    }
}

struct PlayerScoreView: View {
    let playerId: Int
    let score: Int
    let color: Color
    let isCurrentPlayer: Bool
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 16, height: 16)
            
            Text("Player \(playerId)")
                .fontWeight(.medium)
            
            Spacer()
            
            Text("\(score)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isCurrentPlayer ? color : Color.clear, lineWidth: 2)
                )
        )
        .scaleEffect(isCurrentPlayer ? 1.03 : 1.0)
        .animation(.spring(response: 0.3), value: isCurrentPlayer)
    }
}


