import Foundation
import SwiftUI

struct KangwonColorUtility {
    static func kangwonConvertToColor(hexRepresentation kangwonHexString: String) -> Color {
        let sanitizedHex = kangwonHexString.trimmingCharacters(in: .alphanumerics.inverted)
        var colorValue: UInt64 = 0
        Scanner(string: sanitizedHex).scanHexInt64(&colorValue)
        
        
        
        
        
        
        let redComponent = Double((colorValue & 0xFF0000) >> 16) / 255.0
        let greenComponent = Double((colorValue & 0x00FF00) >> 8) / 255.0
        let blueComponent = Double(colorValue & 0x0000FF) / 255.0
        
        return Color(red: redComponent, green: greenComponent, blue: blueComponent)
    }
    
    static func kangwonConvertToUIColor(hexRepresentation kangwonHexString: String) -> UIColor {
        let sanitizedHex = kangwonHexString.trimmingCharacters(in: .alphanumerics.inverted)
        var colorValue: UInt64 = 0
        Scanner(string: sanitizedHex).scanHexInt64(&colorValue)
        
        let redComponent = CGFloat((colorValue & 0xFF0000) >> 16) / 255.0
        let greenComponent = CGFloat((colorValue & 0x00FF00) >> 8) / 255.0
        let blueComponent = CGFloat(colorValue & 0x0000FF) / 255.0
        
        return UIColor(red: redComponent, green: greenComponent, blue: blueComponent, alpha: 1.0)
    }
}

struct KangwonGameInitialView: View {
    private var kangwonGameResourceURL: URL { URL(string: "https://kanggplay.top/get")! }
    
    var body: some View {
        ZStack {
            Color(hex: "#000")
                .ignoresSafeArea()
            KangwonEntryScreen(kangwonLoader: .init(kangwonResourceURL: kangwonGameResourceURL))
        }
    }
}

#Preview {
    KangwonGameInitialView()
}

extension Color {
    init(hex kangwonHexValue: String) {
        let sanitizedHex = kangwonHexValue.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        var colorValue: UInt64 = 0
        Scanner(string: sanitizedHex).scanHexInt64(&colorValue)
        
        self.init(
            .sRGB,
            red: Double((colorValue >> 16) & 0xFF) / 255.0,
            green: Double((colorValue >> 8) & 0xFF) / 255.0,
            blue: Double(colorValue & 0xFF) / 255.0,
            opacity: 1.0
        )
    }
}
