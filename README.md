# 읽다보면 이해가 되는 알엑스 👀

## Intro
익명 Observable, 익명 Observer만 존재하는 간단한 리액티브를 구현하는 저장소입니다. </br></br>

[공식 레포](https://github.com/ReactiveX/RxSwift)의 코드를 최대한 따라가면서, 기본적인 기능을 제공하는 코드를 제외하고는 삭제하여 리액티브 프로그래밍의 원리를 이해하는데 집중합니다. 

</br>

main.swift에서부터 주석을 따라가다보면 어떻게 subscribe와 이벤트의 전달과 처리가 동작하는지 이해하게 됩니다 😎</br>
주석은 **여행 #** 으로 넘버링 되어 있습니다. XCode의 검색을 "여행"으로 고정해두면 다음 파일을 찾기가 편합니다.

ex)
```swift
/* 여행 1 */
// create에 들어가는 클로저의 타입은 (AnyObserver<Int>) -> Disposable) -> Observable<Int>.
// observer 혹은 emitter로 써오던 파라미터가 결국 AnyObserver였음을 알 수 있다. AnyObserver에 onNext나 onComplete 같은 이벤트를 방출해주는 것
// create의 반환 타입은 Observable. 즉, create는 말 그대로 observable을 만드는 메서드이고, 만들 때 내부에 방출할 이벤트를 전달해준다.
// 전달되는 클로저의 반환타입은 disposable이다. 그래서 Disposables.create를 호출해준다. create에 클로저가 전달되면 dispose가 호출되었을 때 그 클로저를 실행한다.
// 그럼 create 메서드를 더 자세히 보자. Observable.create가 있는 곳으로 이동하자. create에 우클릭하고 jump to definition 고고
let observable = Observable<Int>.create { observer in
    
    /* 여행 19 */
    // 클로저에 왔다. 이곳에 전달된 observer는 AnyObserver였다. onNext를 찾아가자.
    observer.onNext(1)
    observer.onNext(2)
    observer.onCompleted()
    return Disposables.create()
}
```

</br>

## 제공하는 기능
- Observable 생성
- 이벤트는 next, error, completed 만 지원
- 생성한 Observable 구독
- 구독 취소

## 이해하고자 하는 객체들

### [AnonymousObservable](https://github.com/ReactiveX/RxSwift/blob/b4307ba0b6425c0ba4178e138799946c3da594f8/RxSwift/Observables/Create.swift#L64)

- AnonymousObservable은 create를 통해 새로운 Observable을 생성할 때 반환되는 인스턴스 입니다.
- AnonymousObservable은 생성자로 subscribeHandler를 받습니다. 이 핸들러는 AnonymousObservable 인스턴스에 대한 구독(subscribe)가 발생하면 실행됩니다.

  ```swift
  init(_ subscribeHandler: @escaping SubscribeHandler) {
        self.subscribeHandler = subscribeHandler
  }
  ```

- 따라서 create 메서드와 함께 전달하는 클로저가 subscribeHanlder에 저장됩니다.

  ```swift
  let observable = Observable<Int>.create { observer in // 이 trailing closure가 subscribeHandler에 저장된다.
    observer.onNext(1)
    observer.onNext(2)
    observer.onCompleted()
    return Disposables.create()
  }
  ```
- AnonymousObservable은 Producer 클래스를 상속합니다. 따라서 subscribe가 발생하면 Producer의 subscribe가 호출되고, AnonymousObservable은 Producer의 run 메서드를 오버라이딩해 정의합니다. run 메서드는 sink와 subscription 인스턴스를 생성해 튜플로 반환합니다.

  ```swift
  override func run<Observer: ObserverType>(
        _ observer: Observer,
        cancel: Cancelable
    ) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        let sink = AnonymousObservableSink(observer: observer, cancel: cancel)
        let subscription = sink.run(self)
        
        return (sink: sink, subscription: subscription)
  }
  ```
  
  </br>

### [AnonymousObservableSink](https://github.com/ReactiveX/RxSwift/blob/b4307ba0b6425c0ba4178e138799946c3da594f8/RxSwift/Observables/Create.swift#L25)

- AnonymousObservableSink는 AnonymousObservable로부터 이벤트를 받을 수 있게 하는 객체입니다. 
- 내부에 run 메서드를 구현하고 있고, 이 메서드의 인자로 전달되는 AnonymousObservable의 subscribeHandler를 실행시켜 이벤트를 받게됩니다.

  ```swift
  func run(_ parent: Parent) -> Disposable {
        return parent.subscribeHandler(AnyObserver(self))
  }
  ```
  
 - AnonymousObservableSink는 메서드는 ObservableType을 채택하고 있기 때문에 자체적인 on 메서드를 구현하고 있습니다. 이 on 메서드는 자신의 부모클래스인 Sink의 forwardOn 메서드를 호출하고 이를 통해 이벤트를 전달합니다.

    ```swift
    func on(_ event: Event<Element>) {
            switch event {
            case .next:
                self.forwardOn(event: event)
            case .error, .completed:
                self.forwardOn(event: event)
                self.dispose()
            }
    }
    ```
    
    </br>

### [AnonymousObserver](https://github.com/ReactiveX/RxSwift/blob/main/RxSwift/Observers/AnonymousObserver.swift)

- AnonymousObserver는 ObserverBase 타입을 상속합니다.
- AnonymousObserver는 subscribe 내부에서 생성하게되는 Observer입니다.

  ```swift
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
  ```
- AnonymousObserver의 생성자에 전달되는 클로저는 내부에 있는 eventHandler 프로퍼티에 할당됩니다.

  ```swift
  init(_ eventHandler: @escaping EventHandler) {
    self.eventHandler = eventHandler
  }
  ```

- 등록된 이벤트 핸들러는 onCore 메서드를 통해 Event가 전달되면 실행됩니다.

  ```swift
  override func onCore(_ event: Event<Element>) {
      self.eventHandler(event)
  }
  ```
  </br>


### [AnyObserver](https://github.com/ReactiveX/RxSwift/blob/main/RxSwift/AnyObserver.swift)

- AnyObserver는 ObserverType을 채택합니다.
- AnyObserver는 두 종류의 생성자가 있습니다. 클로저를 받아서 해당 클로저를 이벤트 핸들러인 observer 프로퍼티에 할당하거나, 어떤 ObserverType을 받아 구현된 on 메서드는 observer 프로퍼티에 할당합니다.

  ```swift
  public init(eventHandler: @escaping EventHandler) {
          self.observer = eventHandler
      }

  public init<Observer: ObserverType>(_ observer: Observer) where Observer.Element == Element {
          self.observer = observer.on
      }
  ```
- AnyObserver도 ObserverType을 채택하고 있기 때문에 on 메서드를 구현합니다. AnyObserver에서는 on 메서드를 이벤트 핸들러를 호출하고 인자로 전달받은 이벤트를 넘기고 있습니다.

  ```swift
  public func on(_ event: Event<Element>) {
      self.observer(event)
  }
  ```
  
  </br>

### [Cancelable](https://github.com/ReactiveX/RxSwift/blob/main/RxSwift/Cancelable.swift)

- Cancelable은 Disposable을 채택합니다.
- Cancelable은 객체가 dispose 되었는지 확인할 수 있는 isDisposed 프로퍼티를 정의합니다. 본 프로젝트에서는 isDisposed를 구현하고 있지 않습니다.

  ```swift
  public protocol Cancelable : Disposable {
      var isDisposed: Bool { get }
  }
  ```
  
  </br>

### [Disposables](https://github.com/ReactiveX/RxSwift/blob/main/RxSwift/Disposables/Disposables.swift)

- Disposables는 아무것도 가지고 있지 않은 구조체입니다.

  ```swift
  struct Disposables {}
  ```

- Disposables의 Extension에서는 오버로딩으로 세부 타입들이 타입메서드인 create를 호출하면서 세부 타입의 Disposable 인스턴스를 생성하도록 합니다. 본 프로젝트에서는 DefaultDisposables과 BinaryDisposables를 정의하고 있습니다.

  ```swift
  extension Disposables {
      static public func create() -> Disposable {
          return DefaultDisposable()
      }
  }

  extension Disposables {
      public static func create(_ disposable1: Disposable, _ disposable2: Disposable) -> Cancelable {
          BinaryDisposables(disposable1, disposable2)
      }
  }
  ```
  
  </br>

### [Disposable](https://github.com/ReactiveX/RxSwift/blob/main/RxSwift/Disposable.swift)

- Disposable은 dispose 메서드의 인터페이스를 가지는 프로토콜입니다.

  ```swift
  protocol Disposable {
      func dispose()
  }
  ```
  
- 구체적인 Disposable 타입들은 이 프로토콜을 채택해 구독을 취소할 때 취할 동작을 dispose에 구현합니다.

  ```swift
  class DefaultDisposable: Disposable {
    func dispose() {
        print("disposed")
    }
  }
  ```
  
  </br>

### [Event](https://github.com/ReactiveX/RxSwift/blob/main/RxSwift/Event.swift)

- Event는 시퀀스에 전달할 이벤트를 정의하는 enum입니다.
- next, error, completed가 정의되어 있고, next는 associatedValue로 제네릭을 받습니다.

  ```swift
  enum Event<Element> {
      case next(Element), error(Swift.Error), completed
  }
  ```
  
  </br>

### [Observable](https://github.com/ReactiveX/RxSwift/blob/main/RxSwift/Observable.swift)

- Observable은 ObservableType을 채택하는 클래스입니다.
- subscribe의 추상 메서드를 가지고 있어 이 클래스를 상속하는 Observable의 구체 타입들이 subscribe를 반드시 구현하도록 합니다.

  ```swift
  func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element  {
      fatalError()
  }
  ```
  
  </br>

### [ObservableConvertibleType](https://github.com/ReactiveX/RxSwift/blob/main/RxSwift/ObservableConvertibleType.swift)

- ObservableConvertibleType은 asObservable 메서드의 인터페이스를 가지는 프로토콜입니다.

  ```swift
  protocol ObservableConvertibleType {
      associatedtype Element
      func asObservable() -> Observable<Element>
  }
  ```
  
  </br>

### [ObservableType](https://github.com/ReactiveX/RxSwift/blob/main/RxSwift/ObservableType.swift)

- ObservableType은 ObservableConvertibleType을 채택하는 프로토콜입니다.
- 프로토콜에는 subscribe 메서드에 대한 인터페이스가 정의되어 있습니다.

  ```swift
  protocol ObservableType: ObservableConvertibleType {
      associatedtype Element
      func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable  where Observer.Element == Element
  }
  ```
- ObservableType은 extension으로 create 타입 메서드를 구현하고 있습니다. 이 메서드는 클로저를 인자로 받아 AnonymousObservable을 생성해 반환합니다.

  ```swift
  extension ObservableType {
      public static func create(_ subscribe: @escaping (AnyObserver<Element>) -> Disposable) -> Observable<Element> {
          return AnonymousObservable(subscribe)
      }
  }
  ```
  
- 또 다른 ObservableType의 extension은 subscribe 메서드를 구현하고 있습니다. 일반적으로 onNext, onError, onCompleted, onDisposed에 전달하는 클로저가 이 메서드에서 AnonymousObserver로 래핑되어 사용됩니다.

  ```swift
  extension ObservableType {
    func subscribe(
            onNext: ((Element) -> Void)? = nil,
            onError: ((Swift.Error) -> Void)? = nil,
            onCompleted: (() -> Void)? = nil,
            onDisposed: (() -> Void)? = nil
        ) -> Disposable {
            let disposable: Disposable
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
  ```
  
- 또 다른 ObservableType의 Extension은 ObservableType이 채택하는 ObservableConvertibleType에 있는 asObservable 메서드를 구현합니다. 이 메서드는 자기자신에 대해 subscribe를 부르는 observable를 생성합니다.

  ```swift
  func asObservable() -> Observable<Element> {
      Observable.create { observer in self.subscribe(observer) }
  }
  ```
  
  </br>

### [ObserverType](https://github.com/ReactiveX/RxSwift/blob/main/RxSwift/ObserverType.swift)

- ObserverType은 on 메서드를 인터페이스로 가지는 프로토콜입니다. 모든 구체적인 Observer 타입들은 이 프로토콜을 채택하고 on을 구현합니다.

  ```swift
  protocol ObserverType {
      associatedtype Element
      func on(_ event: Event<Element>)
  }
  ```

- ObserverType은 Extension에 이벤트에 대한 on 을 좀 더 쉽게 사용할 수 있는 신태틱 슈가를 제공합니다. on(.next)를 onNext()로 간단하게 호출할 수 있게 해줍니다.

  ```swift
  extension ObserverType {
      public func onNext(_ element: Element) {
          self.on(.next(element))
      }

      public func onCompleted() {
          self.on(.completed)
      }

      public func onError(_ error: Swift.Error) {
          self.on(.error(error))
      }
  }
  ```
  
  </br>

### [Producer](https://github.com/ReactiveX/RxSwift/blob/main/RxSwift/Observables/Producer.swift)

- Producer는 Observable을 상속하는 클래스입니다.
- Observable의 추상 메서드였던 subsribe를 구현하기 때문에 Observable을 subscribe하면 실제로 불리는 메서드는 Producer의 subscribe 메서드가 됩니다.
- subscribe 안에서는 SinkDisposer의 인스턴스를 만들고, sink와 subscription을 생성한 뒤, SinkDisposer에 넣어주고 SinkDisposer 인스턴스를 반환합니다.

  ```swift
  override func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
      let disposer = SinkDisposer() 
      let sinkAndSubsription = self.run(observer, cancel: disposer)

      disposer.setSinkAndSubscription(sink: sinkAndSubsription.sink, subscription: sinkAndSubsription.subscription)
      return disposer
  }
  ```
  
- sink는 이벤트가 들어왔을 때 옵저버에게 전달해주는 Disposable이고, subscription은 옵저버에 대해 옵저버블의 subscribeHandler를 실행하는 Disposable입니다.
- sink와 subscription을 만드는 run 메서드는 Observable의 구체 타입에 정의됩니다. 본 프로젝트는 AnonymousObservable만 사용하고 있습니다.

  ```swift
  override func run<Observer: ObserverType>(
        _ observer: Observer,
        cancel: Cancelable
    ) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
    
        let sink = AnonymousObservableSink(observer: observer, cancel: cancel)
        let subscription = sink.run(self)
        
        return (sink: sink, subscription: subscription)
    }
  ```
  
- AnonymousObservable의 run은, AnonymousObservableSink 인스턴스를 만들고, run 메서드를 실행해 subscription에 반환값을 할당합니다.

</br>

### [Sink](https://github.com/ReactiveX/RxSwift/blob/main/RxSwift/Observables/Sink.swift)

- Sink는 Disposable을 채택하는 클래스입니다. 
- Sink는 ObserverType의 observer 프로퍼티와 Cancelable 타입의 cancel 프로퍼티를 가지고 있습니다.

  ```swift
  fileprivate let observer: Observer
  fileprivate let cancel: Cancelable
  ```
  
- Sink로 이벤트가 전달되면 forwardOn 메서드를 통해 observer에게 이벤트를 전달하고, dispose가 실행되면 cacel의 dispose 메서드를 호출합니다.

  ```swift
  func forwardOn(event: Event<Observer.Element>) {
      self.observer.on(event)
  }

  func dispose() {
      self.cancel.dispose()
  }
  ```
  
  </br>

### [SinkDisposer](https://github.com/ReactiveX/RxSwift/blob/b4307ba0b6425c0ba4178e138799946c3da594f8/RxSwift/Observables/Producer.swift#L39)

- SinkDisposer는 Cancelable을 채택하고 있는 클래스입니다.
- SinkDisposer는 sink와 subscription 프로퍼티를 가지고 있습니다.

  ```swift
  private var sink: Disposable?
  private var subscription: Disposable?
  ```
 
 - 두 프로퍼티는 setSinkAndSubscription 메서드를 통해 채워집니다. 이 메서든 subscribe에서 sink와 subscription을 만든 뒤에 호출됩니다.

    ```swift
    func setSinkAndSubscription(sink: Disposable, subscription: Disposable) {
        self.sink = sink
        self.subscription = subscription
    }
    ```
  
- dispose가 호출되면 sink와 subscription의 dispose를 모두 호출합니다.

  ```swift
  func dispose() {
      self.sink?.dispose()
      self.subscription?.dispose()
      self.sink = nil
      self.subscription = nil
  }
  ```

- SinkDisposer는 Producer의 subscribe 메서드의 반환 값이기 때문에 subscribe를 통해 얻게되는 Disposable은 사실 SinkDisposer의 인스턴스입니다.

</br>

## 이해하고자 하는 동작들

### Observable.create를 하면 일어나는 일 

### observable.subscribe를 하면 일어나는 일
