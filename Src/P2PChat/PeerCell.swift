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

struct PeerCellModel
{
    var peer: CBPeripheral
    
    //===
    
    var title: String? { get { return peer.name?.uppercaseString } }
}

//===

class PeerCell: UICollectionViewCell
{
    // MARK: Properties - IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: Methods - Custom
    
    func configure(viewModel: PeerCellModel)
    {
        titleLabel.text = viewModel.title
    }
}
