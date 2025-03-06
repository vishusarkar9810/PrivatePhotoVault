//
//  PasscodeViewController.swift
//  PrivatePhotoVault
//
//  Created by Vishwajeet Sarkar on 06/03/25.
//

import UIKit

class PasscodeViewController: UIViewController {
    private let securityManager = SecurityManager()
    private let passcodeTextField = UITextField()
    private let submitButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("PasscodeViewController: viewDidLoad called at \(Date())")
        view.backgroundColor = .white
        setupUI()
        
        // Move keychain check to background if needed
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            if (try? self.securityManager.retrievePasscode()) == nil {
                DispatchQueue.main.async {
                    self.title = "Set Passcode"
                }
            } else {
                DispatchQueue.main.async {
                    self.title = "Enter Passcode"
                }
            }
        }
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let frame = self.view.frame
            let inWindow = self.view.window != nil
            print("PasscodeViewController: View frame after layout: \(frame), in window: \(inWindow), subviews: \(self.view.subviews.count)")
            if frame.width == 0 || frame.height == 0 {
                print("Warning: View has zero size, UI may not render")
            }
        }
    }
    
    private func setupUI() {
        print("PasscodeViewController: Setting up UI")
        passcodeTextField.placeholder = "Enter 4-digit passcode"
        passcodeTextField.keyboardType = .numberPad
        passcodeTextField.isSecureTextEntry = true
        passcodeTextField.borderStyle = .roundedRect
        passcodeTextField.backgroundColor = .systemGray6
        passcodeTextField.translatesAutoresizingMaskIntoConstraints = false
        
        submitButton.setTitle("Submit", for: .normal)
        submitButton.addTarget(self, action: #selector(submitPasscode), for: .touchUpInside)
        submitButton.backgroundColor = .systemBlue
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 8
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(passcodeTextField)
        view.addSubview(submitButton)
        
        NSLayoutConstraint.activate([
            passcodeTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passcodeTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            passcodeTextField.widthAnchor.constraint(equalToConstant: 200),
            passcodeTextField.heightAnchor.constraint(equalToConstant: 40),
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            submitButton.topAnchor.constraint(equalTo: passcodeTextField.bottomAnchor, constant: 20),
            submitButton.widthAnchor.constraint(equalToConstant: 100),
            submitButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        print("PasscodeViewController: Subviews added: \(view.subviews.count)")
    }
    
    @objc private func submitPasscode() {
        guard let passcode = passcodeTextField.text, passcode.count == 4 else {
            showAlert(message: "Please enter a 4-digit passcode.")
            return
        }
        
        do {
            if (try? securityManager.retrievePasscode()) == nil {
                try securityManager.savePasscode(passcode)
                try securityManager.generateAndSaveEncryptionKey()
                let galleryVC = GalleryViewController()
                navigationController?.pushViewController(galleryVC, animated: true)
            } else if try securityManager.retrievePasscode() == passcode {
                let galleryVC = GalleryViewController()
                navigationController?.pushViewController(galleryVC, animated: true)
            } else {
                showAlert(message: "Invalid passcode.")
            }
        } catch {
            showAlert(message: "An error occurred. Please try again.")
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
