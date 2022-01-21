//
//  AnyObserver.swift
//  SimpleReactiveSwift
//
//  Created by 전여훈 on 2022/01/21.
//

import Foundation

struct AnyObserver<Element>: ObserverType {
    public typealias EventHandler = (Event<Element>) -> Void
    
    private let observer: EventHandler
    
    public init(eventHandler: @escaping EventHandler) {
        self.observer = eventHandler
    }
    
    /* 여행 14 */
    // 이 생성자가 하는 일은 간단하다. 자신의 인자로 전달된 Observer의 on 메서드를 자신의 eventHandler로 잡아주는 것이다.
    // on 메서드를 그럼 보고와야겠다. 여기서 인자로 전달된 인스턴스의 타입은 AnonymousObservableSink 이니까 그 안에 들어있는 on 메서드를 확인해보자.
    // 이번에는 jump to definition이 안되니까 찾아가자..
    
    // 결국 이벤트를 받아서 forwardOn으로 보내거나 추가적으로 dispose까지 실행해주는 클로저가 AnyObserver의 observer 프로퍼티에 담긴다.
    // 다시 돌아가자.
    public init<Observer: ObserverType>(_ observer: Observer) where Observer.Element == Element {
        self.observer = observer.on
    }
    
    public func on(_ event: Event<Element>) {
        /* 여행 21 */
        // on에 도착했다. 여기서 하는 일은 전달받은 이벤트를 observer에 인자로 전달하는 것이다.
        // AnyOnserver의 observer에는 아까 만든 AnonymousObservableSink의 on 메서드가 들어있다.
        // forwardOn으로 이벤트를 전달하고 있었으니까, 다시 그 메서드를 보고오자.
        self.observer(event)
    }
}
