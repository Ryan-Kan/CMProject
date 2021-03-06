//
//  CollectionViewCell.swift
//  CMProject
//
//  Created by Kan Onn Kit on 10/7/18.
//  Copyright © 2018 Kan Onn Kit. All rights reserved.
//

import UIKit

class EventCell: UICollectionViewCell {  // For each event
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventType: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventCredits: UILabel!
    
}
