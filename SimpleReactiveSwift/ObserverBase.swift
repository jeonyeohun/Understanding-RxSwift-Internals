//
//  ObserverBase.swift
//  SimpleReactiveSwift
//
//  Created by 전여훈 on 2022/01/22.
//

import Foundation

class ObserverBase<Element> : Disposable, ObserverType {
    
    func on(_ event: Event<Element>) {
        switch event {
        case .next:
            /* 여행 24 */
            // ObserverBase는 onCore를 부르고 있다. 근데 얘는 AnonymousObserver에서 오버라이딩하고 있다.
            // 다시 AnonymousObserver로 이동하자.
            self.onCore(event)
        case .error, .completed:
            self.onCore(event)
        }
    }
    
    func onCore(_ event: Event<Element>) {}
    
    func dispose() {}
}
