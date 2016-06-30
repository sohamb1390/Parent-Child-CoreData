//
//  Product+CoreDataProperties.swift
//  ParentChildCoreData
//
//  Created by Soham Bhattacharjee on 30/06/16.
//  Copyright © 2016 Soham Bhattacharjee. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Product {

    @NSManaged var pName: String?
    @NSManaged var pPrice: String?

}
