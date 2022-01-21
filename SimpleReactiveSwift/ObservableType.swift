//
//  ObservableType.swift
//  SimpleReactiveSwift
//
//  Created by 전여훈 on 2022/01/21.
//

import Foundation

protocol ObservableType: ObservableContertibleType {
    associatedtype Element
    func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable  where Observer.Element == Element
}

extension ObservableType {
    public static func create(_ subscribe: @escaping (AnyObserver<Element>) -> Disposable) -> Observable<Element> {
        return AnonymousObservable(subscribe)
    }
}

extension ObservableType {
    func subscribe(
        onNext: ((Element) -> Void)? = nil,
        onError: ((Swift.Error) -> Void)? = nil,
        onCompleted: (() -> Void)? = nil,
        onDisposed: (() -> Void)? = nil
    ) -> Disposable {
        let disposable: Disposable
        
        disposable = Disposables.create()
        
        let observer = AnonymousObserver<Element> { event in
            switch event {
            case .next(let value):
                onNext?(value)
            case .error(let error):
                onError?(error)
                disposable.dispose()
            case .completed:
                onCompleted?()
                disposable.dispose()
            }
        }
        return Disposables.create(
            self.asObservable().subscribe(observer),
            disposable
        )
    }
}

class ObserverBase<Element> : Disposable, ObserverType {
    func on(_ event: Event<Element>) {
        switch event {
        case .next:
            self.onCore(event)
        case .error, .completed:
            self.onCore(event)
        }
    }
    
    func onCore(_ event: Event<Element>) {}
    
    func dispose() {}
}

extension ObservableType {
    func asObservable() -> Observable<Element> {
        Observable.create { observer in self.subscribe(observer) }
    }
}
