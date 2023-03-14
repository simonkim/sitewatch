import UIKit
import Combine

struct Picsum: Decodable {
    let author: String
    let url: String
}

func testZip() {
    let picsums: [Picsum] = [
        .init(author: "A", url: "https://picsum.photos/200/300.jpg"),
        .init(author: "B", url: "https://picsum.photos/200/300?random=1"),
    ]
    let baseIndex: Int = 12
    let indices = Array(baseIndex ..< (baseIndex + picsums.count) )
    let notes = ["Alpha", "Beta"]
    
    let picsumsIndexed = zip(picsums, indices)
    print(picsumsIndexed)
    let c1 = picsumsIndexed.publisher
        .zip(notes.publisher)
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { _ in
            
        }, receiveValue: { value in
            print("url: \(value.0)")
            print("note: \(value.1)")
        })

    RunLoop.current.run(until: .init(timeInterval: 1, since: .now))
}

    
func testFlatMap() {
    let picsums: [Picsum] = [
        .init(author: "A", url: "https://picsum.photos/200/300.jpg"),
        .init(author: "B", url: "https://picsum.photos/200/300?random=1"),
    ]
    let baseIndex: Int = 12
    let indices = Array(baseIndex ..< (baseIndex + picsums.count) )
    let notes = ["Alpha", "Beta"]
    
    let picsumsIndexed = zip(picsums.map{ URL(string:$0.url)! }, indices)
    
    let c1 = picsumsIndexed.publisher
        .setFailureType(to: URLError.self)
        .flatMap { (url, index) in
            return URLSession.shared.dataTaskPublisher(for: url)
//            return Publishers.Zip(
//                URLSession.shared.dataTaskPublisher(for: value.0),
//                Just(value.1)
//            )
        }
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { _ in
            
        }, receiveValue: { value in
//            print("url: \(value.0)")
//            print("note: \(value.1)")
            print("value: \(value)")
            //            finished = true
        })
    
    RunLoop.current.run(until: .init(timeInterval: 1, since: .now))
}

//testZip()

testFlatMap()
