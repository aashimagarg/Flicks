//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Aashima Garg on 1/26/16.
//  Copyright © 2016 Aashima Garg. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD
import SwiftHEXColors

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var tableView: UITableView!
    
    var movies: [NSDictionary]?
    var endpoint: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        

        let refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl)
        
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.show(true)
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            print("response: \(responseDictionary)")
                            
                            hud.hide(true)
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            self.tableView.reloadData()
                            
                    }
                }
        })
        task.resume()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            
            return movies.count
            
        } else {
            return 0
        }
        
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        cell.backgroundColor = UIColor(hexString: "#81BEF7")
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(hexString: "#A9D0F5")
        cell.selectedBackgroundView = backgroundView
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as? String
        let overview = movie["overview"] as? String
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        
        if let posterPath = movie["poster_path"] as? String{
            let imageUrl = NSURL(string: baseUrl + posterPath)
            cell.posterView.setImageWithURLRequest(NSURLRequest(URL: imageUrl!), placeholderImage: nil, success: { (request: NSURLRequest, response: NSHTTPURLResponse?, image: UIImage) -> Void in
                if response != nil {
                    //This came from the server
                    cell.posterView.image = image
                }
                else{
                    //From the cache
                    cell.posterView.image = image
                }
                },
                failure: nil)
        }
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
     
        
        print("row \(indexPath.row)")
        return cell
    }
 
    func handleRefresh(refreshControl: UIRefreshControl){
        self.tableView.reloadData()
        refreshControl.endRefreshing()
        print("refreshed")
    }
    
   
    
  
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movie = movie
        
        print("prepare for segue called")
        
    }
  

}
