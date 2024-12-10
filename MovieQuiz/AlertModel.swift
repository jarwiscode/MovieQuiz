import Foundation

struct alertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: (() -> Void)?
}
