//
//  FileSizeDialogViewController.swift
//  NES CHR Editor
//
//  Created by Tom Salvo on 10/23/16.
//  Copyright © 2016 Tom Salvo. All rights reserved.
//

import AppKit

protocol FileSizeSelectionProtocol {
    func fileSizeSelected(_ aNumChrBlocks: UInt8)
}

class FileSizeDialogViewController: NSViewController {

    static let supportedNumChrBlocks: [UInt8] = [1, 2, 4, 8, 16, 32, 64]
    
    var numChrBlocks:UInt8 = 1
    var fileSizeSelectionDelegate:FileSizeSelectionProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        for (index, n) in FileSizeDialogViewController.supportedNumChrBlocks.enumerated() {
            
            let size: ChrFileSize = ChrFileSize(numChrBlocks: n)
            
            let sizeRadioButton = NSButton(radioButtonWithTitle: "\(size.friendlyName)  (\(size.numCHRsInFile) CHRs)", target: self, action: #selector(radiobuttonSelected(sender:)))
            if index == 0 { sizeRadioButton.state = NSControl.StateValue.on }
            stackView.addArrangedSubview(sizeRadioButton)
        }
        
        let okButton = NSButton(title: "OK", target: self, action: #selector(okButtonSelected(sender:)))
        okButton.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(okButton)
        
        
        self.view.addSubview(stackView)
        self.view.addConstraints([
            NSLayoutConstraint(item: stackView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: stackView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: -20),
            NSLayoutConstraint(item: stackView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: stackView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 20),
            
            NSLayoutConstraint(item: stackView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200),
            NSLayoutConstraint(item: stackView, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200),
            
            NSLayoutConstraint(item: okButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100),
            ])
    }
    
    @objc func radiobuttonSelected(sender:NSButton) {
        
        let selectedNumChrBlocks: UInt8 = FileSizeDialogViewController.supportedNumChrBlocks.filter({
            sender.title.contains(ChrFileSize.init(numChrBlocks: $0).friendlyName)
            }).first ?? FileSizeDialogViewController.supportedNumChrBlocks[0]
        
        self.numChrBlocks = selectedNumChrBlocks
    }
    
    @IBAction func okButtonSelected(sender:NSButton) {
        print("File Size - OK - selected file size \(ChrFileSize(numChrBlocks: self.numChrBlocks).friendlyName)")
        self.fileSizeSelectionDelegate?.fileSizeSelected(self.numChrBlocks)
        self.dismiss(self)
    }
}
