import Foundation

class ContactListObject : NSObject, NSCoding{

	var id : String!
	var avatar : String!
	var contactId : String!
	var createdAt : Int!
	var createdBy : String!
	var deletedAt : Int!
	var firstName : String!
	var lastName : String!
	var modifiedAt : Int!
	var modifiedBy : String!
	var objectType : String!
	var phone : String!
	var regions : [String]!
	var tenantId : String!

	init(fromDictionary dictionary: [String:Any]){
		id = dictionary["_id"] as? String
		avatar = dictionary["avatar"] as? String
		contactId = dictionary["contactId"] as? String
		createdAt = dictionary["createdAt"] as? Int
		createdBy = dictionary["createdBy"] as? String
		deletedAt = dictionary["deletedAt"] as? Int
		firstName = dictionary["firstName"] as? String
		lastName = dictionary["lastName"] as? String
		modifiedAt = dictionary["modifiedAt"] as? Int
		modifiedBy = dictionary["modifiedBy"] as? String
		objectType = dictionary["objectType"] as? String
		phone = dictionary["phone"] as? String
		regions = dictionary["regions"] as? [String]
		tenantId = dictionary["tenantId"] as? String
	}

	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		if id != nil{
			dictionary["_id"] = id
		}
		if avatar != nil{
			dictionary["avatar"] = avatar
		}
		if contactId != nil{
			dictionary["contactId"] = contactId
		}
		if createdAt != nil{
			dictionary["createdAt"] = createdAt
		}
		if createdBy != nil{
			dictionary["createdBy"] = createdBy
		}
		if deletedAt != nil{
			dictionary["deletedAt"] = deletedAt
		}
		if firstName != nil{
			dictionary["firstName"] = firstName
		}
		if lastName != nil{
			dictionary["lastName"] = lastName
		}
		if modifiedAt != nil{
			dictionary["modifiedAt"] = modifiedAt
		}
		if modifiedBy != nil{
			dictionary["modifiedBy"] = modifiedBy
		}
		if objectType != nil{
			dictionary["objectType"] = objectType
		}
		if phone != nil{
			dictionary["phone"] = phone
		}
		if regions != nil{
			dictionary["regions"] = regions
		}
		if tenantId != nil{
			dictionary["tenantId"] = tenantId
		}
		return dictionary
	}

    @objc required init(coder aDecoder: NSCoder)
	{
         id = aDecoder.decodeObject(forKey: "_id") as? String
         avatar = aDecoder.decodeObject(forKey: "avatar") as? String
         contactId = aDecoder.decodeObject(forKey: "contactId") as? String
         createdAt = aDecoder.decodeObject(forKey: "createdAt") as? Int
         createdBy = aDecoder.decodeObject(forKey: "createdBy") as? String
         deletedAt = aDecoder.decodeObject(forKey: "deletedAt") as? Int
         firstName = aDecoder.decodeObject(forKey: "firstName") as? String
         lastName = aDecoder.decodeObject(forKey: "lastName") as? String
         modifiedAt = aDecoder.decodeObject(forKey: "modifiedAt") as? Int
         modifiedBy = aDecoder.decodeObject(forKey: "modifiedBy") as? String
         objectType = aDecoder.decodeObject(forKey: "objectType") as? String
         phone = aDecoder.decodeObject(forKey: "phone") as? String
         regions = aDecoder.decodeObject(forKey: "regions") as? [String]
         tenantId = aDecoder.decodeObject(forKey: "tenantId") as? String

	}

    @objc func encode(with aCoder: NSCoder)
	{
		if id != nil{
			aCoder.encode(id, forKey: "_id")
		}
		if avatar != nil{
			aCoder.encode(avatar, forKey: "avatar")
		}
		if contactId != nil{
			aCoder.encode(contactId, forKey: "contactId")
		}
		if createdAt != nil{
			aCoder.encode(createdAt, forKey: "createdAt")
		}
		if createdBy != nil{
			aCoder.encode(createdBy, forKey: "createdBy")
		}
		if deletedAt != nil{
			aCoder.encode(deletedAt, forKey: "deletedAt")
		}
		if firstName != nil{
			aCoder.encode(firstName, forKey: "firstName")
		}
		if lastName != nil{
			aCoder.encode(lastName, forKey: "lastName")
		}
		if modifiedAt != nil{
			aCoder.encode(modifiedAt, forKey: "modifiedAt")
		}
		if modifiedBy != nil{
			aCoder.encode(modifiedBy, forKey: "modifiedBy")
		}
		if objectType != nil{
			aCoder.encode(objectType, forKey: "objectType")
		}
		if phone != nil{
			aCoder.encode(phone, forKey: "phone")
		}
		if regions != nil{
			aCoder.encode(regions, forKey: "regions")
		}
		if tenantId != nil{
			aCoder.encode(tenantId, forKey: "tenantId")
		}

	}

}
