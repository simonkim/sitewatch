//
//  CombineTests.swift
//  AreaWatchDemoTests
//
//  Created by Simon Kim on 2023/03/25.
//

import XCTest
import Combine

final class CombineScribble: XCTestCase {
    enum LocalError: Error {
        case failed
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFlatMap_nested_publishers() throws {
        let exp = expectation(description: "sinkCompletion")
        exp.expectedFulfillmentCount = 2
        let expValue10 = expectation(description: "value10")
        expValue10.expectedFulfillmentCount = 10
        let expValue3 = expectation(description: "value3")
        expValue3.expectedFulfillmentCount = 3

        let multiplyPublisher: (Int) -> AnyPublisher<Double, Error> = {
            Just(Double($0 * $0))
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        let c1 = Array(0..<10).publisher
            .setFailureType(to: Error.self) // iOS13
            .flatMap(multiplyPublisher)
            .sink(receiveCompletion: { _ in exp.fulfill()}, receiveValue: { value in
                expValue10.fulfill()
            })

        let c2 = [1, 2, 3].publisher
            .setFailureType(to: Error.self)  // iOS13
            .flatMap(multiplyPublisher)
            .sink(receiveCompletion: { _ in exp.fulfill()}, receiveValue: { value in
                expValue3.fulfill()
            })
        
        waitForExpectations(timeout: 3)
        
        [c1, c2].forEach { $0.cancel() }
    }
    
    func testFlatMap_zip_data_index() throws {
        let exp = XCTestExpectation(description: "sink")
        exp.expectedFulfillmentCount = 2
        
        let baseIndex: Int = 12
        let picsums: [PicsumInteractor.Picsum] = [
            .init(author: "A", imageUrl: "https://picsum.photos/200/300.jpg"),          // baseIndex + 1
            .init(author: "B", imageUrl: "https://picsum.photos/200/300?random=1"),     // baseIndex + 2
        ]
        
        let picsumsIndexed = zip(
            picsums.map{ URL(string: $0.imageUrl)! },
            Array(baseIndex ..< (baseIndex + picsums.count) )
        )
        
        let c1 = picsumsIndexed.publisher
            .setFailureType(to: URLError.self)
            .flatMap { (url, index) in
                return Publishers.Zip(
                    URLSession.shared.dataTaskPublisher(for: url),
                    Just(index)
                        .setFailureType(to: URLError.self)
                )
                .map { (UIImage(data: $0.0.data), $0.1) }
                .filter { $0.0 != nil}
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { value in
                    print("value: \(value)")
                    exp.fulfill()
                })
        
        wait(for: [exp], timeout: 3)
        
        [c1].forEach { $0.cancel() }
        
    }

    func testPublisherSendTwice() throws {
        let expValue = expectation(description: "Value")
        expValue.expectedFulfillmentCount = 2
        
        var cancellables: [AnyCancellable] = []

        let subject = PassthroughSubject<Int, Error>()
        subject.eraseToAnyPublisher()
            .sink { _ in
            } receiveValue: { value in
                print(value)
                expValue.fulfill()
            }.store(in: &cancellables)

        
        subject.send(1)
        subject.send(2)
        waitForExpectations(timeout: 0.5)
    }
    
    func testPublisherSendError_once() throws {
        let expFailed = expectation(description: "Failed")
        
        var cancellables: [AnyCancellable] = []

        let subject = PassthroughSubject<Int, Error>()
        subject
            .eraseToAnyPublisher()
            .sink { result in
                if case .failure(_) = result {
                    expFailed.fulfill()
                }
            } receiveValue: { value in
                print(value)
            }.store(in: &cancellables)
        
        subject.send(completion: .failure(LocalError.failed))
        waitForExpectations(timeout: 0.5)
    }
    
    func clampPublisher<T: Comparable>(value: T, max: T) -> AnyPublisher<T, Error> {
        if value > max {
            return Fail(error: LocalError.failed).eraseToAnyPublisher()
        }
        return Just(value)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func testPublisher_twoErros_then_recover_value() throws {
        let expFailed = expectation(description: "Failed")
        expFailed.expectedFulfillmentCount = 2
        let expValue = expectation(description: "Value")

        var cancellables: [AnyCancellable] = []
        enum Result {
            case value(Int)
            case failure(Error)
        }
        let input = PassthroughSubject<Int, Never>()
        input
            // To recover from error and continue handling the next value
            // Wrap followings with flatMap*
            // - nesteded publisher
            // - map value,
            // - and catch to replace error with a value
            // * iOS 13 requires Failure Type to remain unchanged.
            //   `Never` in this case: (Int, Never) -> (Result, Never)
            .flatMap { value in                                         // Int, Never -> Result, Never
                return self.clampPublisher(value: value, max: 10)       //      (Int, Error)
                    .map { Result.value($0) }                           //      Int -> Result.value()
                    .catch { e in                                       //      Error -> Result.failure()
                        Just(Result.failure(e))
                    }
                    .setFailureType(to: Never.self)                     //      Error -> Never
            }
            .eraseToAnyPublisher()
            .sink { _ in
            } receiveValue: { result in
                print(result)
                if case .failure(_) = result {
                    expFailed.fulfill()
                }
                if case .value(_) = result {
                    expValue.fulfill()
                }
            }.store(in: &cancellables)
        
        input.send(100) // error 100 > max
        input.send(200) // error 200 > max
        input.send(5)   // < max
        waitForExpectations(timeout: 0.5)
    }

    func testEnumState() throws {
        let exp = expectation(description: "sink")
        exp.expectedFulfillmentCount = 4
        
        let sut = EnumStatePublished()
        
        let publisher = sut.$footerState
            .dropFirst(1)                       // Drop initial state
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
        let c1 = publisher.sink { state in
            print("sink: \(state)")
            exp.fulfill()
        }
        
        sut.footerState = .init(isLoading: true)
        sut.footerState = .init(error: LocalError.failed)
        sut.footerState = .init(isLoading: true)
        sut.footerState = .init(isLoading: false)
        
        waitForExpectations(timeout: 0.5)
        c1.cancel()
    }
}

class EnumStatePublished {
    @Published var footerState: FooterState = .init(isLoading: false, error: nil)

    enum FooterState: Equatable {
        case loading
        case finished(Error?)
        
        var isLoading: Bool {
            if case .loading = self { return true }
            return false
        }
        
        var error: Error? {
            guard case .finished(let e) = self else {
                return nil
            }
            return e
        }
        
        init(isLoading: Bool, error: Error? = nil) {
            switch isLoading {
            case true:
                self = .loading
            case false:
                self = .finished(error)
            }
        }
        
        init(error: Error?) {
            self.init(isLoading: error == nil, error: error)
        }
        

        static func == (lhs: FooterState, rhs: FooterState) -> Bool {
            switch (lhs, rhs) {
            case (.loading, .loading):  return true
                
            case (.finished(let lhsError), .finished(let rhsError)):
                return equal(lhsError, rhsError)
                
            default:                    return false
            }
        }
        
        static func equal<T: Error>(_ lhs: T?, _ rhs: T?) -> Bool {
            if lhs == nil, rhs == nil {
                return true
            }
            guard let lhs = lhs, let rhs = rhs else {
                return false
            }
            guard String(describing: lhs) == String(describing: rhs) else {
                return false
            }
            return (lhs as NSError).isEqual(rhs as NSError)
        }
    }
    
}
