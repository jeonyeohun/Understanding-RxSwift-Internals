//
//  AnonymousObserver.swift
//  SimpleReactiveSwift
//
//  Created by 전여훈 on 2022/01/21.
//

import Foundation

final class AnonymousObserver<Element>: ObserverBase<Element> {
    typealias EventHandler = (Event<Element>) -> Void
    
    private let eventHandler : EventHandler
    /* 여행 5 */
    // AnonymousObserver는 만들어지면서 전달된 클로저를 EventHandler로 등록한다.
    // 이 말은 곧 subsribe를 하면서 만들었던 이벤트별 클로저들이 switch로 감싸진 하나의 클로저가 되어서 이곳에 등록되는 것이다.
    // 왜 eventHandler인지 납득이 된다. 이제 다시 돌아가자.
    init(_ eventHandler: @escaping EventHandler) {
        self.eventHandler = eventHandler
    }
    
    override func onCore(_ event: Event<Element>) {
        /* 여행 25 */
        // 마침내 이벤트가 이벤트 핸들러에 도착했다. 위에 적혀있는대로, subscribe를 하면서 만들어진 switch 클로저에 이벤트가 인자로 전달된다.
        self.eventHandler(event)
    }
}
