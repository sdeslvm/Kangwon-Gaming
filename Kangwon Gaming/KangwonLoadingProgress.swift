import SwiftUI
import Combine
import WebKit

// MARK: - Протоколы

/// Протокол для управления состоянием веб-загрузки
protocol KangwonWebLoadable: AnyObject {
    var kangwonState: KangwonWebStatus { get set }
    func setKangwonConnectivity(_ available: Bool)
}

/// Протокол для мониторинга прогресса загрузки
protocol KangwonProgressMonitoring {
    func observeKangwonProgression()
    func monitorKangwon(_ webView: WKWebView)
}

// MARK: - Основной загрузчик веб-представления

/// Класс для управления загрузкой и состоянием веб-представления
final class KangwonWebLoader: NSObject, ObservableObject, KangwonWebLoadable, KangwonProgressMonitoring {
    // MARK: - Свойства
    
    @Published var kangwonState: KangwonWebStatus = .standby
    
    let kangwonResource: URL
    private var kangwonCancellables = Set<AnyCancellable>()
    private var kangwonProgressPublisher = PassthroughSubject<Double, Never>()
    private var kangwonWebViewProvider: (() -> WKWebView)?
    
    // MARK: - Инициализация
    
    init(kangwonResourceURL: URL) {
        self.kangwonResource = kangwonResourceURL
        super.init()
        observeKangwonProgression()
    }
    
    // MARK: - Публичные методы
    
    /// Привязка веб-представления к загрузчику
    func attachKangwonWebView(factory: @escaping () -> WKWebView) {
        kangwonWebViewProvider = factory
        triggerKangwonLoad()
    }
    
    /// Установка доступности подключения
    func setKangwonConnectivity(_ available: Bool) {
        switch (available, kangwonState) {
        case (true, .noConnection):
            triggerKangwonLoad()
        case (false, _):
            kangwonState = .noConnection
        default:
            break
        }
    }
    
    // MARK: - Приватные методы загрузки
    
    /// Запуск загрузки веб-представления
    private func triggerKangwonLoad() {
        guard let webView = kangwonWebViewProvider?() else { return }
        
        let request = URLRequest(url: kangwonResource, timeoutInterval: 12)
        kangwonState = .progressing(progress: 0)
        
        webView.navigationDelegate = self
        webView.load(request)
        monitorKangwon(webView)
    }
    
    // MARK: - Методы мониторинга
    
    /// Наблюдение за прогрессом загрузки
    func observeKangwonProgression() {
        kangwonProgressPublisher
            .removeDuplicates()
            .sink { [weak self] progress in
                guard let self else { return }
                self.kangwonState = progress < 1.0 ? .progressing(progress: progress) : .finished
            }
            .store(in: &kangwonCancellables)
    }
    
    /// Мониторинг прогресса веб-представления
    func monitorKangwon(_ webView: WKWebView) {
        webView.publisher(for: \.estimatedProgress)
            .sink { [weak self] progress in
                self?.kangwonProgressPublisher.send(progress)
            }
            .store(in: &kangwonCancellables)
    }
}

// MARK: - Расширение для обработки навигации

extension KangwonWebLoader: WKNavigationDelegate {
    /// Обработка ошибок при навигации
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        handleKangwonNavigationError(error)
    }
    
    /// Обработка ошибок при provisional навигации
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        handleKangwonNavigationError(error)
    }
    
    // MARK: - Приватные методы обработки ошибок
    
    /// Обобщенный метод обработки ошибок навигации
    private func handleKangwonNavigationError(_ error: Error) {
        kangwonState = .failure(reason: error.localizedDescription)
    }
}

// MARK: - Расширения для улучшения функциональности

extension KangwonWebLoader {
    /// Создание загрузчика с безопасным URL
    convenience init?(kangwonURLString: String) {
        guard let url = URL(string: kangwonURLString) else { return nil }
        self.init(kangwonResourceURL: url)
    }
}
