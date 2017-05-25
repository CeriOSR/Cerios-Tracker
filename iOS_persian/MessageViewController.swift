//
//  MessageViewController.swift
//  iOS_persian
//
//  Created by Rey Cerio on 2017-05-24.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class MessageViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var trackerController: TrackerController?
    
    var currentUser: User? {
        didSet{
            navigationItem.title = currentUser?.name
            print("message", currentUser?.name)
        }
    }
    
    var messages = [Message]()
        
    let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        return textField
    }()
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.lightGray.cgColor
        return textView
    }()
    
    let sendButton: UIButton = {
        let sendButton = UIButton(type: .system)
        sendButton.layer.borderWidth = 0.5
        sendButton.layer.borderColor = UIColor.lightGray.cgColor
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return sendButton
    }()
    
    let separatorLine: UIView = {
        let separatorLine = UIView()
        separatorLine.backgroundColor = .lightGray
        return separatorLine
    }()
    
    lazy var inputContainerView: UIView = {
        
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 150)
        
        //        containerView.addSubview(self.textField)
        containerView.addSubview(self.textView)
        containerView.addSubview(self.separatorLine)
        containerView.addSubview(self.sendButton)
        
        containerView.addConstraintsWithVisualFormat(format: "H:|[v0]|", views: self.separatorLine)
        containerView.addConstraintsWithVisualFormat(format: "H:|-2-[v0]-2-[v1(75)]-2-|", views: self.textView, self.sendButton)
        containerView.addConstraintsWithVisualFormat(format: "V:|[v0]|", views: self.textView)
        containerView.addConstraintsWithVisualFormat(format: "V:|[v0]|", views: self.sendButton)
        containerView.addConstraintsWithVisualFormat(format: "V:|[v0(1)]", views: self.separatorLine)
        
        return containerView
        
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive
        collectionView?.backgroundColor = .white
        self.collectionView!.register(MessageCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleBack))
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        handleFetchMessages()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MessageCell
        
        let message = messages[indexPath.item]
        
        cell.dateLabel.text = message.date
        cell.nameLabel.text = message.dispatcherName
        cell.messageLabel.text = message.message
        
        
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    func handleSend() {
        guard let text = textView.text else {return}
        guard let currentUserName = currentUser?.name else {return}
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {return}
        let messageRef = FIRDatabase.database().reference().child("message_feed").child(uid).childByAutoId()
        let values = ["date": String(describing:Date()), "dispatcherId": uid,"dispatcherName": currentUserName,"message": text] as [String : Any]
        messageRef.updateChildValues(values) { (error, ref) in
            print(messageRef.key)
            let messageFanRef = FIRDatabase.database().reference().child("messageIdByDispatcher").child(uid)
            messageFanRef.updateChildValues([messageRef.key: 1])
        }
        
    }
    
    func handleFetchMessages() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {return}
        let messageFanFetchRef = FIRDatabase.database().reference().child("messageIdByDispatcher").child(uid)
        messageFanFetchRef.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messageFetchRef = FIRDatabase.database().reference().child("message_feed").child(uid).child(messageId)
            messageFetchRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else {return}
                let message = Message()
                message.date = dictionary["date"] as? String
                message.dispatcherId = dictionary["dispatcherId"] as? String
                message.dispatcherName = dictionary["dispatcherName"] as? String
                message.message = dictionary["message"] as? String
                
                self.messages.append(message)
                DispatchQueue.main.async(execute: { 
                    self.collectionView?.reloadData()
                })
            }, withCancel: nil)
        }, withCancel: nil)
        
    
    }
    
    func handleBack() {
        let tabBarController = TabBarController()
        let navController = UINavigationController(rootViewController: tabBarController)
        self.present(navController, animated: true, completion: nil)
    }
    
}

