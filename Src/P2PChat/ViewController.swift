//
//  ViewController.swift
//  P2PChat
//
//  Created by Maxim Khatskevich on 12/3/15.
//  Copyright © 2015 Maxim Khatskevich. All rights reserved.
//

import UIKit
import CoreBluetooth

//===

class ViewController: UIViewController,
UICollectionViewDataSource,
UICollectionViewDelegate
{
    // MARK: Properties - IBOutlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var layout: UICollectionViewFlowLayout!

    // MARK: Methods - Overrided
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //===
        
        chat.activate()
        
        KVOController
        .bindWithObject(chat,
        keyPath: Selector("lastUpdated"))
        { [unowned self] (oldValue, newValue) -> Void in
                
                self.update()
        }
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        //===
        
        layout.itemSize.width = UIScreen.mainScreen().bounds.size.width
    }
    
    // MARK: Custom
    
    func update()
    {
        collectionView.reloadData()
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return chat.conversations.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let result = collectionView
            .dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! PeerCell
        
        //===

        result.configure(chat.conversations[indexPath.item])
        
        //===
        
        return result
    }
    
//    // MARK: - Navigation
//    
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//    }
}

