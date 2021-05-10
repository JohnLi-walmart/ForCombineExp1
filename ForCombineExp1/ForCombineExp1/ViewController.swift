//
//  ViewController.swift
//  ForCombineExp1
//
//  Created by John Li on 5/7/21.
//

import UIKit
import Combine

class ViewController: UIViewController {

    @IBOutlet private weak var allowMessageSwitch: UISwitch!
    @IBOutlet private weak var sendButton: UIButton!
    @IBOutlet private weak var messageLabel: UILabel!
    
    @Published var canSendMessage: Bool = false
    
    private var switchSubscriber: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpProcessingChain()
    }
    
    @IBAction func didSwitched(_ sender: UISwitch) {
        canSendMessage = sender.isOn
    }
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        let message = Message(content: "The current date is \(Date())", author: "Me")
        NotificationCenter.default.post(name: Notification.Name(rawValue: Notification.Name.enableMessage), object: message)
    }
    
    private func setUpProcessingChain() {
        switchSubscriber = $canSendMessage.receive(on: DispatchQueue.main).assign(to: \.isEnabled, on: sendButton)
        
        let messagePublisher = NotificationCenter.Publisher(center: .default, name: Notification.Name(rawValue: Notification.Name.enableMessage)).map { norification -> String? in
            
            return (norification.object as? Message)?.content ?? ""
        }
        
        let messageSubscriber = Subscribers.Assign(object: messageLabel, keyPath: \.text)
        
        messagePublisher.subscribe(messageSubscriber)
    }
}

extension Notification.Name {
    static let enableMessage = "enableMessage"
}

struct Message {
    var content: String
    var author: String
}
