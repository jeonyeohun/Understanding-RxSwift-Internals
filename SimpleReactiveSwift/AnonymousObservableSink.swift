//
//  AnonymousObservableSink.swift
//  SimpleReactiveSwift
//
//  Created by 전여훈 on 2022/01/21.
//

import Foundation

class AnonymousObservableSink<Observer: ObserverType>: Sink<Observer>, ObserverType {
    typealias Element = Observer.Element
    typealias Parent = AnonymousObservable<Element>
    
    /* 여행 11 */
    // 생성자를 보니 상위 타입의 생성자를 부르고 있다.
    // 상위 타입은 Sink이니까 저기로 가봐야할 것 같다. 고고 Jump to definition.
    override init(observer: Observer, cancel: Cancelable) {
        super.init(observer: observer, cancel: cancel)
    }
    
    /* 여행 15 */
    // on 메서드는 .next 에 대해서는 forwadOn만 부르면서 이벤트를 전달하고, error나 completed는 forwardOn을 부른뒤에 dispose하고있다.
    // 이 함수를 통채로 AnyObserver의 observer 프로퍼티에 등록하는 것이다.
    // forwardOn은 여기에 없으니 상위 타입인 Sink에 있겠지. 이제 뭔가 퍼즐이 맞춰진다. 근데 아직 on이 호출된 것은 아니니까 일단 돌아가자.
    func on(_ event: Event<Element>) {
        switch event {
        case .next:
            /* 여행 22 */
            // forwardOn으로 이벤트가 전달된다.
            self.forwardOn(event: event)
        case .error, .completed:
            self.forwardOn(event: event)
            self.dispose()
        }
    }
    
    func run(_ parent: Parent) -> Disposable {
        /* 여행 13 */
        // run의 인자로 전달된 parent는 AnonymousObservable이다. 지금까지 따라오느라 헷갈릴 것 같아 정리하면 이 AnonymousObservable은 첫 subscribe 가장 마지막에서 Disposables.create안에 들어가는 첫번째 인자에서 만들어진 AnonymousObservable이다.
        // 그때 우리는 self.asObservable().create(observer) 라는 코드를 봤었는데, 자기자신에 대한 AnonymousObservable을 asObservable을 통해 만들었었다.
        // 그리고 이 인스턴스 안에는 { observer in self.subscribe(observer) } 이 클로저가 subscribeHandler로 들어가 있다. 이해가 안된다면 asObservable이 어떻게 구현되어 있는지 보면된다.
        // 그럼 아래에서는 결국에는 { observer in self.subscribe(observer) } 이 클로저를 실행하는 것과 같다. 그리고 인자로 self를 AnyObserver로 형변환하게 된다.
        // 여기서 self는 AnonymousObservableSink이고, 상위 타입인 Sink에 이벤트 처리 클로저인 eventHandler를 가진 observer 프로퍼티와 아까 만들었던 SinkDisposer의 인스턴스인 cancel이 들어가 있다.
        // 그럼 형 변환을 하면 어떻게 되는지 AnyObserver의 생성자부터 보자. Jump to definition.
        
        // 다시 돌아왔다. AnyObserver의 observer 프로퍼티에는 self에 들어있던 forwadOn을 호출하는 클로저가 들어간다.
        // 이제 subscribeHandler를 실행할 차례다.
        // { observer in self.subscribe(observer) } 이 클로저의 인자로 AnyObserver가 들어가게되고, subscribe를 해주니 subsribe가 한 번 더 호출된다. 다시 producer로 가보자.
        
        /* 여행 18 */
        // -- 다시 run으로 돌아왔다. 이번에 parent는 { observer in self.subscribe(observer) } 이 클로저에서 캡쳐된 self이고, self의 subscriptionHandler는 create에서 만들었던 이벤트를 방출했던 클로저이다.
        // -- 따라서 이제 그 클로저에 현재 self, 즉 이전 방문에서 만든 AnyObserver의 EventHandler가 AnyObserver로 전달된다.
        // -- 그럼 이제 create 에서 만든 클로저를 실행하러 main으로 가자
        return parent.subscribeHandler(AnyObserver(self))
    }
}
