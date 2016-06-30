//
//  ViewController.swift
//  ParentChildCoreData
//
//  Created by Soham Bhattacharjee on 30/06/16.
//  Copyright © 2016 Soham Bhattacharjee. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var privateMOC:NSManagedObjectContext?
    var mainMOC: NSManagedObjectContext?
    var writerMOC: NSManagedObjectContext?
    
    var arrProducts:[Product] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.privateMOC = self.appDelegate.createPrivateMOC()
        self.mainMOC = self.appDelegate.mainMOC
        self.writerMOC = self.appDelegate.masterMOC
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.privateMOC != nil {
            
            self.privateMOC?.performBlock({ 
                for index in 0..<5000 {
                    if let newProduct: Product = NSEntityDescription.insertNewObjectForEntityForName("Product", inManagedObjectContext: self.privateMOC!) as? Product {
                        newProduct.pName = "P\(index + 1)"
                        newProduct.pPrice = "\(index + 1)"
                        
                        do {
                            try self.privateMOC!.save()
                            print("Index Saved: \(index)")
                            
                            // This is optional, I am putting the privateQueue in sleep for 5 seconds for better performance
                            if index%1000 == 0 {
                                sleep(5)
                            }
                        }
                        catch let error as NSError {
                            print(error.localizedDescription)
                        }
                    }
                }
                do {
                    try self.privateMOC!.save()
                }
                catch let error as NSError {
                    print(error.localizedDescription)
                }
                
                if self.mainMOC != nil {
                    self.mainMOC?.performBlock({ 
                        // Initialize Fetch Request
                        let fetchRequest = NSFetchRequest()
                        
                        // Create Entity Description
                        let entityDescription = NSEntityDescription.entityForName("Product", inManagedObjectContext: self.mainMOC!)
                        
                        // Configure Fetch Request
                        fetchRequest.entity = entityDescription
                        let sortDesc = NSSortDescriptor(key: "pName", ascending: true)
                        fetchRequest.sortDescriptors = [sortDesc]
                        
                        do {
                            if let resultArray:[Product] = try self.mainMOC!.executeFetchRequest(fetchRequest) as? [Product] {
                                self.arrProducts = resultArray
                                print(self.arrProducts)
                                self.tableView.reloadData()
                            }
                            
                        } catch {
                            let fetchError = error as NSError
                            print(fetchError)
                        }
                        
                        do {
                            try self.mainMOC!.save()
                        }
                        catch let error as NSError {
                            print(error.localizedDescription)
                        }
                        
                        if self.writerMOC != nil {
                            self.writerMOC?.performBlock({ 
                                do {
                                    try self.writerMOC!.save()
                                }
                                catch let error as NSError {
                                    print(error.localizedDescription)
                                }
                            })
                        }
                    })
                }
            })
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrProducts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellIdentifier", forIndexPath: indexPath)
        
        let productObj = self.arrProducts[indexPath.row]
        cell.textLabel?.text = productObj.pName
        cell.detailTextLabel?.text = productObj.pPrice
        return cell
    }
}

