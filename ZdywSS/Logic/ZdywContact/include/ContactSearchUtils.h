//
//  ContactSearchUtils.h
//  ContactManager
//
//  Created by mini1 on 13-6-6.
//  Copyright (c) 2013年 D-TONG-TELECOM. All rights reserved.
//

#ifndef ContactManager_ContactSearchUtils_h
#define ContactManager_ContactSearchUtils_h

void* create_contact_instance();
int delete_contact_instance(void* instance);

int init_contacts(void* instance, const struct ContactListContainer* pContacts);
int init_contacts_for_search_only(void* instance, const struct ContactListContainer* pContacts);

int push_key(void* instance, unsigned int nKey);
int pop_key(void* instance);
int reset_key(void* instance);

const struct ContactWithKey* get_keypress_result(void* instance);
unsigned int get_real_contact_count(void* instance);

// for T9SearchEngine.m only!!
int release_contact_list_object( struct ContactListContainer* pContacts);

double calc_name_string_weight( const char* pszName );
double calc_phone_number_weight( const char* pszPhoneNumber );

// for text search only.
int push_one_char(void* instance, char nchar);
const struct ContactWithChar* get_charpress_result(void* instance);

#endif
