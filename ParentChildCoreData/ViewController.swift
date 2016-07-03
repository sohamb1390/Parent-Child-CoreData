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
        self.saveToPrivateContext()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Fetch Products
    func fetchProducts(moc: NSManagedObjectContext!) {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest()
        
        // Create Entity Description
        let entityDescription = NSEntityDescription.entityForName("Product", inManagedObjectContext: moc)
        
        // Configure Fetch Request
        fetchRequest.entity = entityDescription
        let sortDesc = NSSortDescriptor(key: "pName", ascending: true)
        fetchRequest.sortDescriptors = [sortDesc]
        fetchRequest.fetchLimit = 100
        do {
            if let resultArray:[Product] = try self.mainMOC!.executeFetchRequest(fetchRequest) as? [Product] {
                self.arrProducts = resultArray
            }
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }
    
    // MARK: - Writing data -> Private Context -> Main Context -> Writer Context
    func saveToPrivateContext() {
        // Checking whether the PrivateManagedObjectContext is nil or not
        if self.privateMOC != nil {
            
            self.privateMOC?.performBlock({
                for index in 0..<20000 {
                    if let newProduct: Product = NSEntityDescription.insertNewObjectForEntityForName("Product", inManagedObjectContext: self.privateMOC!) as? Product {
                        newProduct.pName = "P\(index + 1)"
                        newProduct.pPrice = "\(index + 1)"
                        
                        do {
                            try self.privateMOC!.save()
                            print("Index Saved: \(index)")
                            
                            // This is optional, I am putting the privateQueue in sleep for 5 seconds for better performance
                            if index%1000 == 0 {
                                sleep(2)
                            }
                        }
                        catch let error as NSError {
                            print(error.localizedDescription)
                        }
                    }
                }
                // Final save operation on Private ManagedObjectContext
                do {
                    try self.privateMOC!.save()
                }
                catch let error as NSError {
                    print(error.localizedDescription)
                }
                // Fetching products using the private context
                self.fetchProducts(self.privateMOC)
                
                // Saving content on Main ManagedObjectContext & Writer ManagedObjectContext
                self.saveToParentAndWriterContext()
            })
        }
    }
    
    func saveToParentAndWriterContext() {
        if self.mainMOC != nil {
            self.mainMOC?.performBlock({
                
                // Updating UI
                self.tableView.reloadData()
                
                do {
                    try self.mainMOC!.save()
                }
                catch let error as NSError {
                    print(error.localizedDescription)
                }
                
                /// Finally the writer context will perform the save opration and persist the data to the disk
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
    }
}

// MARK: - UITableView DataSource & Delegates
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

