//
//  KeyboardViewController.swift
//  Wallet_Keyboard_Extension
//
//  Created by GianluK on 8/23/24.
//

import UIKit
import UniformTypeIdentifiers

class KeyboardViewController: UIInputViewController {
    // UI Elements
    private var amountLabel: UILabel!
    private var increaseButton: UIButton!
    private var decreaseButton: UIButton!
    private var sendButton: UIButton!
    private var requestButton: UIButton!
    private var addressLabel: UILabel!
    private var sendLoadingSpinner: UIActivityIndicatorView!
    private var requestLoadingSpinner: UIActivityIndicatorView!
    
    // Data
    private var currentAmount: Int = 1
    private var walletAddress: String {
        switch configuredChain {
        case .solana:
            return "7avUQL5L49iF6PY7iUwuTxYVsySwYf3U3ucjTEdtWzyf"
        default:
            return "0x9647BB6a598c2675310c512e0566B60a5aEE6261"
        }
    }
    
    // Global configuration chain constant
    private let configuredChain: Chain = .zkSync
    
    private enum Chain: String {
        case arbitrum = "Arbitrum"
        case polygon = "Polygon"
        case zkSync = "zkSync"
        case solana = "Solana"
        case avalanche = "Avalanche"
        case mantle = "Mantle"
        
        var linkQueue: [String] {
            switch self {
            case .zkSync:
                return [
                    "https://peanut.to/claim?c=324&v=v4.3&i=70&t=ui#p=JxlhboGVhrpiMhyU",
                    "https://peanut.to/claim?c=324&v=v4.3&i=71&t=ui#p=47sXuj3fhTwBNRrL",
                    "https://peanut.to/claim?c=324&v=v4.3&i=72&t=ui#p=97no9UgYBa2PHDQu",
                    "https://peanut.to/claim?c=324&v=v4.3&i=73&t=ui#p=4g5uD64tKpwJHWus",
                    "https://peanut.to/claim?c=324&v=v4.3&i=74&t=ui#p=sKW3LLocOogrNNBd"
                ]
            }
        }

        var explorerURL: String {
            switch self {
            case .arbitrum:
                return "https://arbiscan.io/address/"
            case .polygon:
                return "https://polygonscan.com/address/"
            case .zkSync:
                return "https://explorer.zksync.io/address/"
            case .solana:
                return "https://solscan.io/account/"
            case .avalanche:
                return "https://snowtrace.io/address/"
            case .mantle:
                return "https://explorer.mantle.xyz/address/"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        addressLabel = createLabel(text: shortenAddress(walletAddress), fontSize: 14)
        addressLabel.textColor = .systemBlue
        addressLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addressTapped))
        addressLabel.addGestureRecognizer(tapGesture)
        amountLabel = createLabel(text: "$1", fontSize: 56)
        increaseButton = createButton(title: "+", fontSize: 56, action: #selector(increaseAmount))
        decreaseButton = createButton(title: "-", fontSize: 56, action: #selector(decreaseAmount))
        requestButton = createButton(title: "Request", fontSize: 28, action: #selector(requestAmount))
        sendButton = createButton(title: "Send", fontSize: 28, action: #selector(sendAmount))
        
        sendLoadingSpinner = UIActivityIndicatorView(style: .medium)
        sendLoadingSpinner.hidesWhenStopped = true
        
        requestLoadingSpinner = UIActivityIndicatorView(style: .medium)
        requestLoadingSpinner.hidesWhenStopped = true
        
        [addressLabel, amountLabel, increaseButton, decreaseButton,
         requestButton, sendButton, sendLoadingSpinner, requestLoadingSpinner].forEach { view.addSubview($0) }
    }
    
    private func setupConstraints() {
        [addressLabel, amountLabel, increaseButton, decreaseButton,
         requestButton, sendButton, sendLoadingSpinner, requestLoadingSpinner].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            // Center the amount section and make it larger
            amountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            amountLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            amountLabel.heightAnchor.constraint(equalToConstant: 70),
            
            increaseButton.leadingAnchor.constraint(equalTo: amountLabel.trailingAnchor, constant: 30),
            increaseButton.centerYAnchor.constraint(equalTo: amountLabel.centerYAnchor),
            increaseButton.heightAnchor.constraint(equalToConstant: 70),
            
            decreaseButton.trailingAnchor.constraint(equalTo: amountLabel.leadingAnchor, constant: -30),
            decreaseButton.centerYAnchor.constraint(equalTo: amountLabel.centerYAnchor),
            decreaseButton.heightAnchor.constraint(equalToConstant: 70),
            
            // Adjust "Request" and "Send" buttons
            requestButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            requestButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -10),
            
            sendButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            sendButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 10),
            
            sendLoadingSpinner.centerXAnchor.constraint(equalTo: sendButton.centerXAnchor),
            sendLoadingSpinner.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor),
            
            requestLoadingSpinner.centerXAnchor.constraint(equalTo: requestButton.centerXAnchor),
            requestLoadingSpinner.centerYAnchor.constraint(equalTo: requestButton.centerYAnchor),
            
            // Address label at the bottom
            addressLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            addressLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    private func createLabel(text: String, fontSize: CGFloat) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.textAlignment = .center
        return label
    }
    
    private func createButton(title: String, fontSize: CGFloat, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    @objc private func increaseAmount() {
        currentAmount += 1
        updateAmountLabel()
    }
    
    @objc private func decreaseAmount() {
        if currentAmount > 1 {
            currentAmount -= 1
        }
        updateAmountLabel()
    }
    
    private func updateAmountLabel() {
        amountLabel.text = "$\(currentAmount)"
    }
    
    @objc private func sendAmount() {
        guard let link = configuredChain.linkQueue.first else {
            insertText("No more links available for \(configuredChain.rawValue).")
            return
        }
        
        sendButton.isEnabled = false
        sendButton.setTitle("", for: .normal)
        sendLoadingSpinner.startAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            guard let self = self else { return }
            self.sendLoadingSpinner.stopAnimating()
            self.sendButton.setTitle("Send", for: .normal)
            self.sendButton.isEnabled = true
            self.insertText(link)
        }
    }
    
    @objc private func requestAmount() {
        requestButton.isEnabled = false
        requestButton.setTitle("", for: .normal)
        requestLoadingSpinner.startAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self = self else { return }
            let formattedAmount = String(self.currentAmount * 1000000)
            let link = "https://amanu.app/claim/request?rea=\(self.walletAddress)&amt=\(formattedAmount)&chain=\(self.configuredChain.rawValue.lowercased())"
            self.insertText(link)
            self.requestLoadingSpinner.stopAnimating()
            self.requestButton.setTitle("Request", for: .normal)
            self.requestButton.isEnabled = true
        }
    }
    
    private func insertText(_ text: String) {
        let proxy = textDocumentProxy as UITextDocumentProxy
        proxy.insertText(text)
    }
    
    private func shortenAddress(_ address: String) -> String {
        guard address.count > 10 else { return address }
        let prefix = address.prefix(6)
        let suffix = address.suffix(4)
        return "\(prefix)...\(suffix)"
    }

    @objc private func addressTapped() {
        let explorerURL = configuredChain.explorerURL + walletAddress
        if let url = URL(string: explorerURL) {
            openURL(url)
        }
        
        // Provide visual feedback
        let originalColor = addressLabel.textColor
        addressLabel.textColor = .green
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.addressLabel.textColor = originalColor
        }
    }
    
    private func openURL(_ url: URL) {
        let selector = sel_registerName("openURL:")
        var responder: UIResponder? = self as UIResponder
        while responder != nil {
            if responder!.responds(to: selector) {
                responder!.perform(selector, with: url)
                return
            }
            responder = responder!.next
        }
    }
}