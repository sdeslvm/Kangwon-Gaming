import SwiftUI
import Foundation

struct KangwonEntryScreen: View {
    @StateObject private var kangwonLoader: KangwonWebLoader

    init(kangwonLoader: KangwonWebLoader) {
        _kangwonLoader = StateObject(wrappedValue: kangwonLoader)
    }

    var body: some View {
        ZStack {
            KangwonWebViewBox(kangwonLoader: kangwonLoader)
                .opacity(kangwonLoader.kangwonState == .finished ? 1 : 0.5)
            switch kangwonLoader.kangwonState {
            case .progressing(let percent):
                KangwonProgressIndicator(kangwonValue: percent)
            case .failure(let err):
                KangwonErrorIndicator(kangwonErr: err)
            case .noConnection:
                KangwonOfflineIndicator()
            default:
                EmptyView()
            }
        }
    }
}

private struct KangwonProgressIndicator: View {
    let kangwonValue: Double
    var body: some View {
        GeometryReader { geo in
            KangwonLoadingOverlay(kangwonProgress: kangwonValue)
                .frame(width: geo.size.width, height: geo.size.height)
                .background(Color.black)
        }
    }
}

private struct KangwonErrorIndicator: View {
    let kangwonErr: String
    var body: some View {
        Text("Ошибка: \(kangwonErr)").foregroundColor(.red)
    }
}

private struct KangwonOfflineIndicator: View {
    var body: some View {
        Text("Нет соединения").foregroundColor(.gray)
    }
}
