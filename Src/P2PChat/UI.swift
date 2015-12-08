//
//  UI.swift
//  P2PChat
//
//  Created by Maxim Khatskevich on 12/6/15.
//  Copyright © 2015 Maxim Khatskevich. All rights reserved.
//

import UIKit

//===

class UI
{
    // MARK: Methods - Private
    
    class private func mainStoryboard() -> UIStoryboard
    {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    // MARK: Methods - Public
    
    class func presentChatVC(chat: Any, fromVC: UIViewController)
    {
        let result =
            mainStoryboard().instantiateViewControllerWithIdentifier("ChatVC") as! ChatVC
        
        //===
        
        result.configure() // TODO: pass parameted later
        
        //===
        
        fromVC.navigationController?.pushViewController(result, animated: true)
    }
}