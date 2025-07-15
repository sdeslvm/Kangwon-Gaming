import SwiftUI

// MARK: - Протоколы для улучшения расширяемости

protocol KangwonProgressDisplayable {
    var kangwonProgressPercentage: Int { get }
}

protocol KangwonBackgroundProviding {
    associatedtype KangwonBackgroundContent: View
    func makeKangwonBackground() -> KangwonBackgroundContent
}

// MARK: - Расширенная структура загрузки

struct KangwonLoadingOverlay<KangwonBackground: View>: View, KangwonProgressDisplayable {
    let kangwonProgress: Double
    let kangwonBackgroundView: KangwonBackground
    
    var kangwonProgressPercentage: Int { Int(kangwonProgress * 100) }
    
    init(kangwonProgress: Double, @ViewBuilder kangwonBackground: () -> KangwonBackground) {
        self.kangwonProgress = kangwonProgress
        self.kangwonBackgroundView = kangwonBackground()
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                kangwonBackgroundView
                VStack(spacing: 32) {
                    Spacer()
                    Text("Kangwon")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#1BD8FD"))
                        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                    Text("Loading \(kangwonProgressPercentage)%")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                        .shadow(radius: 1)
                    KangwonProgressBar(kangwonValue: kangwonProgress)
                        .frame(width: geo.size.width * 0.6, height: 12)
                        .padding(.top, 8)
                    Spacer()
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

// MARK: - Фоновые представления

extension KangwonLoadingOverlay where KangwonBackground == KangwonBackgroundView {
    init(kangwonProgress: Double) {
        self.init(kangwonProgress: kangwonProgress) { KangwonBackgroundView() }
    }
}

struct KangwonBackgroundView: View, KangwonBackgroundProviding {
    func makeKangwonBackground() -> some View {
        LinearGradient(
            gradient: Gradient(colors: [Color(hex: "#373c56"), Color(hex: "#1BD8FD")]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    var body: some View {
        makeKangwonBackground()
    }
}

// MARK: - Индикатор прогресса с анимацией

struct KangwonProgressBar: View {
    let kangwonValue: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white.opacity(0.15))
                    .frame(height: geometry.size.height)
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(hex: "#F3D614"))
                    .frame(width: CGFloat(kangwonValue) * geometry.size.width, height: geometry.size.height)
                    .animation(.linear(duration: 0.2), value: kangwonValue)
            }
        }
    }
}

// MARK: - Превью

#Preview("Kangwon Loading") {
    KangwonLoadingOverlay(kangwonProgress: 0.42)
}

