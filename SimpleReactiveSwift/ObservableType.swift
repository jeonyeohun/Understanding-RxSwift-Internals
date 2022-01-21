//
//  ObservableType.swift
//  SimpleReactiveSwift
//
//  Created by 전여훈 on 2022/01/21.
//

import Foundation

protocol ObservableType: ObservableConvertibleType {
    associatedtype Element
    func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable  where Observer.Element == Element
}

extension ObservableType {
    /* 여행 2 */
    // 일단 들어왔는데, Observable이 아니다. 우리는 Observable.create를 불렀는데?
    // 그렇다. create는 Observable이 채택하는 프로토콜인 ObservableType에 정의되어 있다.
    // 심지어 subscribe도 ObservableType이 인터페이스를 들고 있는데, 이건 좀 있다가 알아보자.
    // create 메서드에서 하는 일은 단순하다. AnonymousObservable 인스턴스를 만들고 반환한다.
    // 그리고 생성자에 우리가 create를 부르면서 정의했던 클로저가 전달된다.
    //  -> 이 클로저는
    //    { observer in
    //        observer.onNext(1)
    //        observer.onNext(2)
    //        observer.onCompleted()
    //        return Disposables.create()
    //    }
    //  이 녀석이다.
    // 이제 AnonymousObservable이 뭔지 알아야겠지? Jump to Definition.
    public static func create(_ subscribe: @escaping (AnyObserver<Element>) -> Disposable) -> Observable<Element> {
        return AnonymousObservable(subscribe)
    }
}

extension ObservableType {
    /* 여행 4 */
    // subscribe 메서드의 구현체로 도착했다. 인자로 받는 클로저들이 nil을 디폴트로 가진다. 아 이래서 아무 클로저를 만들지 않아도, onNext만 만들어도 문제가 없었던 것이었다.
    // subscribe는 disposable을 반환한다. 이건 당연하다.. 구독을 취속하려면 취소할 수 있게 해주는 인스턴스를 줘야하니까.
    // 구현을 구체적으로 보기 위해서 아래로 내려가자.
    func subscribe(
        onNext: ((Element) -> Void)? = nil,
        onError: ((Swift.Error) -> Void)? = nil,
        onCompleted: (() -> Void)? = nil,
        onDisposed: (() -> Void)? = nil
    ) -> Disposable {
        let disposable: Disposable
        
        // 일단 여기에서 disposable을 하나 만든다. 나는 구독 취소시 동작을 지정할 수 없도록 만들어서 그냥 빈 disposable을 만든다.
        disposable = Disposables.create()
        
        // 갑자기 AnonymousObserver를 만든다.
        // 이 옵저버가 하는 일은 어떤 이벤트가 들어왔을 때 subscribe의 인자로 들어온 이벤트에 맞는 메서드들을 실행하는 것이다.
        // 그렇다. subscribe 자체가 구독자가 아니라, 내부에서 구독자를 만들고 있었던 것이다.
        // 어떻게 만들어지는지 잠시 보고오자. Jump to definition.
        // 간단하다. 결국은 switch문으로 이벤트에 대한 동작을 전달받을 클로저로 정의하고, 이 과정을 eventHandler에 등록해주는 것이다.
        let observer = AnonymousObserver<Element> { event in
            switch event {
            /* 여행 27 */
            // 돌고돌아 다시 여기까지 왔다.
            // 이벤트가 이 클로저에 전달되고 onNext가 불리면서 사전에 정의한 next에 대한 클로저가 실행된다.
            case .next(let value):
                onNext?(value)
            case .error(let error):
                onError?(error)
                disposable.dispose() // 우리가 알고있는대로 에러나 컴플리션 이벤트가 발생하면 dispose 메서드가 호출된다.
            case .completed:
                onCompleted?()
                disposable.dispose()
            }
        }
        return Disposables.create( // 마지막에 disposable을 만든다. 근데 안에 전달되는 인자가 두 개다. 뭐지? 인자를 두 개 받는 Dispoables.create를 찾아가보자. 아직 이 메서드가 안끝났으면 여기로 다시 돌아와야한다. 창 끄지 말고 Jump to definition.
            self.asObservable().subscribe(observer),
            // 다시 돌아왔으니 이걸 먼저보자. 자기자신의 asObservable을 실행하고 subscribe한 결과를 반환한다. 그리고 subscribe의 인자로 위에서 만든 observer를 전달한다. 와우. 무슨말인지 모르겠는걸?
            // 일단 self부터 정의하자. self는 내가 subscribe를 불렀던 대상이니까 Observable<Int> 이녀석의 인스턴일 것이다.
            // 그럼 그 인스턴스의 asObservable을 먼저 봐야겠으니까 또 점프해보자. Jump to definition. 구현체로 찾아가야 하니까 ObservableType안에 들어있는 asObservable로 가면 된다(사실 스크롤 내리면 밑에 있다).
            // ========
            // 다시 돌아왔다. 그럼 AnonymousObservable이 반환되었고, 이 인스턴스가 가지고 있는 subscribe메서드를 호출한다. 그리고 인자로 위에서 만들었던 observer를 전달한다. observer의 존재를 잊었을까봐 다시 적어보면, subscribe를 할 때 작성한 각 이벤트에 대한 클로저를 가지고 있는 객체이다.
            // 그럼 이제 subscribe를 보면 되겠지? Jump to definition. subscribe의 구현체는 Producer에 있다. 사실 AnonymousObservable은 Producer를 상속하고 있었다.
            disposable
        )
    }
}

extension ObservableType {
    /* 여행 7 */
    // asObservable이 하는 일은 간단하다. Observable.create를 다시 부른다.
    // 그리고 이번에는 create 메서드의 인자로 이벤트를 방출하는 클로저가 아니라 자기자신을 subscribe하는 클로저를 보내고 그 인자로 전달받은 observer를 그대로 전달한다.
    // 헷갈리지만 생각해보면 이해된다. 맨처음에 만들었던 Observable<Int>가 여전히 타겟이고, 이번에는 이 친구의 subscribe를 호출하는 클로저를 전달하는것이다. 그리고 그 클로저에 observer를 전달하는 것이고.
    // 그럼 아까 보았던대로, AnonymousObservable이 하나 만들어질 것이다. 그리고 그 안에 있는 subscribeHandler는 { observer in self.subscribe(observer) } 이게 되겠지. 이때 self는 캡쳐해서 가지고 들어간 것이니까 AnonymousObservable이 아니라 create를 호출한 인스턴스다.
    // 정리하자면 subscribeHandler로 self.subscribe(observer)를 등록한 AnonymousObservable이 반환된다.
    // 오키 여기는 일단 알겠다. 다시 돌아가자.
    func asObservable() -> Observable<Element> {
        Observable.create { observer in self.subscribe(observer) }
    }
}
