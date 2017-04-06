//
//  Cells.swift
//  CeriosDrivr
//
//  Created by Rey Cerio on 2017-02-28.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit
import Firebase

class BaseCell: UICollectionViewCell {
    override init(frame: CGRect){
        super.init(frame: frame)
        
        setupViews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        
    }
}

class DispatcherCell: BaseCell {
    
    let uid = FIRAuth.auth()?.currentUser?.uid
    var isOnline: String? {
        didSet{
            activeLabel.backgroundColor = .green
        }
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "name"
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    let activeLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(nameLabel)
        addSubview(activeLabel)
        
        addConstraintsWithVisualFormat(format: "H:|-6-[v0]-16-|", views: nameLabel)
        addConstraintsWithVisualFormat(format: "H:|-6-[v0]-16-|", views: activeLabel)

        addConstraintsWithVisualFormat(format: "V:|[v0(45)][v1]|", views: nameLabel, activeLabel)
    }
    //This solves the flicker on non pinged cells....cells that ping still flickers...to solve might need to observe from a child that doesnt get changed.
    //the ping helps tho :D
    override func prepareForReuse() {
        activeLabel.text = nil
        activeLabel.textColor = .black
    }
    
}

