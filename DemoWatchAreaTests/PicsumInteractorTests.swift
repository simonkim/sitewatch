//
//  PicsumInteractorTests.swift
//  AreaWatchDemoTests
//
//  Created by Simon Kim on 2023/04/22.
//

import XCTest
import Combine

final class PicsumInteractorTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testLoadPage_morePicsums() throws {
        let pageSize = 10

        let exp = expectation(description: "sink")
        
        let sut = PicsumInteractor(pageSize: pageSize)
        sut.loadedItemCount = 0
        let c1 = sut.morePicsums.sink { [weak sut, pageSize] more in
            XCTAssert(more.items.count > 0)
            XCTAssertEqual(sut?.loadedItemCount, pageSize)
            exp.fulfill()
        }
        
        sut.loadingPage = 0

        waitForExpectations(timeout: 3)

        [c1].forEach { $0.cancel() }
        
    }
    
    func testLoadPage_updatedCoverImage() throws {
        let pageSize = 10

        let expCoverImages = expectation(description: "coverImages")
        expCoverImages.expectedFulfillmentCount = pageSize
        
        let sut = PicsumInteractor(pageSize: pageSize)
        sut.loadedItemCount = 0

        let c2 = sut.updatedCoverImage.sink { image in
            expCoverImages.fulfill()
        }
        
        sut.loadingPage = 0

        waitForExpectations(timeout: 3)

        [c2].forEach { $0.cancel() }
        
    }

}

// MARK : -

class PicsumInteractor {
    struct Picsum: Decodable {
        let author: String
        let imageUrl: String
        
        private enum CodingKeys: String, CodingKey {
            case imageUrl = "download_url"
            case author
        }
    }

    struct MorePicsums {
        let items: [Picsum]
        let indicies: [Int]
        let nextPage: Int
        
        var urlIndexPairs: [(URL, Int)] {
            let urls = items.compactMap { URL(string: $0.imageUrl) }
            guard urls.count == indicies.count else {
                return []
            }
            return zip(urls, indicies).map { ($0, $1 )}
        }
    }

    struct UpdatedCoverImage {
        let itemIndex: Int
        let image: UIImage
    }
    
    @Published var loadingPage: Int? = nil
    @Published var lastError: Error? = nil
    var loadedItemCount: Int = 0
    var nextPage: Int = 0
    
    lazy var morePicsums = {
        morePicsumsSubject
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
    }()
    lazy var updatedCoverImage = {
        updatedCoverImageSubject
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
    }()
    
    private let pageSize: Int
    private let morePicsumsSubject = PassthroughSubject<MorePicsums, Never>()
    private let updatedCoverImageSubject = PassthroughSubject<UpdatedCoverImage, Never>()

    private var cancellables: [AnyCancellable] = []

    init(pageSize: Int) {
        self.pageSize = pageSize
        let decoder = JSONDecoder()
        $loadingPage
            .compactMap { $0 }
            .map { URL(picsumPage: $0) }
            //iOS13: <Int?,Never> -> <Int?, RemoteStoreError>
            .setFailureType(to: URLError.self)
            .flatMap(URLSession.shared.dataTaskPublisher)
            .map(\.data)
            .decode(type: [Picsum].self, decoder: decoder)
            .map { [weak self] result in
                let nextPage = self?.nextPage ?? 0
                let loadedItemCount = self?.loadedItemCount ?? 0
                let indices = Array(loadedItemCount ..< (loadedItemCount + result.count) )

                return MorePicsums(items: result, indicies: indices, nextPage: nextPage)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.lastError = error
                    return
                }
                self?.loadingPage = nil
            }, receiveValue: { [weak self] value in
                self?.loadedItemCount += value.items.count
                self?.nextPage += 1
                self?.morePicsumsSubject.send(value)
            })
            .store(in: &cancellables)
        
        morePicsumsSubject
            .map(\.urlIndexPairs)
            .flatMap(\.publisher)
            .setFailureType(to: URLError.self)
            .flatMap { (url, index) in
                return Publishers.Zip(
                    Just(index)
                        .setFailureType(to: URLError.self),
                    URLSession.shared.dataTaskPublisher(for: url)
                )
            }
            .map { ( $0.0, UIImage(data: $0.1.data) ) }
            .filter { $0.1 != nil }
            .map { UpdatedCoverImage(itemIndex: $0.0, image: $0.1!) }
            .sink(receiveCompletion: { _ in
            }, receiveValue: { [weak self] value in
                self?.updatedCoverImageSubject.send(value)
            })
            .store(in: &cancellables)
    }
}

extension URL {
    static let firtPicsumPage = URL(string: "https://picsum.photos/v2/list")!
    init(picsumPage: Int?) {
        guard let picsumPage = picsumPage else {
            self = Self.firtPicsumPage
            return
        }
        self.init(string: "https://picsum.photos/v2/list?page=\(picsumPage)&limit=10")!
    }
}
