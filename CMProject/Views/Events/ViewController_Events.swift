//
//  ViewController_Events.swift
//  CMProject
//
//  Created by Kan Onn Kit on 10/7/18.
//  Copyright © 2018 Kan Onn Kit. All rights reserved.
//

import UIKit

class ViewController_Events: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    // Inlets
    
    // Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // Vars
    var dictEvents: [String:String] = [:]
    var arrayEvents = NSMutableArray()
    
    // Func
    override func viewDidLoad() {
        print()
        print("LOADING 'EVENTS' VIEW CONTROLLER")
        
        self.title = "Events"
        
        super.viewDidLoad()
        
        // MARK: - Gather Data
        let path = Bundle.main.path(forResource: "SGTouristEvents", ofType: "txt")
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path!)
        {
            let fullText = try! String(contentsOfFile: path!, encoding: String.Encoding.utf8)
            let readings = fullText.components(separatedBy: "\n")
            
            for i in 1..<readings.count-1
            {
                let eventData = readings[i].components(separatedBy: "|")
                dictEvents["Title"] = "\(eventData[0])"
                dictEvents["Event_Type"] = "\(eventData[1])"
                dictEvents["Event_Date"] = "\(eventData[2])"
                dictEvents["Event_Credits"] = "\(eventData[3])"  // Credits for the image
                
                arrayEvents.add(dictEvents)
            }
            
            print("No. of events loaded: \(arrayEvents.count)")
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK:- Collection view init
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayEvents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! EventCell
        cell.layer.cornerRadius = 8.0
        
        let cellContents = arrayEvents[indexPath.item] as! [String: String]
        
        cell.eventTitle.text = cellContents["Title"]
        cell.eventCredits.text = "Image by \(cellContents["Event_Credits"]!)"
        cell.eventType.text = cellContents["Event_Type"]
        cell.eventDate.text = cellContents["Event_Date"]
        cell.eventImage.image = UIImage(named: cellContents["Title"]!)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
