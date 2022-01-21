//
//  Observable.swift
//  SimpleReactiveSwift
//
//  Created by 전여훈 on 2022/01/21.
//

import Foundation

class Observable<Element>: ObservableType {
    typealias Element = Element
    func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element  {
        return Disposables.create()
    }
}
