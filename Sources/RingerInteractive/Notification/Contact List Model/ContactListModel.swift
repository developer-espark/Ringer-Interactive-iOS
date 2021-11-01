//
//	ContactListModel.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation


class ContactListModel : NSObject, NSCoding{

	var count : Int!
	var next : String!
	var objects : [ContactListObject]!
	var previous : String!
	var total : Int!


	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: [String:Any]){
		count = dictionary["count"] as? Int
		next = dictionary["next"] as? String
		objects = [ContactListObject]()
		if let objectsArray = dictionary["objects"] as? [[String:Any]]{
			for dic in objectsArray{
				let value = ContactListObject(fromDictionary: dic)
				objects.append(value)
			}
		}
		previous = dictionary["previous"] as? String
		total = dictionary["total"] as? Int
	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		if count != nil{
			dictionary["count"] = count
		}
		if next != nil{
			dictionary["next"] = next
		}
		if objects != nil{
			var dictionaryElements = [[String:Any]]()
			for objectsElement in objects {
				dictionaryElements.append(objectsElement.toDictionary())
			}
			dictionary["objects"] = dictionaryElements
		}
		if previous != nil{
			dictionary["previous"] = previous
		}
		if total != nil{
			dictionary["total"] = total
		}
		return dictionary
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         count = aDecoder.decodeObject(forKey: "count") as? Int
         next = aDecoder.decodeObject(forKey: "next") as? String
         objects = aDecoder.decodeObject(forKey :"objects") as? [ContactListObject]
         previous = aDecoder.decodeObject(forKey: "previous") as? String
         total = aDecoder.decodeObject(forKey: "total") as? Int

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder)
	{
		if count != nil{
			aCoder.encode(count, forKey: "count")
		}
		if next != nil{
			aCoder.encode(next, forKey: "next")
		}
		if objects != nil{
			aCoder.encode(objects, forKey: "objects")
		}
		if previous != nil{
			aCoder.encode(previous, forKey: "previous")
		}
		if total != nil{
			aCoder.encode(total, forKey: "total")
		}

	}

}