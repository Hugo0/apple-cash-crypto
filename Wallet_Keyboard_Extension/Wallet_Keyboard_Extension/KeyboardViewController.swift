//
//  KeyboardViewController.swift
//  Wallet_Keyboard_Extension
//
//  Created by GianluK on 8/23/24.
//

import UIKit

class KeyboardViewController: UIInputViewController {
    // UI Elements
    private var amountLabel: UILabel!
    private var increaseButton: UIButton!
    private var decreaseButton: UIButton!
    private var sendButton: UIButton!
    private var requestButton: UIButton!
    private var addressLabel: UILabel!
    private var loadingSpinner: UIActivityIndicatorView!
    
    // Data
    private var currentAmount: Int = 1
    private let walletAddress = "0xd1387901E75B5Af2E4A68Da880D2485796c82d8C"
    
    // Global configuration chain constant
    private let configuredChain: Chain = .arbitrum
    
    private enum Chain: String {
        case arbitrum = "Arbitrum"
        
        var linkQueue: [String] {
            switch self {
            case .arbitrum: return ["https://peanut.to/claim?c=42161&v=v4.3&i=1&t=ui#p=example"]
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
        amountLabel = createLabel(text: "$1", fontSize: 56)
        increaseButton = createButton(title: "+", fontSize: 56, action: #selector(increaseAmount))
        decreaseButton = createButton(title: "-", fontSize: 56, action: #selector(decreaseAmount))
        requestButton = createButton(title: "Request", fontSize: 28, action: #selector(requestAmount))
        sendButton = createButton(title: "Send", fontSize: 28, action: #selector(sendAmount))
        
        loadingSpinner = UIActivityIndicatorView(style: .medium)
        loadingSpinner.hidesWhenStopped = true
        
        [addressLabel, amountLabel, increaseButton, decreaseButton,
         requestButton, sendButton, loadingSpinner].forEach { view.addSubview($0) }
    }
    
    private func setupConstraints() {
        [addressLabel, amountLabel, increaseButton, decreaseButton,
         requestButton, sendButton, loadingSpinner].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
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
            
            loadingSpinner.centerXAnchor.constraint(equalTo: sendButton.centerXAnchor),
            loadingSpinner.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor),
            
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
        loadingSpinner.startAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            guard let self = self else { return }
            self.loadingSpinner.stopAnimating()
            self.sendButton.setTitle("Send", for: .normal)
            self.sendButton.isEnabled = true
            self.insertText(link)
        }
    }
    
    @objc private func requestAmount() {
        let formattedAmount = String(currentAmount * 1000000)
        let link = "https://amanu.app/claim/request?rea=\(walletAddress)&amt=\(formattedAmount)&chain=\(configuredChain.rawValue.lowercased())"
        insertText(link)
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
}