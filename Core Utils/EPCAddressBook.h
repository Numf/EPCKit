//
//  EPCAddressBook.h
//
//  Created by Everton Cunha on 15/03/13.
//

#import <Foundation/Foundation.h>

@interface EPCAddressBook : NSObject

+ (NSArray*)allContacts;

+ (BOOL)requestAddressBookAccess;

+ (BOOL)hasAccessToAddressBook;
@end

@interface EPCAddressBookPerson : NSObject
@property (copy) NSString *name, *lastName, *middleName, *companyName;
@property (strong) NSArray *phones;
@property (readonly) NSString *contactName; // first and last, middle or company
@end