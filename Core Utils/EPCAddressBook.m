//
//  EPCAddressBook.m
//
//  Created by Everton Cunha on 15/03/13.
//

#import "EPCAddressBook.h"
#import <AddressBook/AddressBook.h>

@implementation EPCAddressBook

+ (BOOL)hasAccessToAddressBook {
	if (IOS_VERSION_LESS_THAN(@"6.0")) {
		return YES;
	}
	
	ABAuthorizationStatus status =  ABAddressBookGetAuthorizationStatus();
	
	if (status == kABAuthorizationStatusNotDetermined) {
		return [self requestAddressBookAccess];
	}
	
	return status == kABAuthorizationStatusAuthorized;
}

+ (BOOL)requestAddressBookAccess {
	__block BOOL accessGranted = NO;
	
	if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
		dispatch_semaphore_t sema = dispatch_semaphore_create(0);
		
		ABAddressBookRef addressBook = NULL;
		if (IOS_VERSION_LESS_THAN(@"6.0")) {
			addressBook = ABAddressBookCreate();
		}
		else {
			addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
		}
		ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
			accessGranted = granted;
			dispatch_semaphore_signal(sema);
		});
		
		dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
		dispatch_release(sema);
	}
	else { // we're on iOS 5 or older
		accessGranted = YES;
	}
	return accessGranted;

}

+ (NSArray *)allContacts {
	
    ABAddressBookRef addressBook =  NULL;
	if (ABAddressBookRequestAccessWithCompletion != NULL) {
		// iOS 6+
		[self requestAddressBookAccess];
		addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
	}
	else {
		addressBook = ABAddressBookCreate();
	}
	
    
	if (![self hasAccessToAddressBook]) {
		return nil;
	}
	
	NSCharacterSet *numbersSet = [NSCharacterSet decimalDigitCharacterSet];
	
    //Creates an NSArray from the CFArrayRef using toll-free bridging
    CFArrayRef arrayOfPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
	
	CFIndex count = CFArrayGetCount(arrayOfPeople);
	
	NSMutableArray *mut = [NSMutableArray arrayWithCapacity:count];
	
	for (CFIndex i = 0 ; i < count; i++) {
		
		EPCAddressBookPerson *pp = [[EPCAddressBookPerson alloc] init];
		[mut addObject:pp];
		[pp release];
		
		ABRecordRef person = CFArrayGetValueAtIndex(arrayOfPeople, i);
		
		CFStringRef value = ABRecordCopyValue(person, kABPersonFirstNameProperty);
		if (value != NULL) {
			pp.name = (id)value;
			CFRelease(value);
		}
		
		value = ABRecordCopyValue(person, kABPersonLastNameProperty);
		if (value != NULL) {
			pp.lastName = (id)value;
			CFRelease(value);
		}
		
		value = ABRecordCopyValue(person, kABPersonOrganizationProperty);
		if (value != NULL) {
			pp.companyName = (id)value;
			CFRelease(value);
		}
		
		ABMutableMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        CFIndex phoneNumberCount = ABMultiValueGetCount( phoneNumbers );
		
		NSMutableArray *phones = [NSMutableArray arrayWithCapacity:phoneNumberCount];
		pp.phones = phones;
		
        for (int k=0; k<phoneNumberCount; k++ )
		{
			NSMutableDictionary *mutDict = [NSMutableDictionary dictionaryWithCapacity:3];
			[phones addObject:mutDict];
			
            CFStringRef phoneNumberLabel = ABMultiValueCopyLabelAtIndex( phoneNumbers, k );
            CFStringRef phoneNumberValue = ABMultiValueCopyValueAtIndex( phoneNumbers, k );
            CFStringRef phoneNumberLocalizedLabel = ABAddressBookCopyLocalizedLabel( phoneNumberLabel );
		
			if (phoneNumberLocalizedLabel != NULL)
				[mutDict setObject:(id)phoneNumberLocalizedLabel forKey:@"label"];
		
			if (phoneNumberValue != NULL) {
				[mutDict setObject:(id)phoneNumberValue forKey:@"numberFormatted"];
			}
			
			NSMutableString *cleanNumber = nil;
			
			if (phoneNumberValue != NULL) {
				cleanNumber = [[NSMutableString alloc] initWithString:(id)phoneNumberValue];
				int i = 0;
				while (i < [cleanNumber length]) {
					if ([numbersSet characterIsMember:[cleanNumber characterAtIndex:i]]) {
						i++;
					}
					else {
						[cleanNumber replaceCharactersInRange:NSMakeRange(i, 1) withString:@""];
					}
				}
				if ([cleanNumber length] > 0) {
					[mutDict setObject:cleanNumber forKey:@"number"];
				}
				else {
					[mutDict setObject:@"" forKey:@"number"];
				}
				[cleanNumber release];
			}
			else {
				[mutDict setObject:@"" forKey:@"number"];
			}
			
            CFRelease(phoneNumberLocalizedLabel);
            CFRelease(phoneNumberLabel);
            CFRelease(phoneNumberValue);
		}
		
		CFRelease(phoneNumbers);
		
	}
	
	CFRelease(arrayOfPeople);
	
    CFRelease(addressBook);
	
	return mut;
}

@end


@implementation EPCAddressBookPerson

- (void)dealloc
{
    self.name = self.middleName = self.lastName = self.companyName = nil;
	self.phones = nil;
    [super dealloc];
}

- (NSString *)contactName {
	if (self.name && self.lastName) {
		return [self.name stringByAppendingFormat:@" %@", self.lastName];
	}
	if (self.name) {
		return self.name;
	}
	if (self.lastName) {
		return self.lastName;
	}
	if (self.middleName) {
		return self.middleName;
	}
	if (self.companyName) {
		return self.companyName;
	}
	return nil;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"name: %@, middle: %@, last: %@, company: %@, phones: %@", self.name, self.middleName, self.lastName, self.companyName, self.phones];
}
@end