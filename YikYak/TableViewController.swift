
//  TableViewController.swift


import UIKit
import CoreLocation

class TableViewController: PFQueryTableViewController, CLLocationManagerDelegate {

    var pixs = [""]
    
    let locationManager = CLLocationManager()
    var currLocation : CLLocationCoordinate2D?
    
    override init!(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: className)
    }
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.parseClassName = "Yak"
        self.textKey = "text"
        self.pullToRefreshEnabled = true
        self.objectsPerPage = 200

    }
    
    
    private func alert(message : String) {
        let alert = UIAlertController(title: "Oops something went wrong.", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        let settings = UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default) { (action) -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            return
        }
        alert.addAction(settings)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 60
        self.tableView.rowHeight = UITableViewAutomaticDimension
        locationManager.desiredAccuracy = 1000
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        self.loadObjects()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        alert("Cannot fetch your location")
    }
    
    override func queryForTable() -> PFQuery! {
        let query = PFQuery(className: "Yak")
        if let queryLoc = currLocation {
            query.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: queryLoc.latitude, longitude: queryLoc.longitude), withinMiles: 10)
            query.limit = 200;
            query.orderByDescending("createdAt")
        } else {
            /* Decide on how the application should react if there is no location available */
            query.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: 37.411822, longitude: -121.941125), withinMiles: 10)
            query.limit = 200;
            query.orderByDescending("createdAt")
        }

        return query
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        locationManager.stopUpdatingLocation()
        if(locations.count > 0){
            let location = locations[0] as CLLocation
            println(location.coordinate)
            currLocation = location.coordinate
        } else {
            alert("Cannot fetch your location")
        }
    }
    

    override func objectAtIndexPath(indexPath: NSIndexPath!) -> PFObject! {
        var obj : PFObject? = nil
        if(indexPath.row < self.objects.count){
            obj = self.objects[indexPath.row] as PFObject
        }

        return obj
    }
    
    
    
    
    
    
    
    
    
    
   
  

    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!, object: PFObject!) -> PFTableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as TableViewCell
        cell.parseText.text = object.valueForKey("text") as String
        let score = object.valueForKey("count") as Int
        cell.count.text = "\(score)"
      //Code for Displaying Time  
    //Retrieve date from Parse Servers and display in label
        var dateUpdated = object.createdAt as NSDate
        var dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "h:mm a"
        let parseDate = NSString(format: "%@", dateFormat.stringFromDate(dateUpdated))
        
        cell.time.text = getTimeDifference(parseDate)
		//NSString(format: "%@", dateFormat.stringFromDate(dateUpdated))
        
    var year: 31536000
	var month: 2592000
	var week: 604800
	var day: 86400
	var hour: 3600
	var minute: 60
	func getTimeDifference(date: String) -> String {

	var currentTime: NSDate=NSDate()
	var seconds: currentTime.IntervalSinceDate(date)
	if seconds < minute {
		return "Moments ago"
	}
	if seconds < 2*minute {
		return "1 minute ago"
	}
	for index in 3...60 {
		if seconds < minute*index) {
			return "\(index-1) minutes ago"
		}
	}
	if seconds < 2*hour {
		return "1 hour ago"
	}
	for index in 3...24 {
		if seconds < hour*index {
			return "\(index-1) hours ago"
		}
	}
	if seconds < 2*day {
		return "1 day ago"
	}
	for index in 3...7 {
		if seconds < day*index {
			return "\(index-1) days ago"
		}
	}
	if seconds < 2*week {
		return "1 week ago"
	}
	for index in 3...4 {
		if seconds < week*(index) {
			return "\(index-1) weeks ago"
		}
	}
	if seconds < 2*month {
		return "1 month ago"
	}
	for index in 3...12 {
		if seconds < month*(index) {
			return "\(index-1) months ago"
		}
	}
	if seconds > year {
		return "1 year ago"
	}
}
        
    //Current Time to find date difference
        /*
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: date)
        let hour = components.hour
        let minutes = components.minute
        let seconds = components.second
        let secondString:String = String(components.second)
        //let date = pix.objectForKey("createdAt") as String
        //cell.time.text = date
        //cell.time.text = "\((indexPath.row + 1) * 3)m ago"
        */
        //let reportCount = object.valueForKey("reportCount")
        
        //cell.reportCounter.text = "\(reportCount)"
        
        
        //let replycnt = object.objectForKey("replies") as Int
        //cell.replies.text = "\(replycnt) replies"
       
        
    //Photo from user
        let userImageFile = object.valueForKey("profileImage") as PFFile
        userImageFile.getDataInBackgroundWithBlock {
            (imageData: NSData!, error: NSError!) -> Void in
            if error == nil {
                let image = UIImage(data:imageData)

                cell.parseImage.image = image
            }
        }

        
        
        return cell
    }
    //function creates/finds an id stored locally in a file
func userID() -> String {
	let destinationPath = NSTemporaryDirectory()+"userID.txt")
	let manager = NSFileManager.defaultManager()
	if manager.fileExistsAtPath(destinationPath) {
		let userID = NSString(contentsOfFile: destinationPath, encoding: NSUTF8StringEncoding, error: nil) as String
		return userID
	} else{	
		let userID = String(arc4random())
		var error: NSError?
		let written = userID.writeToFile(destinationPath, atomically: true, encoding: NSUTF8StringEncoding, error: &error)
		if written {
		println("Success")
		return userID
		} else {
			println("An error occurred:\(errorValue)")
		}
	}
}
    
  
    
    @IBAction func topButton(sender: AnyObject) {

        let hitPoint = sender.convertPoint(CGPointZero, toView: self.tableView)
        let hitIndex = self.tableView.indexPathForRowAtPoint(hitPoint)
        let object = objectAtIndexPath(hitIndex)
        let user = userID()
        let userArray :  [String] = [user]
        if !contains(object["Voters"],user) {
		object.incrementKey("count")
		object.addUniqueObjectsFromArray(userArray, forKey: "Voters")
		object.voters.append(userID)
		object.saveInBackground()
		self.tableView.reloadData()
		NSLog("Top Index Path \(hitIndex!.row)")
		}
		//object.incrementKey("count")
        //object.saveInBackground()
        //self.tableView.reloadData()
        //NSLog("Top Index Path \(hitIndex?.row)")
        
        
    }
	func inArray(user: String)-> bool {
		for element in object["Voters"] {
			if element == user {
				return true
			}
				return false
		}
	}

    @IBAction func bottomButton(sender: AnyObject) {

        let hitPoint = sender.convertPoint(CGPointZero, toView: self.tableView)
        let hitIndex = self.tableView.indexPathForRowAtPoint(hitPoint)
        let object = objectAtIndexPath(hitIndex)
        let userID = userID()
        if contains(object.voters, userID) {
			//do nothing
		} else {
		object.incrementKey("count", byAmount: -1)
		object.saveInBackground()
		object.voters.appends(userID)
		self.tableView.reloadData()
		NSLog("Bottom Index Path \(hitIndex!.row)")
		}
		//object.incrementKey("count", byAmount: -1)
        //object.saveInBackground()
        //self.tableView.reloadData()
        //NSLog("Bottom Index Path \(hitIndex?.row)")
        
    }
    
    
    
    
    
    @IBAction func reportPostPressed(sender: UIButton) {
       
        let hitPoint = sender.convertPoint(CGPointZero, toView: self.tableView)
        let hitIndex = self.tableView.indexPathForRowAtPoint(hitPoint)
        let object = objectAtIndexPath(hitIndex)
        object.incrementKey("reportCount", byAmount: 1)
        object.saveInBackground()
        self.tableView.reloadData()
        NSLog("Bottom Index Path \(hitIndex?.row)")

        let alertController = UIAlertController(title: "Reported", message:
            "Thank you for informing us! We will review this post for inappropriate content and act accordingly.", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
        let button = sender

        button.enabled = false
  
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "yakDetail"){
            let indexPath = self.tableView.indexPathForSelectedRow()
            let obj = self.objects[indexPath!.row] as PFObject
            let navVC = segue.destinationViewController as UINavigationController
            //let detailVC = navVC.topViewController as DetailViewController
            //detailVC.yak = obj
        }
    }
   
}
