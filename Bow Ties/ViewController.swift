//
//  ViewController.swift
//  Bow Ties
//
//  Created by Pietro Rea on 6/25/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
  
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var ratingLabel: UILabel!
  @IBOutlet weak var timesWornLabel: UILabel!
  @IBOutlet weak var lastWornLabel: UILabel!
  @IBOutlet weak var favoriteLabel: UILabel!
    
    var managedContext: NSManagedObjectContext!
    var currentBowtie: Bowtie!

  override func viewDidLoad() {
    super.viewDidLoad()
    insertSampleData()
    let request = NSFetchRequest(entityName: "Bowtie")
    let firstTitle = segmentedControl.titleForSegmentAtIndex(0)
    
    request.predicate = NSPredicate(format: "searchKey == %@", firstTitle!)
    
    var error: NSError? = nil
    var results = managedContext.executeFetchRequest(request, error: &error) as [Bowtie]?
    if let bowties = results {
        currentBowtie = bowties[0]
        populate(bowties[0])
    } else {
        println("Could not fetch \(error), \(error!.userInfo)")
    }
  }
    
    func populate(bowtie: Bowtie) {
        imageView.image = UIImage(data:bowtie.photoData)
        nameLabel.text = bowtie.name
        ratingLabel.text = "Rating: \(bowtie.rating.doubleValue)/5"
        timesWornLabel.text = "# times worn: \(bowtie.timesWorn.integerValue)"
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .NoStyle
        lastWornLabel.text = "Last worn: " + dateFormatter.stringFromDate(bowtie.lastWorn)
        
        favoriteLabel.hidden = !bowtie.isFavorite.boolValue
        view.tintColor = bowtie.tintColor as UIColor
    }
  
  @IBAction func segmentedControl(control: UISegmentedControl) {
        let selectedValue = control.titleForSegmentAtIndex(control.selectedSegmentIndex)
        let fetchRequest = NSFetchRequest(entityName: "Bowtie")
        fetchRequest.predicate = NSPredicate(format: "searchKey == %@", selectedValue!)
    
    var error: NSError?
    let results = managedContext.executeFetchRequest(fetchRequest, error: &error) as [Bowtie]?
    if let bowties = results {
        currentBowtie = bowties.last!
        populate(currentBowtie)
    } else {
        println("Couldn't fetch \(error), \(error!.userInfo)")
    }
  }

  @IBAction func wear(sender: AnyObject) {
    let times = currentBowtie.timesWorn.integerValue
    currentBowtie.timesWorn = NSNumber(integer: times + 1)
    currentBowtie.lastWorn = NSDate()
    var error: NSError?
    if !managedContext.save(&error) {
        println("Could not save \(error), \(error!.userInfo)")
    }
    populate(currentBowtie)
  }
  
  @IBAction func rate(sender: AnyObject) {
        let alert = UIAlertController(title: "New Rating", message: "Rate this bowtie", preferredStyle: .Alert)
    let saveAction = UIAlertAction(title: "Save", style: .Default) { (action: UIAlertAction!) -> Void in
            let textField = alert.textFields![0] as UITextField
            self.updateRating(textField.text)
        }
    let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (action: UIAlertAction!) -> Void in
        
    }
    alert.addTextFieldWithConfigurationHandler(addPlaceholderText)
    
    alert.addAction(saveAction)
    alert.addAction(cancelAction)
    
    presentViewController(alert, animated: true, completion: nil)
  }
    
    func addPlaceholderText(textField: UITextField!) {
        textField.placeholder = "1-5 rating"
    }
    
    func updateRating(numericString: String) {
        currentBowtie.rating = (numericString as NSString).doubleValue
        var error: NSError?
        
        if !managedContext.save(&error) {
            if error!.code == NSValidationNumberTooLargeError || error!.code == NSValidationNumberTooSmallError {
                rate(currentBowtie)
            }
        } else {
            populate(currentBowtie)
        }
    }
    
    
  func insertSampleData() {
        let fetchRequest = NSFetchRequest(entityName: "Bowtie")
        fetchRequest.predicate = NSPredicate(format: "searchKey != nil")
        let count = managedContext.countForFetchRequest(fetchRequest, error: nil);
        if count > 0 { return }
        let path = NSBundle.mainBundle().pathForResource("SampleData", ofType: "plist")
        let dataArray = NSArray(contentsOfFile: path!)!
        for dict : AnyObject in dataArray {
            let entity = NSEntityDescription.entityForName("Bowtie", inManagedObjectContext: managedContext)
            let bowtie = Bowtie(entity: entity!, insertIntoManagedObjectContext: managedContext)
            let btDict = dict as NSDictionary
            bowtie.name = btDict["name"] as NSString
            bowtie.searchKey = btDict["searchKey"] as NSString
            bowtie.rating = btDict["rating"] as NSNumber
            let tintColorDict = btDict["tintColor"] as NSDictionary
            bowtie.tintColor = colorFromDict(tintColorDict)
            let imageName = btDict["imageName"] as NSString
            let image = UIImage(named:imageName)
            let photoData = UIImagePNGRepresentation(image)
            bowtie.photoData = photoData
            bowtie.lastWorn = btDict["lastWorn"] as NSDate
            bowtie.timesWorn = btDict["timesWorn"] as NSNumber;
            bowtie.isFavorite = btDict["isFavorite"] as NSNumber
        }
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error!.userInfo)")
        }
    }
    func colorFromDict(dict: NSDictionary) -> UIColor { let red = dict["red"] as NSNumber
            let green = dict["green"] as NSNumber
            let blue = dict["blue"] as NSNumber
            let color = UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0,
            blue: CGFloat(blue)/255.0, alpha: 1)
            return color;
    }
}

