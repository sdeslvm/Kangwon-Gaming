import SwiftUI
import WebKit

// MARK: - Протоколы и расширения

/// Протокол для создания градиентных представлений
protocol KangwonGradientProviding {
    func createKangwonGradientLayer() -> CAGradientLayer
}

// MARK: - Улучшенный контейнер с градиентом

/// Кастомный контейнер с градиентным фоном
final class KangwonGradientContainerView: UIView, KangwonGradientProviding {
    // MARK: - Приватные свойства
    
    private let kangwonGradientLayer = CAGradientLayer()
    
    // MARK: - Инициализаторы
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupKangwonView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupKangwonView()
    }
    
    // MARK: - Методы настройки
    
    private func setupKangwonView() {
        layer.insertSublayer(createKangwonGradientLayer(), at: 0)
    }
    
    /// Создание градиентного слоя
    func createKangwonGradientLayer() -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(hex: "#1BD8FD").cgColor,
            UIColor(hex: "#0FC9FA").cgColor
        ]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        return layer
    }
    
    // MARK: - Обновление слоя
    
    override func layoutSubviews() {
        super.layoutSubviews()
        kangwonGradientLayer.frame = bounds
    }
}

// MARK: - Расширения для цветов

extension UIColor {
    /// Инициализатор цвета из HEX-строки с улучшенной обработкой
    convenience init(hex kangwonHexString: String) {
        let sanitizedHex = kangwonHexString
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
            .uppercased()
        
        var colorValue: UInt64 = 0
        Scanner(string: sanitizedHex).scanHexInt64(&colorValue)
        
        let redComponent = CGFloat((colorValue & 0xFF0000) >> 16) / 255.0
        let greenComponent = CGFloat((colorValue & 0x00FF00) >> 8) / 255.0
        let blueComponent = CGFloat(colorValue & 0x0000FF) / 255.0
        
        self.init(red: redComponent, green: greenComponent, blue: blueComponent, alpha: 1.0)
    }
}

// MARK: - Представление веб-вида

struct KangwonWebViewBox: UIViewRepresentable {
    // MARK: - Свойства
    
    @ObservedObject var kangwonLoader: KangwonWebLoader
    
    // MARK: - Координатор
    
    func makeCoordinator() -> KangwonWebCoordinator {
        KangwonWebCoordinator { [weak kangwonLoader] status in
            DispatchQueue.main.async {
                kangwonLoader?.kangwonState = status
            }
        }
    }
    
    // MARK: - Создание представления
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = createKangwonWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        
        setupKangwonWebViewAppearance(webView)
        setupKangwonContainerView(with: webView)
        
        webView.navigationDelegate = context.coordinator
        kangwonLoader.attachKangwonWebView { webView }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Here you can update the WKWebView as needed, e.g., reload content when the loader changes.
        // For now, this can be left empty or you can update it as per loader's state if needed.
    }
    
    // MARK: - Приватные методы настройки
    
    private func createKangwonWebViewConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        return configuration
    }
    
    private func setupKangwonWebViewAppearance(_ webView: WKWebView) {
        webView.backgroundColor = .clear
        webView.isOpaque = false
    }
    
    private func setupKangwonContainerView(with webView: WKWebView) {
        let containerView = KangwonGradientContainerView()
        containerView.addSubview(webView)
        
        webView.frame = containerView.bounds
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    private func clearKangwonWebsiteData() {
        let dataTypes: Set<String> = [
            .diskCache,
            .memoryCache,
            .cookies,
            .localStorage
        ]
        
        WKWebsiteDataStore.default().removeData(
            ofTypes: dataTypes,
            modifiedSince: .distantPast
        ) {}
    }
}

// MARK: - Расширение для типов данных

extension String {
    static let diskCache = WKWebsiteDataTypeDiskCache
    static let memoryCache = WKWebsiteDataTypeMemoryCache
    static let cookies = WKWebsiteDataTypeCookies
    static let localStorage = WKWebsiteDataTypeLocalStorage
}

