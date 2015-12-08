//
//  PeerCell.swift
//  P2PChat
//
//  Created by Maxim Khatskevich on 12/4/15.
//  Copyright © 2015 Maxim Khatskevich. All rights reserved.
//

import UIKit
import CoreBluetooth

//===

// we could declare model as a touple, if needed more than 1 value
// typealias PeerCellModel = (title: String?, subtitle: String?)
typealias PeerCellModel = String

//===

class PeerCell: UICollectionViewCell
{
    // MARK: Properties - IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: Methods - Custom
    
    class func viewModel(conversation: ConversationMdl) -> PeerCellModel
    {
//        var result = ""
        
        //===

//        if let peerName = peer.name
//        {
//            result = "\(peerName) / \(peer.identifier.UUIDString)"
//        }
//        else
//        {
//            result = "\(peer.identifier.UUIDString)"
//        }
        
        //===
        
        return (conversation.title ?? "Noname")
    }
    
    func configure(model: ConversationMdl)
    {
        // we could save viewModel in a property,
        // if need to keep it outside this function call;
        // or assign to a local variable,
        // if need to use multiple times
        
        titleLabel.text = PeerCell.viewModel(model)
    }
}
