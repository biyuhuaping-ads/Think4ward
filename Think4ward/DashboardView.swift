
import SwiftUI

// Updated HowToPlayView that includes image assets
struct HowToPlayView: View {
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color.indigo.opacity(0.7), Color.purple.opacity(0.6)]),
                startPoint: animateGradient ? .topLeading : .bottomLeading,
                endPoint: animateGradient ? .bottomTrailing : .topTrailing
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.linear(duration: 5.0).repeatForever(autoreverses: true)) {
                    animateGradient.toggle()
                }
            }
            
            // Content area - fixed layout without scrolling
            VStack(alignment: .leading, spacing: 20) {
                // Header with glow effect
                VStack(spacing: 8) {
                    Text("Game Instructions")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .purple.opacity(0.5), radius: 10, x: 0, y: 5)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Text("Learn how to play all our games")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.top, 10)
                .padding(.bottom, 10)
                
                // Game cards grid - 2x2 layout
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    CompactInstructionCard(
                        title: "Tic Tac Toe",
                        description: "Classic 3×3 grid game",
                        imageName: "xmark.circle",
                        color: .green,
                        imageAsset: "TicTacToe" // Name of your image asset
                    )
                    
                    CompactInstructionCard(
                        title: "Connect Four",
                        description: "Connect 4 discs in a row",
                        imageName: "circle.grid.3x3.fill",
                        color: .blue,
                        imageAsset: "ConnectFour" // Name of your image asset
                    )
                    
                    CompactInstructionCard(
                        title: "Gomoku",
                        description: "Get 5 in a row to win",
                        imageName: "square.grid.3x3",
                        color: .orange,
                        imageAsset: "Gomoku" // Name of your image asset
                    )
                    
                    CompactInstructionCard(
                        title: "Dots & Boxes",
                        description: "Connect dots to form boxes",
                        imageName: "square.dashed",
                        color: .purple,
                        imageAsset: "DotsAndBoxes" // Name of your image asset
                    )
                }
                .padding(.horizontal, 10)
                
                Spacer()
                
                // Hint for selecting a card
                Text("Tap a game to see detailed instructions")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 10)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            UINavigationBar.appearance().tintColor = .white
        }
    }
}

// Compact card for the instruction overview screen
struct CompactInstructionCard: View {
    let title: String
    let description: String
    let imageName: String
    let color: Color
    let imageAsset: String? // Add this property
    
    // Add a default value for imageAsset so existing code doesn't break
    init(title: String, description: String, imageName: String, color: Color, imageAsset: String? = nil) {
        self.title = title
        self.description = description
        self.imageName = imageName
        self.color = color
        self.imageAsset = imageAsset
    }
    
    var body: some View {
        NavigationLink(destination: GameDetailView(
            title: title,
            description: description,
            imageName: imageName,
            color: color,
            imageAsset: imageAsset // Pass the imageAsset to GameDetailView
        )) {
            // Rest of the view remains the same
            VStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    // Either use asset image or system image
                    if let assetName = imageAsset {
                        Image(assetName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    } else {
                        Image(systemName: imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .foregroundColor(color)
                    }
                }
                
                // Title and description
                VStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(description)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 5)
            }
            .frame(height: 140)
            .padding(.vertical, 10)
            .padding(.horizontal, 5)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: color.opacity(0.2), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [color.opacity(0.5), color.opacity(0.2)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
        }
    }
}

// Updated Game Detail View with image support
struct GameDetailView: View {
    let title: String
    let description: String
    let imageName: String
    let color: Color
    let imageAsset: String?
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color.indigo.opacity(0.7), Color.purple.opacity(0.6)]),
                startPoint: animateGradient ? .topLeading : .bottomLeading,
                endPoint: animateGradient ? .bottomTrailing : .topTrailing
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.linear(duration: 5.0).repeatForever(autoreverses: true)) {
                    animateGradient.toggle()
                }
            }
            
            // Single game instruction card
            
            VStack {
                GameInstructionCard(
                    title: title,
                    description: description,
                    imageName: imageName,
                    color: color,
                    imageAsset: imageAsset,
                    instructions: getInstructions(for: title)
                )
                .padding()
            }
            
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Helper function to get the correct instructions based on the game title
    func getInstructions(for game: String) -> [String] {
        switch game {
        case "Tic Tac Toe":
            return [
                "Players take turns placing X or O on a 3×3 grid",
                "The first player to get 3 of their marks in a row (horizontally, vertically, or diagonally) wins",
                "If the grid fills up with no winner, the game is a draw",
                "Tap any empty cell to place your mark",
                "Use the Reset button to start a new game"
            ]
        case "Connect Four":
            return [
                "Players take turns dropping colored discs into a 7×6 grid",
                "Discs fall to the lowest available position in the column",
                "The first player to connect 4 discs of the same color in a row (horizontally, vertically, or diagonally) wins",
                "If the grid fills up with no winner, the game is a draw",
                "Tap any column to drop your disc",
                "Use the Reset button to start a new game"
            ]
        case "Gomoku":
            return [
                "Players take turns placing X or O on a 15×15 grid",
                "The first player to get exactly 5 of their marks in a row (horizontally, vertically, or diagonally) wins",
                "The board is much larger than Tic Tac Toe, allowing for more strategic gameplay",
                "You can scroll the board horizontally and vertically if needed",
                "Tap any empty cell to place your mark",
                "Use the Reset button to start a new game"
            ]
        case "Dots & Boxes":
            return [
                "Players take turns drawing lines between adjacent dots on a grid",
                "When a player completes the fourth side of a box, they claim that box and get another turn",
                "Player 1 is blue, Player 2 is red",
                "The player with the most boxes when the grid is filled wins",
                "Tap on the spaces between dots to draw lines",
                "Strategic play involves forcing your opponent to complete the third side of boxes",
                "Use the Reset button to start a new game"
            ]
        default:
            return ["Instructions not available for this game."]
        }
    }
}

// Update the existing GameInstructionCard to support images
struct GameInstructionCard: View {
    let title: String
    let description: String
    let imageName: String
    let color: Color
    let imageAsset: String?
    let instructions: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Header with icon or image
            HStack(spacing: 15) {
                // Icon with static design
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 70, height: 70)
                    
                    Circle()
                        .stroke(color.opacity(0.3), lineWidth: 2)
                        .frame(width: 70, height: 70)
                    
                    // Either use asset image or system image
                    if let assetName = imageAsset {
                        Image(assetName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                    } else {
                        Image(systemName: imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 34, height: 34)
                            .foregroundColor(color)
                    }
                }
                
                // Title and description
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(color)
                    
                    Text(description)
                        .font(.system(size: 16))
                        .foregroundColor(Color.primary.opacity(0.7))
                }
            }
            .padding(.bottom, 8)
            
            // Gradient divider
            LinearGradient(
                gradient: Gradient(colors: [color.opacity(0.7), color.opacity(0.2)]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 3)
            .cornerRadius(1.5)
            .padding(.bottom, 15)
            
            // Instructions with styled bullet points
            ForEach(instructions, id: \.self) { instruction in
                HStack(alignment: .top, spacing: 12) {
                    // Styled bullet point
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.2))
                            .frame(width: 18, height: 18)
                        
                        Image(systemName: "circle.fill")
                            .resizable()
                            .frame(width: 6, height: 6)
                            .foregroundColor(color)
                    }
                    .padding(.top, 4)
                    
                    Text(instruction)
                        .font(.system(size: 16))
                        .foregroundColor(Color.primary.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 5)
            }
        }
        .padding(25)
        .background(
            ZStack {
                // Main background
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                
                // Subtle gradient overlay
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.white, Color.white.opacity(0.95)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
        )
        .shadow(color: color.opacity(0.2), radius: 15, x: 0, y: 8)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [color.opacity(0.5), color.opacity(0.2)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
    }
}

struct DashboardView: View {
    @State private var animateGradient = false
    @State private var isNavigateToGames = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.6)]),
                    startPoint: animateGradient ? .topLeading : .bottomLeading,
                    endPoint: animateGradient ? .bottomTrailing : .topTrailing
                )
                .ignoresSafeArea()
                
                // Content
                VStack(spacing: 30) {
                    // Logo/Title Area with glow effect
                    VStack(spacing: 15) {
                        Text("Think4ward")
                            .font(.system(size: 46, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .purple.opacity(0.5), radius: 10, x: 0, y: 5)
                        
                        Text("Game Collection")
                            .font(.system(size: 24, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.bottom, 10)
                    }
                    .padding(.top, 40)
                    
                    // Game controller image with pulsing animation
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 170, height: 170)
                        
                        
                        Image("YourGameImageName")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 170, height: 170)
                    }
                    .padding(.bottom, 20)
                    
                    // Navigation Buttons with depth effect
                    VStack(spacing: 20) {
                        Button(action: {
                            showAdIfAvailable()  // 调用广告加载或展示
                        }) {
                            DashboardButton(
                                title: "Play Games",
                                systemImage: "gamecontroller",
                                gradient: Gradient(colors: [.green, .blue])
                            )
                        }
                        
                        NavigationLink(destination: GamesView(), isActive: $isNavigateToGames) {
                            EmptyView()
                        }
                        NavigationLink(destination: HowToPlayView()) {
                            DashboardButton(
                                title: "How to Play",
                                systemImage: "questionmark.circle",
                                gradient: Gradient(colors: [.orange, .red])
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Footer text
                    Text("© 2025 Think4ward Games")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.bottom, 10)
                }
                .padding()
            }
            .navigationBarHidden(true)
            .onAppear{
                InterstitialAdVC.shared.createInterstitialAd()
            }
//            .contentShape(Rectangle()) // 让整个区域可点击
//            .onTapGesture {
//                showAdIfAvailable()
//            }
        }
    }
    
    private func showAdIfAvailable() {
        print("👉 加载/展示广告")
        let adVC = InterstitialAdVC.shared
        adVC.showAdIfAvailable()
        adVC.onAdClick = {
            isNavigateToGames = true
        }
    }
}

// Enhanced button for dashboard
struct DashboardButton: View {
    let title: String
    let systemImage: String
    let gradient: Gradient
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: systemImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 28, height: 28)
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            ZStack {
                LinearGradient(
                    gradient: gradient,
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .cornerRadius(15)
                
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
            }
        )
        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
    }
}

// Enhanced Games view with professional styling and fixed layout
struct GamesView: View {
    @State private var animateGradient = false
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.indigo.opacity(0.6)]),
                startPoint: animateGradient ? .topLeading : .bottomLeading,
                endPoint: animateGradient ? .bottomTrailing : .topTrailing
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.linear(duration: 5.0).repeatForever(autoreverses: true)) {
                    animateGradient.toggle()
                }
            }
            
            // Content with fixed layout (no ScrollView)
            VStack(spacing: 25) {
                // Header with glow effect
                VStack(spacing: 10) {
                    Text("Game Collection")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .blue.opacity(0.5), radius: 10, x: 0, y: 5)
                    
                    Text("Select a game to play")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.top, 20)
                .padding(.bottom, 20)
                
                // Game Cards Grid - fixed 2x2 layout
                LazyVGrid(columns: columns, spacing: 20) {
                    EnhancedGameCard(
                        title: "Tic Tac Toe",
                        description: "Classic 3×3 grid game",
                        imageName: "xmark.circle",
                        imageAsset: "TicTacToe", // Use "TicTacToe" when you add it to assets
                        color: .green,
                        destination: TicTacToeView()
                    )
                    
                    EnhancedGameCard(
                        title: "Connect Four",
                        description: "Drop discs to connect 4 in a row",
                        imageName: "circle.grid.3x3.fill",
                        imageAsset: "ConnectFour", // Use "ConnectFour" when you add it to assets
                        color: .blue,
                        destination: ConnectFour()
                    )
                    
                    EnhancedGameCard(
                        title: "Gomoku",
                        description: "Get 5 in a row to win",
                        imageName: "square.grid.3x3",
                        imageAsset: "Gomoku", // Use "Gomoku" when you add it to assets
                        color: .orange,
                        destination: GomokuView()
                    )
                    
                    EnhancedGameCard(
                        title: "Dots & Boxes",
                        description: "Complete boxes by connecting dots",
                        imageName: "square.dashed",
                        imageAsset: "DotsAndBoxes" , // Use "DotsAndBoxes" when you add it to assets
                        color: .purple,
                        destination: ContentView()
                    )
                }
                .padding(.horizontal, 15)
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Hide the navigation bar title in favor of our custom one
            UINavigationBar.appearance().tintColor = .white
        }
    }
}

// Enhanced Game Card with support for custom images - static design
struct EnhancedGameCard<Destination: View>: View {
    let title: String
    let description: String
    let imageName: String
    let imageAsset: String? // Optional name of image in assets
    let color: Color
    let destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
            VStack(spacing: 15) {
                // Image area - will use asset image if provided, otherwise system image
                ZStack {
                    // Background circle
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 100, height: 100)
                    
                    // Either use asset image or system image
                    if let assetName = imageAsset {
                        Image(assetName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                    } else {
                        Image(systemName: imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .foregroundColor(color)
                    }
                }
                
                // Title and description
                VStack(spacing: 6) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 8)
            }
            .frame(minHeight: 180)
            .padding(.vertical, 15)
            .padding(.horizontal, 10)
            .background(
                ZStack {
                    // Main background
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                    
                    // Top highlight
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [color.opacity(0.2), Color.white.opacity(0.1)]),
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                }
            )
            .shadow(color: color.opacity(0.3), radius: 10, x: 0, y: 5)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [color.opacity(0.5), color.opacity(0.2)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
        }
    }
}
